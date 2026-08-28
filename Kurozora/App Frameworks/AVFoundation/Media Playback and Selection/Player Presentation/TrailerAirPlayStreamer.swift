//
//  TrailerAirPlayStreamer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import Kingfisher
import MediaPlayer
import UIKit

#if targetEnvironment(macCatalyst)
import Obfuscation
#endif

/// Streams a trailer to an AirPlay device through a native player, since the web player's video
/// cannot follow the system route.
@MainActor
final class TrailerAirPlayStreamer {
	// MARK: - Properties
	static let shared = TrailerAirPlayStreamer()

	/// The native player carrying the trailer to the device.
	private var player: AVPlayer?

	/// The web player the stream stands in for.
	private weak var sourcePlayer: TrailerWebPlayer?

	/// The observation following the native player onto and off the external route.
	private var externalPlaybackObservation: NSKeyValueObservation?

	/// The observer watching the streamed trailer play to its end.
	private var itemEndObserver: NSObjectProtocol?

	/// The observer carrying the stream's progress back to the app's controls.
	private var progressObserver: Any?

	/// A Boolean value indicating whether the stream is running on a device.
	private(set) var isStreaming = false

	/// A Boolean value indicating whether the streamer itself is working the web player.
	private var isAdjustingSource = false

	/// A Boolean value indicating whether the stream is waiting on the next trailer's manifest.
	private var isAdoptingSource = false

	/// The streamed trailer's title.
	private var streamTitle: String?

	/// The streamed trailer's artwork.
	private var streamArtwork: MPMediaItemArtwork?

	/// The now playing entry that stood before the stream took the display.
	private var previousNowPlayingInfo: [String: Any]?

	/// The system playback commands registered while the stream runs.
	private var remoteCommandTargets: [(MPRemoteCommand, Any)] = []

	/// The session tying the stream to the system's now playing display.
	private var nowPlayingSession: Any?

	/// The now playing display the stream reports on.
	private var nowPlayingCenter: MPNowPlayingInfoCenter {
		if #available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, watchOS 9.0, *), let session = self.nowPlayingSession as? MPNowPlayingSession {
			return session.nowPlayingInfoCenter
		}

		return MPNowPlayingInfoCenter.default()
	}

	/// The name of the device the stream plays on.
	var deviceName: String? {
		guard self.isStreaming, let player = self.player else { return nil }

		#if targetEnvironment(macCatalyst)
		let contextKey = #obfuscated("outputContext")
		let devicesKey = #obfuscated("outputDevices")
		let nameKey = #obfuscated("deviceName")
		guard
			player.responds(to: NSSelectorFromString(contextKey)),
			let outputContext = player.value(forKey: contextKey) as? NSObject
		else { return nil }

		var names: [String] = []

		if outputContext.responds(to: NSSelectorFromString(devicesKey)), let outputDevices = outputContext.value(forKey: devicesKey) as? [NSObject] {
			names = outputDevices.compactMap { outputDevice in
				guard outputDevice.responds(to: NSSelectorFromString(nameKey)) else { return nil }
				return outputDevice.value(forKey: nameKey) as? String
			}
		}

		if names.isEmpty, outputContext.responds(to: NSSelectorFromString(nameKey)), let contextName = outputContext.value(forKey: nameKey) as? String {
			names = [contextName]
		}

		// An internal endpoint identifier stands in where no friendly name is set.
		return names.first { !$0.contains("0x") && !$0.lowercased().contains("endpoint") }
		#else
		return AVAudioSession.sharedInstance().currentRoute.outputs.first { $0.portType == .airPlay }?.portName
		#endif
	}

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Returns whether the given player's trailer is streaming to a device.
	///
	/// - Parameter webPlayer: The web player to check.
	///
	/// - Returns: `true` while the trailer streams.
	func isStreaming(from webPlayer: TrailerWebPlayer?) -> Bool {
		guard let webPlayer = webPlayer else { return false }
		return self.isStreaming && self.sourcePlayer === webPlayer
	}

	/// Readies a native player for the given trailer and hands it to the picker.
	///
	/// - Parameters:
	///    - webPlayer: The web player showing the trailer.
	///    - routePickerView: The picker about to offer the devices.
	func arm(with webPlayer: TrailerWebPlayer?, for routePickerView: AVRoutePickerView) {
		guard let webPlayer = webPlayer else { return }

		if let streamURL = webPlayer.nativeStreamURL() {
			self.bind(webPlayer, streamURL: streamURL, to: routePickerView)
			return
		}

		// The manifest only turns up once the trailer has played a moment, so an early press
		// waits for it while the picker is up.
		Task { @MainActor [weak self, weak routePickerView] in
			for _ in 0 ..< 20 {
				try? await Task.sleep(nanoseconds: 500_000_000)
				guard let self = self, let routePickerView = routePickerView else { return }

				if let streamURL = webPlayer.nativeStreamURL() {
					self.bind(webPlayer, streamURL: streamURL, to: routePickerView)
					return
				}
			}
		}
	}

	/// Runs the armed player briefly, letting a picked route take it.
	///
	/// The player runs silent and unwatched, so a pick shows up on the device while no pick
	/// passes without a trace.
	func probe() {
		guard !self.isStreaming, let player = self.player else { return }

		player.volume = 0.0
		player.play()

		Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 1_500_000_000)
			guard let self = self, !self.isStreaming else { return }
			self.player?.pause()
		}
	}

	/// Moves the stream onto the given trailer, keeping the picked route.
	///
	/// - Parameter webPlayer: The web player showing the next trailer.
	func continueStream(with webPlayer: TrailerWebPlayer) {
		guard self.isStreaming, self.sourcePlayer !== webPlayer, let player = self.player else { return }

		// The next trailer plays locally for a moment, since only a playing page surfaces its
		// manifest. The stream takes it back as soon as the manifest is up.
		self.sourcePlayer = webPlayer
		self.isAdoptingSource = true

		Task { @MainActor [weak self] in
			defer { self?.isAdoptingSource = false }

			for _ in 0 ..< 20 {
				guard let self = self, self.isStreaming, self.sourcePlayer === webPlayer else { return }

				if let streamURL = webPlayer.nativeStreamURL() {
					let item = AVPlayerItem(url: streamURL)
					player.replaceCurrentItem(with: item)
					self.observeItemEnd(of: item)
					self.applyMetadata(from: webPlayer, to: item)

					self.isAdjustingSource = true
					webPlayer.pause()
					self.isAdjustingSource = false

					player.play()
					return
				}

				try? await Task.sleep(nanoseconds: 500_000_000)
			}
		}
	}

	/// Plays or pauses the stream in the web player's stead.
	///
	/// - Parameters:
	///    - isPlaying: Whether the stream plays.
	///    - webPlayer: The web player the request came from.
	///
	/// - Returns: `true` when the stream took the request.
	func setPlaying(_ isPlaying: Bool, from webPlayer: TrailerWebPlayer) -> Bool {
		guard self.isStreaming, self.sourcePlayer === webPlayer, !self.isAdjustingSource, !self.isAdoptingSource, let player = self.player else { return false }

		if isPlaying {
			player.play()
		} else {
			player.pause()
		}

		webPlayer.handleExternalStreamPlaying(isPlaying)
		self.publishNowPlayingInfo()

		#if targetEnvironment(macCatalyst)
		self.nowPlayingCenter.playbackState = isPlaying ? .playing : .paused
		#endif

		return true
	}

	/// Moves the stream to the given point.
	///
	/// - Parameters:
	///    - seconds: The point to play from.
	///    - webPlayer: The web player the request came from.
	func seek(to seconds: Double, from webPlayer: TrailerWebPlayer) {
		guard self.isStreaming, self.sourcePlayer === webPlayer else { return }
		self.player?.seek(to: CMTime(seconds: max(0.0, seconds), preferredTimescale: 600))
		self.publishNowPlayingInfo()
	}

	/// Carries the reader's volume onto the stream.
	///
	/// - Parameters:
	///    - volume: The loudness, from silent at `0` to full at `1`.
	///    - webPlayer: The web player the change came from.
	func setVolume(_ volume: Double, from webPlayer: TrailerWebPlayer) {
		guard self.isStreaming, self.sourcePlayer === webPlayer else { return }
		self.player?.volume = Float(min(max(0.0, volume), 1.0))
	}

	/// Carries the reader's sound choice onto the stream.
	///
	/// - Parameters:
	///    - isMuted: Whether the sound is off.
	///    - webPlayer: The web player the change came from.
	func setMuted(_ isMuted: Bool, from webPlayer: TrailerWebPlayer) {
		guard self.isStreaming, self.sourcePlayer === webPlayer else { return }
		self.player?.isMuted = isMuted
	}

	/// Ends the stream and hands playback back to the web player.
	func stop() {
		self.externalPlaybackObservation = nil

		if let itemEndObserver = self.itemEndObserver {
			NotificationCenter.default.removeObserver(itemEndObserver)
			self.itemEndObserver = nil
		}

		guard let player = self.player else { return }

		if let progressObserver = self.progressObserver {
			player.removeTimeObserver(progressObserver)
			self.progressObserver = nil
		}

		let seconds = player.currentTime().seconds
		player.pause()
		self.player = nil

		guard self.isStreaming else { return }
		self.isStreaming = false
		self.streamTitle = nil
		self.streamArtwork = nil
		self.unregisterRemoteCommands()

		// The display goes back to whoever held it before the stream.
		#if targetEnvironment(macCatalyst)
		self.nowPlayingCenter.playbackState = .stopped
		#endif

		if self.nowPlayingSession != nil {
			self.nowPlayingCenter.nowPlayingInfo = nil
			self.nowPlayingSession = nil
		} else {
			MPNowPlayingInfoCenter.default().nowPlayingInfo = self.previousNowPlayingInfo
		}

		self.previousNowPlayingInfo = nil

		guard let sourcePlayer = self.sourcePlayer else { return }

		self.isAdjustingSource = true
		if seconds.isFinite, seconds > 0.0 {
			sourcePlayer.seek(to: seconds)
		}
		sourcePlayer.play()
		self.isAdjustingSource = false
	}

	/// Builds the native player for the trailer and hands it to the picker.
	///
	/// - Parameters:
	///    - webPlayer: The web player showing the trailer.
	///    - streamURL: The address the native player streams from.
	///    - routePickerView: The picker taking the player.
	private func bind(_ webPlayer: TrailerWebPlayer, streamURL: URL, to routePickerView: AVRoutePickerView) {
		if self.sourcePlayer !== webPlayer || self.player == nil {
			self.stop()

			let item = AVPlayerItem(url: streamURL)
			let player = AVPlayer(playerItem: item)
			player.allowsExternalPlayback = true
			player.volume = 0.0
			self.player = player
			self.sourcePlayer = webPlayer
			self.observeExternalPlayback(of: player)
			self.observeItemEnd(of: item)
			self.applyMetadata(from: webPlayer, to: item)
		}

		// The system routes the picker's own player once a device is picked. The property is
		// AppKit's, carried over unpublished, so it is reached by name.
		guard routePickerView.responds(to: NSSelectorFromString("setPlayer:")) else {
			print("----- [Trailer] Route picker takes no player")
			return
		}

		routePickerView.setValue(self.player, forKey: "player")
	}

	/// Follows the native player onto and off the external route.
	///
	/// - Parameter player: The player to follow.
	private func observeExternalPlayback(of player: AVPlayer) {
		self.externalPlaybackObservation = player.observe(\.isExternalPlaybackActive, options: [.new]) { _, _ in
			DispatchQueue.main.async {
				TrailerAirPlayStreamer.shared.handleExternalPlaybackChange()
			}
		}
	}

	/// Watches the streamed trailer play to its end.
	///
	/// - Parameter item: The item to watch.
	private func observeItemEnd(of item: AVPlayerItem) {
		if let itemEndObserver = self.itemEndObserver {
			NotificationCenter.default.removeObserver(itemEndObserver)
		}

		self.itemEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { _ in
			MainActor.assumeIsolated {
				TrailerAirPlayStreamer.shared.handleStreamEnded()
			}
		}
	}

	/// Starts or ends the stream as the player moves between routes.
	private func handleExternalPlaybackChange() {
		guard let player = self.player else { return }

		if player.isExternalPlaybackActive {
			self.begin()
		} else if self.isStreaming {
			self.stop()
		}
	}

	/// Loops the streamed trailer or passes its end on to the queue.
	private func handleStreamEnded() {
		guard self.isStreaming, let sourcePlayer = self.sourcePlayer else { return }

		if sourcePlayer.loopsPlayback {
			self.player?.seek(to: .zero)
			self.player?.play()
			return
		}

		sourcePlayer.handleExternalStreamEnded()
	}

	/// Starts the stream from where the web player left off.
	private func begin() {
		guard !self.isStreaming, let player = self.player, let sourcePlayer = self.sourcePlayer else { return }
		self.isStreaming = true

		do {
			try AVAudioSession.sharedInstance().setCategory(.playback)
			try AVAudioSession.sharedInstance().setActive(true)
		} catch {
			print("----- [Trailer] AirPlay stream could not claim the audio session: \(error.localizedDescription)")
		}

		let startTime = sourcePlayer.lastReportedTime

		self.isAdjustingSource = true
		sourcePlayer.pause()
		self.isAdjustingSource = false

		player.volume = 1.0
		if startTime.isFinite, startTime > 0.0 {
			player.seek(to: CMTime(seconds: startTime, preferredTimescale: 600))
		}

		self.progressObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 600), queue: .main) { _ in
			MainActor.assumeIsolated {
				TrailerAirPlayStreamer.shared.reportProgress()
			}
		}

		player.play()
		sourcePlayer.handleExternalStreamPlaying(true)

		// The system only takes the entry from an app that reports its state and takes commands,
		// and a player-bound session is what carries both on the Mac.
		if #available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, watchOS 9.0, *) {
			// Automatic publication reads the item itself, and the stream carries no metadata of
			// its own, so the entry is written by hand instead.
			let session = MPNowPlayingSession(players: [player])
			session.automaticallyPublishesNowPlayingInfo = false
			self.nowPlayingSession = session
			self.registerRemoteCommands(on: session.remoteCommandCenter)
			session.becomeActiveIfPossible(completion: nil)
		} else {
			self.previousNowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
			self.registerRemoteCommands(on: MPRemoteCommandCenter.shared())
		}

		self.publishNowPlayingInfo()

		#if targetEnvironment(macCatalyst)
		self.nowPlayingCenter.playbackState = .playing
		#endif
	}

	/// Carries the stream's position back to the app's controls.
	private func reportProgress() {
		guard self.isStreaming, let player = self.player, let sourcePlayer = self.sourcePlayer else { return }

		let currentTime = player.currentTime().seconds
		let duration = player.currentItem?.duration.seconds ?? .nan
		guard currentTime.isFinite, duration.isFinite, duration > 0.0 else { return }

		sourcePlayer.handleExternalStreamProgress(currentTime: currentTime, duration: duration)
	}

	/// Puts the trailer's title on the stream, for the device's own overlay.
	///
	/// - Parameters:
	///    - webPlayer: The web player that knows the title.
	///    - item: The streamed item taking the title.
	private func applyMetadata(from webPlayer: TrailerWebPlayer, to item: AVPlayerItem) {
		Task { @MainActor [weak self, weak item] in
			guard let self = self, let item = item, let metadata = webPlayer.streamMetadata else { return }

			let title = L10n.trailerTitle(metadata.title)
			var externalMetadata = [Self.metadataItem(identifier: .commonIdentifierTitle, value: title as NSString)]

			if let synopsis = metadata.synopsis {
				externalMetadata.append(Self.metadataItem(identifier: .commonIdentifierDescription, value: synopsis as NSString))
			}

			item.externalMetadata = externalMetadata

			guard self.sourcePlayer === webPlayer else { return }
			self.streamTitle = title
			self.streamArtwork = nil
			self.publishNowPlayingInfo()

			guard let artworkURL = metadata.artworkURL.flatMap(URL.init(string:)) else { return }
			guard let artwork = try? await KingfisherManager.shared.retrieveImage(with: artworkURL).image else { return }
			guard self.sourcePlayer === webPlayer else { return }

			self.streamArtwork = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }

			if let artworkData = artwork.jpegData(compressionQuality: 0.9) {
				item.externalMetadata = externalMetadata + [Self.metadataItem(identifier: .commonIdentifierArtwork, value: artworkData as NSData)]
			}

			self.publishNowPlayingInfo()
		}
	}

	/// Builds a metadata entry for the streamed item.
	///
	/// - Parameters:
	///    - identifier: The entry's identifier.
	///    - value: The entry's value.
	///
	/// - Returns: A configured entry.
	private static func metadataItem(identifier: AVMetadataIdentifier, value: NSCopying & NSObjectProtocol) -> AVMetadataItem {
		let metadataItem = AVMutableMetadataItem()
		metadataItem.identifier = identifier
		metadataItem.value = value
		metadataItem.extendedLanguageTag = "und"
		return metadataItem
	}

	/// Registers the system's playback commands to drive the stream.
	///
	/// - Parameter commandCenter: The command center taking the commands.
	private func registerRemoteCommands(on commandCenter: MPRemoteCommandCenter) {
		guard self.remoteCommandTargets.isEmpty else { return }

		let playTarget = commandCenter.playCommand.addTarget { _ in
			MainActor.assumeIsolated {
				TrailerAirPlayStreamer.shared.handleRemotePlay(true)
			}
		}
		let pauseTarget = commandCenter.pauseCommand.addTarget { _ in
			MainActor.assumeIsolated {
				TrailerAirPlayStreamer.shared.handleRemotePlay(false)
			}
		}
		let toggleTarget = commandCenter.togglePlayPauseCommand.addTarget { _ in
			MainActor.assumeIsolated {
				let streamer = TrailerAirPlayStreamer.shared
				return streamer.handleRemotePlay(!((streamer.player?.rate ?? 0.0) > 0.0))
			}
		}
		let positionTarget = commandCenter.changePlaybackPositionCommand.addTarget { event in
			MainActor.assumeIsolated {
				let streamer = TrailerAirPlayStreamer.shared
				guard let event = event as? MPChangePlaybackPositionCommandEvent, let sourcePlayer = streamer.sourcePlayer else { return .commandFailed }
				sourcePlayer.seek(to: event.positionTime)
				return .success
			}
		}

		self.remoteCommandTargets = [
			(commandCenter.playCommand, playTarget),
			(commandCenter.pauseCommand, pauseTarget),
			(commandCenter.togglePlayPauseCommand, toggleTarget),
			(commandCenter.changePlaybackPositionCommand, positionTarget)
		]
	}

	/// Removes the stream's playback commands.
	private func unregisterRemoteCommands() {
		for (command, target) in self.remoteCommandTargets {
			command.removeTarget(target)
		}

		self.remoteCommandTargets = []
	}

	/// Plays or pauses the stream for a system command.
	///
	/// - Parameter isPlaying: Whether the stream plays.
	///
	/// - Returns: Whether the command was taken.
	private func handleRemotePlay(_ isPlaying: Bool) -> MPRemoteCommandHandlerStatus {
		guard let sourcePlayer = self.sourcePlayer else { return .commandFailed }
		return self.setPlaying(isPlaying, from: sourcePlayer) ? .success : .commandFailed
	}

	/// Puts the streamed trailer on the system's now playing display.
	private func publishNowPlayingInfo() {
		guard self.isStreaming, let player = self.player else { return }

		var nowPlayingInfo: [String: Any] = [:]
		nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.video.rawValue
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
		nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate

		if let title = self.streamTitle {
			nowPlayingInfo[MPMediaItemPropertyTitle] = title
		}

		if let artwork = self.streamArtwork {
			nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
		}

		if let duration = player.currentItem?.duration.seconds, duration.isFinite {
			nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
		}

		self.nowPlayingCenter.nowPlayingInfo = nowPlayingInfo
	}
}
