//
//  TrailerNowPlayingReporter.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import Kingfisher
import MediaPlayer
import UIKit

/// Reports the trailer playing out loud in the app on the system's now playing display.
@MainActor
final class TrailerNowPlayingReporter {
	// MARK: - Properties
	static let shared = TrailerNowPlayingReporter()

	/// The web player the display reports on.
	private weak var sourcePlayer: TrailerWebPlayer?

	/// The session tying the report to the system's now playing display.
	private var nowPlayingSession: Any?

	/// The reported trailer's title.
	private var reportTitle: String?

	/// The reported trailer's artwork.
	private var reportArtwork: MPMediaItemArtwork?

	/// The whole second the elapsed time was last reported at.
	private var lastReportedSecond = -1.0

	/// The system playback commands registered while the report stands.
	private var remoteCommandTargets: [(MPRemoteCommand, Any)] = []

	/// The silent player the display's timeline follows, since the display only takes an active
	/// session from a playing player and the trailer itself renders in a web view.
	private var silentPlayer: AVPlayer?

	/// The length the silent player's item was built to cover.
	private var silentDuration = 0.0

	/// The length of the silent track the timeline is built from.
	private static let silenceDuration = 1.0

	/// The address of the silent track backing the report.
	private static let silenceURL: URL? = {
		let url = FileManager.default.temporaryDirectory.appendingPathComponent("trailer-now-playing-silence.wav")

		if FileManager.default.fileExists(atPath: url.path) {
			return url
		}

		// One second of silent 8 kHz mono PCM keeps the file tiny.
		let sampleRate: UInt32 = 8000
		let dataSize = sampleRate * 2

		var wave = Data()
		wave.append(contentsOf: Array("RIFF".utf8))
		wave.append(withUnsafeBytes(of: (36 + dataSize).littleEndian) { Data($0) })
		wave.append(contentsOf: Array("WAVE".utf8))
		wave.append(contentsOf: Array("fmt ".utf8))
		wave.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
		wave.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
		wave.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
		wave.append(withUnsafeBytes(of: sampleRate.littleEndian) { Data($0) })
		wave.append(withUnsafeBytes(of: (sampleRate * 2).littleEndian) { Data($0) })
		wave.append(withUnsafeBytes(of: UInt16(2).littleEndian) { Data($0) })
		wave.append(withUnsafeBytes(of: UInt16(16).littleEndian) { Data($0) })
		wave.append(contentsOf: Array("data".utf8))
		wave.append(withUnsafeBytes(of: dataSize.littleEndian) { Data($0) })
		wave.append(Data(count: Int(dataSize)))

		do {
			try wave.write(to: url)
		} catch {
			print("----- [Trailer] Now playing silence could not be written: \(error.localizedDescription)")
			return nil
		}

		return url
	}()

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Reports the given player's trailer, or takes the report down, for its playback state.
	///
	/// - Parameter webPlayer: The web player the change came from.
	func update(for webPlayer: TrailerWebPlayer) {
		guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, watchOS 9.0, *) else { return }

		// The stream carries its own report while the trailer plays on a device.
		guard !TrailerAirPlayStreamer.shared.isStreaming(from: webPlayer) else {
			self.clear(for: webPlayer)
			return
		}

		// A silent trailer stands on the display only where it is what the reader came to watch,
		// so passing autoplay never takes the display from the music.
		let belongsOnDisplay = !webPlayer.isMuted || webPlayer.reportsNowPlaying

		if !webPlayer.isPaused, belongsOnDisplay {
			self.report(webPlayer)
		} else if self.sourcePlayer === webPlayer {
			if webPlayer.isPaused, belongsOnDisplay {
				self.publish(isPlaying: false)
			} else {
				self.clear(for: webPlayer)
			}
		}
	}

	/// Freshens the reported position as the trailer plays.
	///
	/// - Parameter webPlayer: The web player the report stands for.
	func updateProgress(for webPlayer: TrailerWebPlayer) {
		guard self.sourcePlayer === webPlayer, self.nowPlayingSession != nil else { return }

		let second = webPlayer.lastReportedTime.rounded(.down)
		guard second != self.lastReportedSecond else { return }

		self.lastReportedSecond = second
		self.publish(isPlaying: !webPlayer.isPaused)
	}

	/// Takes the report down for the given player.
	///
	/// - Parameter webPlayer: The web player whose report comes down.
	func clear(for webPlayer: TrailerWebPlayer) {
		guard self.sourcePlayer === webPlayer else { return }
		self.tearDown()
	}

	/// Reloads the report's title and artwork after the trailer's details change.
	///
	/// - Parameter webPlayer: The web player the details belong to.
	func refreshMetadata(for webPlayer: TrailerWebPlayer) {
		guard self.sourcePlayer === webPlayer, self.nowPlayingSession != nil else { return }
		self.loadMetadata(for: webPlayer)
	}

	/// Puts the given player's trailer on the display.
	///
	/// - Parameter webPlayer: The web player showing the trailer.
	@available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, watchOS 9.0, *)
	private func report(_ webPlayer: TrailerWebPlayer) {
		if self.sourcePlayer !== webPlayer || self.nowPlayingSession == nil {
			self.tearDown()

			guard Self.silenceURL != nil else { return }
			self.sourcePlayer = webPlayer

			let silentPlayer = AVPlayer()
			silentPlayer.volume = 0.0
			self.silentPlayer = silentPlayer

			let session = MPNowPlayingSession(players: [silentPlayer])
			session.automaticallyPublishesNowPlayingInfo = false
			self.nowPlayingSession = session
			self.registerRemoteCommands(on: session.remoteCommandCenter)
			session.becomeActiveIfPossible(completion: nil)
		}

		self.loadMetadata(for: webPlayer)
		self.publish(isPlaying: true)
	}

	/// Fills in the trailer's title and artwork as they turn up.
	///
	/// - Parameter webPlayer: The web player showing the trailer.
	private func loadMetadata(for webPlayer: TrailerWebPlayer) {
		guard let metadata = webPlayer.streamMetadata else { return }

		let title = L10n.trailerTitle(metadata.title)
		guard title != self.reportTitle else { return }

		let artworkURL = metadata.artworkURL.flatMap(URL.init(string:))
		self.reportTitle = title

		// The poster is usually already on screen, so the entry can go up whole in one write.
		let cachedArtwork = artworkURL.flatMap { KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: $0.cacheKey) }
		self.reportArtwork = cachedArtwork.map { Self.makeArtwork(from: $0) }
		self.publish(isPlaying: !webPlayer.isPaused)

		guard cachedArtwork == nil, let artworkURL = artworkURL else { return }

		Task { @MainActor [weak self] in
			guard let artwork = try? await KingfisherManager.shared.retrieveImage(with: artworkURL).image else { return }
			guard let self = self, self.sourcePlayer === webPlayer, self.reportTitle == title else { return }

			self.reportArtwork = Self.makeArtwork(from: artwork)
			self.publish(isPlaying: !webPlayer.isPaused)
		}
	}

	/// Builds the artwork the display shows for the trailer.
	///
	/// - Parameter image: The poster the artwork draws.
	///
	/// - Returns: A configured artwork.
	private static func makeArtwork(from image: UIImage) -> MPMediaItemArtwork {
		return MPMediaItemArtwork(boundsSize: image.size) { size in
			let format = UIGraphicsImageRendererFormat()
			format.scale = image.scale
			format.opaque = false

			return UIGraphicsImageRenderer(size: size, format: format).image { _ in
				image.draw(in: CGRect(origin: .zero, size: size))
			}
		}
	}

	/// Writes the trailer's entry on the display.
	///
	/// - Parameter isPlaying: Whether the trailer plays.
	private func publish(isPlaying: Bool) {
		guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, watchOS 9.0, *) else { return }
		guard let webPlayer = self.sourcePlayer, let session = self.nowPlayingSession as? MPNowPlayingSession else { return }

		var nowPlayingInfo: [String: Any] = [:]
		nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.video.rawValue
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = webPlayer.lastReportedTime
		nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

		if let title = self.reportTitle {
			nowPlayingInfo[MPMediaItemPropertyTitle] = title
		}

		if let artwork = self.reportArtwork {
			nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
		}

		if webPlayer.lastReportedDuration > 0.0 {
			nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = webPlayer.lastReportedDuration
		}

		session.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo

		#if targetEnvironment(macCatalyst)
		session.nowPlayingInfoCenter.playbackState = isPlaying ? .playing : .paused
		#endif

		self.syncSilentPlayer(isPlaying: isPlaying)
	}

	/// Keeps the silent player on the trailer's timeline, which the display reads as the entry's.
	///
	/// - Parameter isPlaying: Whether the trailer plays.
	private func syncSilentPlayer(isPlaying: Bool) {
		guard let webPlayer = self.sourcePlayer, let silentPlayer = self.silentPlayer else { return }

		let duration = webPlayer.lastReportedDuration
		if duration > 0.0, abs(duration - self.silentDuration) > 1.0, let item = Self.makeSilentItem(covering: duration) {
			self.silentDuration = duration
			silentPlayer.replaceCurrentItem(with: item)
		} else if silentPlayer.currentItem == nil, let item = Self.makeSilentItem(covering: Self.silenceDuration) {
			silentPlayer.replaceCurrentItem(with: item)
		}

		let elapsed = webPlayer.lastReportedTime
		if abs(silentPlayer.currentTime().seconds - elapsed) > 1.0 {
			silentPlayer.seek(to: CMTime(seconds: max(0.0, elapsed), preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
		}

		if isPlaying {
			silentPlayer.play()
		} else {
			silentPlayer.pause()
		}
	}

	/// Builds a silent item as long as the trailer, stacking the silent track without copying it.
	///
	/// - Parameter duration: The length to cover.
	///
	/// - Returns: A configured item.
	private static func makeSilentItem(covering duration: Double) -> AVPlayerItem? {
		guard let silenceURL = Self.silenceURL else { return nil }

		let asset = AVURLAsset(url: silenceURL)
		let composition = AVMutableComposition()
		let sourceRange = CMTimeRange(start: .zero, duration: CMTime(seconds: Self.silenceDuration, preferredTimescale: 600))
		let stackCount = Int((max(duration, Self.silenceDuration) / Self.silenceDuration).rounded(.up))

		for index in 0 ..< stackCount {
			let start = CMTime(seconds: Double(index) * Self.silenceDuration, preferredTimescale: 600)

			do {
				try composition.insertTimeRange(sourceRange, of: asset, at: start)
			} catch {
				print("----- [Trailer] Now playing timeline could not be built: \(error.localizedDescription)")
				return nil
			}
		}

		return AVPlayerItem(asset: composition)
	}

	/// Takes the report down.
	private func tearDown() {
		self.unregisterRemoteCommands()
		self.silentPlayer?.pause()
		self.silentPlayer = nil
		self.silentDuration = 0.0

		if #available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, watchOS 9.0, *), let session = self.nowPlayingSession as? MPNowPlayingSession {
			#if targetEnvironment(macCatalyst)
			session.nowPlayingInfoCenter.playbackState = .stopped
			#endif
			session.nowPlayingInfoCenter.nowPlayingInfo = nil
		}

		self.nowPlayingSession = nil
		self.sourcePlayer = nil
		self.reportTitle = nil
		self.reportArtwork = nil
		self.lastReportedSecond = -1.0
	}

	/// Registers the system's playback commands to drive the trailer.
	///
	/// - Parameter commandCenter: The command center taking the commands.
	private func registerRemoteCommands(on commandCenter: MPRemoteCommandCenter) {
		guard self.remoteCommandTargets.isEmpty else { return }

		let playTarget = commandCenter.playCommand.addTarget { _ in
			MainActor.assumeIsolated {
				TrailerNowPlayingReporter.shared.handleRemotePlay(true)
			}
		}
		let pauseTarget = commandCenter.pauseCommand.addTarget { _ in
			MainActor.assumeIsolated {
				TrailerNowPlayingReporter.shared.handleRemotePlay(false)
			}
		}
		let toggleTarget = commandCenter.togglePlayPauseCommand.addTarget { _ in
			MainActor.assumeIsolated {
				let reporter = TrailerNowPlayingReporter.shared
				return reporter.handleRemotePlay(reporter.sourcePlayer?.isPaused ?? true)
			}
		}
		let positionTarget = commandCenter.changePlaybackPositionCommand.addTarget { event in
			MainActor.assumeIsolated {
				guard let event = event as? MPChangePlaybackPositionCommandEvent, let sourcePlayer = TrailerNowPlayingReporter.shared.sourcePlayer else { return .commandFailed }
				sourcePlayer.seek(to: event.positionTime)
				return .success
			}
		}

		commandCenter.skipBackwardCommand.preferredIntervals = [15.0]
		commandCenter.skipForwardCommand.preferredIntervals = [15.0]

		let skipBackwardTarget = commandCenter.skipBackwardCommand.addTarget { event in
			MainActor.assumeIsolated {
				TrailerNowPlayingReporter.shared.handleRemoteSkip(by: -((event as? MPSkipIntervalCommandEvent)?.interval ?? 15.0))
			}
		}
		let skipForwardTarget = commandCenter.skipForwardCommand.addTarget { event in
			MainActor.assumeIsolated {
				TrailerNowPlayingReporter.shared.handleRemoteSkip(by: (event as? MPSkipIntervalCommandEvent)?.interval ?? 15.0)
			}
		}

		self.remoteCommandTargets = [
			(commandCenter.playCommand, playTarget),
			(commandCenter.pauseCommand, pauseTarget),
			(commandCenter.togglePlayPauseCommand, toggleTarget),
			(commandCenter.changePlaybackPositionCommand, positionTarget),
			(commandCenter.skipBackwardCommand, skipBackwardTarget),
			(commandCenter.skipForwardCommand, skipForwardTarget)
		]
	}

	/// Removes the trailer's playback commands.
	private func unregisterRemoteCommands() {
		for (command, target) in self.remoteCommandTargets {
			command.removeTarget(target)
		}

		self.remoteCommandTargets = []
	}

	/// Skips the trailer by the given stretch for a system command.
	///
	/// - Parameter interval: The seconds to skip by, negative for backwards.
	///
	/// - Returns: Whether the command was taken.
	private func handleRemoteSkip(by interval: Double) -> MPRemoteCommandHandlerStatus {
		guard let sourcePlayer = self.sourcePlayer else { return .commandFailed }

		sourcePlayer.seek(to: max(0.0, sourcePlayer.lastReportedTime + interval))
		return .success
	}

	/// Plays or pauses the trailer for a system command.
	///
	/// - Parameter isPlaying: Whether the trailer plays.
	///
	/// - Returns: Whether the command was taken.
	private func handleRemotePlay(_ isPlaying: Bool) -> MPRemoteCommandHandlerStatus {
		guard let sourcePlayer = self.sourcePlayer else { return .commandFailed }

		if isPlaying {
			sourcePlayer.play()
		} else {
			sourcePlayer.pause()
		}

		return .success
	}
}
