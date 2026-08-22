//
//  KTrailerPlayerView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import AVFoundation
import UIKit

/// A view that plays a looping, muted YouTube trailer with an optional sound toggle.
class KTrailerPlayerView: UIView {
	// MARK: - Views
	/// The view whose layer renders the trailer.
	private let playerView: PlayerView = {
		let playerView = PlayerView()
		playerView.isUserInteractionEnabled = false
		playerView.translatesAutoresizingMaskIntoConstraints = false
		playerView.alpha = 0.0
		return playerView
	}()

	/// The button that toggles the trailer's sound.
	private let muteToggleButton: UIButton = {
		var configuration = UIButton.Configuration.filled()
		configuration.baseBackgroundColor = UIColor.black.withAlphaComponent(0.6)
		configuration.baseForegroundColor = .white
		configuration.cornerStyle = .capsule
		configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12.0, weight: .semibold)

		let button = UIButton(configuration: configuration)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		return button
	}()

	/// The button that plays the trailer the autoplay policy withholds.
	private let playButton: UIButton = {
		var configuration = UIButton.Configuration.filled()
		configuration.baseBackgroundColor = UIColor.black.withAlphaComponent(0.6)
		configuration.baseForegroundColor = .white
		configuration.cornerStyle = .capsule
		configuration.image = UIImage(systemName: "play.fill")
		configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .semibold)

		let button = UIButton(configuration: configuration)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		return button
	}()

	// MARK: - Properties
	/// A Boolean value indicating whether the sound toggle is shown while the trailer plays.
	var showsMuteToggle = false

	/// The YouTube URL of the trailer currently loaded.
	private(set) var trailerURLString: String?

	/// The player that plays the trailer.
	private let queuePlayer = AVQueuePlayer()

	/// The looper repeating the trailer.
	private var playerLooper: AVPlayerLooper?

	/// The in-flight trailer resolution and preparation task.
	private var loadTask: Task<Void, Never>?

	/// The observation of the player layer's readiness.
	private var readyForDisplayObservation: NSKeyValueObservation?

	/// A Boolean value indicating whether the coordinator granted the play slot.
	private var isPlaybackAllowed = false

	/// A Boolean value indicating whether the reader asked for this trailer.
	private var isReaderInitiated = false

	/// The associated player layer object.
	var playerLayer: AVPlayerLayer {
		self.playerView.playerLayer
	}

	/// A Boolean value indicating whether the trailer may start without the reader asking.
	var isEligibleForAutoplay: Bool {
		self.trailerURLString != nil && self.autoplayAllowed
	}

	/// A Boolean value indicating whether the current autoplay policy and network permit playing a trailer.
	private var autoplayAllowed: Bool {
		switch UserSettings.videoAutoplayPolicy {
		case .never:
			return false
		case .wifiOnly:
			return !KNetworkManager.isOnCellular
		case .wifiAndCellular:
			return true
		}
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.configurePlayerView()

		self.playerLayer.player = self.queuePlayer
		self.playerLayer.videoGravity = .resizeAspectFill
		self.queuePlayer.isMuted = true
		self.queuePlayer.preventsDisplaySleepDuringVideoPlayback = false

		self.configureMuteToggleButton()
		self.configurePlayButton()

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleApplicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	// MARK: - View
	override func didMoveToWindow() {
		super.didMoveToWindow()

		if self.window == nil {
			self.queuePlayer.pause()
		} else {
			if self.trailerURLString != nil {
				TrailerPlaybackCoordinator.shared.register(self)
			}

			if self.playerLooper != nil {
				self.queuePlayer.play()
			}
		}

		TrailerPlaybackCoordinator.shared.setNeedsReevaluation()
	}

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, with: event)
		return hitView === self ? nil : hitView
	}

	// MARK: - Functions
	/// Loads the trailer at the given YouTube URL.
	///
	/// - Parameter urlString: The YouTube URL of the trailer.
	func loadTrailer(fromURL urlString: String?) {
		guard let urlString = urlString, !urlString.isEmpty else {
			self.stopTrailer()
			return
		}
		guard urlString != self.trailerURLString else { return }

		self.stopTrailer()
		self.trailerURLString = urlString
		self.updatePlayButton()

		TrailerPlaybackCoordinator.shared.register(self)
	}

	/// Starts or suspends the trailer for the given play permission.
	///
	/// - Parameter isAllowed: Whether this trailer holds the play slot.
	func setPlaybackAllowed(_ isAllowed: Bool) {
		guard self.isPlaybackAllowed != isAllowed else { return }
		self.isPlaybackAllowed = isAllowed

		if isAllowed {
			self.beginPlayback()
		} else {
			self.suspendPlayback()
		}
	}

	/// Stops playback and unloads the trailer.
	func stopTrailer() {
		self.isPlaybackAllowed = false
		self.suspendPlayback()
		self.trailerURLString = nil
		self.updatePlayButton()

		TrailerPlaybackCoordinator.shared.unregister(self)
	}

	/// Resolves the trailer's streams and starts looping them.
	private func beginPlayback() {
		guard let urlString = self.trailerURLString else { return }

		self.loadTask = Task { @MainActor [weak self] in
			guard let self = self else { return }

			do {
				let streams = try await YouTubeStreamResolver.shared.streams(forVideoURL: urlString)
				guard !Task.isCancelled else { return }

				let asset = try await self.playableAsset(from: streams)
				let isPlayable = try await asset.load(.isPlayable)
				guard isPlayable, !Task.isCancelled, self.isPlaybackAllowed else { return }

				self.startPlayback(with: AVPlayerItem(asset: asset))
			} catch {
				print("----- Failed to load trailer: \(String(describing: error))")
			}
		}
	}

	/// Tears the player down and hides the trailer.
	private func suspendPlayback() {
		self.loadTask?.cancel()
		self.loadTask = nil
		self.readyForDisplayObservation = nil

		self.playerLooper = nil
		self.queuePlayer.pause()
		self.queuePlayer.removeAllItems()
		self.isReaderInitiated = false

		if !self.queuePlayer.isMuted {
			self.setMuted(true)
		}

		self.playerView.layer.removeAllAnimations()
		self.playerView.alpha = 0.0
		self.muteToggleButton.isHidden = true
		self.updatePlayButton()
	}

	/// Builds the asset to play from the given streams.
	///
	/// - Parameter streams: The streams resolved for the trailer.
	///
	/// - Returns: An asset that `AVPlayer` can play.
	private func playableAsset(from streams: YouTubeStreamResolver.PlayableStreams) async throws -> AVAsset {
		let assetOptions = [AVURLAssetAllowsCellularAccessKey: false]

		if let combinedURL = streams.hlsURL ?? streams.progressiveURL {
			return AVURLAsset(url: combinedURL, options: assetOptions)
		}

		if self.wantsSoundToggle, let videoOnlyURL = streams.videoOnlyURL, let audioOnlyURL = streams.audioOnlyURL {
			return try await self.composition(videoURL: videoOnlyURL, audioURL: audioOnlyURL, options: assetOptions)
		}

		guard let videoOnlyURL = streams.videoOnlyURL else {
			throw YouTubeStreamResolver.ResolutionError.streamNotFound
		}
		return AVURLAsset(url: videoOnlyURL, options: assetOptions)
	}

	/// Composes separate adaptive video and audio streams into a single playable asset.
	///
	/// - Parameters:
	///    - videoURL: The video-only stream URL.
	///    - audioURL: The audio-only stream URL.
	///    - options: The options applied to the source assets.
	///
	/// - Returns: A composition carrying both the video and audio tracks.
	private func composition(videoURL: URL, audioURL: URL, options: [String: Any]) async throws -> AVAsset {
		let videoAsset = AVURLAsset(url: videoURL, options: options)
		let audioAsset = AVURLAsset(url: audioURL, options: options)

		async let videoTracks = videoAsset.loadTracks(withMediaType: .video)
		async let audioTracks = audioAsset.loadTracks(withMediaType: .audio)
		async let videoDuration = videoAsset.load(.duration)
		async let audioDuration = audioAsset.load(.duration)

		guard let videoTrack = try await videoTracks.first, let audioTrack = try await audioTracks.first else {
			throw YouTubeStreamResolver.ResolutionError.streamNotFound
		}

		let composition = AVMutableComposition()
		let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
		let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

		let duration = try await min(videoDuration, audioDuration)
		let timeRange = CMTimeRange(start: .zero, duration: duration)
		try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: .zero)
		try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: .zero)

		return composition
	}

	/// Starts looping playback of the given item.
	///
	/// - Parameter playerItem: The item to loop.
	private func startPlayback(with playerItem: AVPlayerItem) {
		self.playerLooper = AVPlayerLooper(player: self.queuePlayer, templateItem: playerItem)
		self.updatePlayButton()

		self.readyForDisplayObservation = self.playerLayer.observe(\.isReadyForDisplay, options: [.initial, .new]) { [weak self] playerLayer, _ in
			guard playerLayer.isReadyForDisplay else { return }

			DispatchQueue.main.async {
				guard let self = self, self.playerLooper != nil else { return }
				self.readyForDisplayObservation = nil
				self.muteToggleButton.isHidden = !self.wantsSoundToggle

				UIView.animate(withDuration: 0.5) {
					self.playerView.alpha = 1.0
				}
			}
		}

		self.queuePlayer.play()
	}

	/// A Boolean value indicating whether the sound toggle belongs on screen while the trailer plays.
	private var wantsSoundToggle: Bool {
		self.showsMuteToggle || self.isReaderInitiated
	}

	/// Pins the trailer view behind the view's controls.
	private func configurePlayerView() {
		self.addSubview(self.playerView)

		NSLayoutConstraint.activate([
			self.playerView.topAnchor.constraint(equalTo: self.topAnchor),
			self.playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}

	/// Configures the sound toggle button.
	private func configureMuteToggleButton() {
		self.muteToggleButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.setMuted(!self.queuePlayer.isMuted)
		}, for: .primaryActionTriggered)
		self.updateMuteToggleButton()

		self.addSubview(self.muteToggleButton)
		NSLayoutConstraint.activate([
			self.muteToggleButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
			self.muteToggleButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12.0),
			self.muteToggleButton.widthAnchor.constraint(equalToConstant: 34.0),
			self.muteToggleButton.heightAnchor.constraint(equalToConstant: 34.0)
		])
	}

	/// Configures the play button.
	private func configurePlayButton() {
		self.playButton.accessibilityLabel = L10n.playTrailer
		self.playButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.isReaderInitiated = true
			self.updatePlayButton()
			TrailerPlaybackCoordinator.shared.pin(self)
		}, for: .primaryActionTriggered)

		self.addSubview(self.playButton)
		NSLayoutConstraint.activate([
			self.playButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.playButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.playButton.widthAnchor.constraint(equalToConstant: 52.0),
			self.playButton.heightAnchor.constraint(equalToConstant: 52.0)
		])
	}

	/// Shows or hides the play button for the loaded trailer.
	private func updatePlayButton() {
		let hasTrailer = self.trailerURLString != nil
		self.playButton.isHidden = !hasTrailer || self.autoplayAllowed || self.isReaderInitiated || self.playerLooper != nil
	}

	/// Mutes or unmutes the trailer and updates the audio session.
	///
	/// - Parameter isMuted: Whether the trailer's sound is off.
	private func setMuted(_ isMuted: Bool) {
		self.queuePlayer.isMuted = isMuted
		self.updateMuteToggleButton()

		do {
			if isMuted {
				try AVAudioSession.sharedInstance().setCategory(.ambient)
				try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
			} else {
				try AVAudioSession.sharedInstance().setCategory(.playback)
				try AVAudioSession.sharedInstance().setActive(true)
			}
		} catch {
			print("----- Failed to update trailer audio session: \(error.localizedDescription)")
		}
	}

	/// Updates the sound toggle button's glyph and accessibility label for the current sound state.
	private func updateMuteToggleButton() {
		let isMuted = self.queuePlayer.isMuted
		self.muteToggleButton.configuration?.image = UIImage(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
		self.muteToggleButton.accessibilityLabel = isMuted ? L10n.unmute : L10n.mute
	}

	/// Resumes playback when the app returns to the foreground.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc private func handleApplicationDidBecomeActive(_ notification: Notification) {
		guard self.window != nil, self.playerLooper != nil else { return }
		self.queuePlayer.play()
	}
}

// MARK: - PlayerView
/// A view whose backing layer renders a player.
private final class PlayerView: UIView {
	override static var layerClass: AnyClass { AVPlayerLayer.self }

	/// The associated player layer object.
	var playerLayer: AVPlayerLayer {
		guard let layer = self.layer as? AVPlayerLayer else {
			fatalError("Layer is not of expected type AVPlayerLayer.")
		}
		return layer
	}
}
