//
//  KTrailerPlayerView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import AVFoundation
import SwiftTheme
import UIKit

/// A view that plays a looping YouTube trailer inline with play, mute, and fullscreen controls.
final class KTrailerPlayerView: UIView {
	// MARK: - Views
	/// The transparent control that reveals the playback controls when tapped.
	private let tapControl: UIControl = {
		let control = UIControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.isUserInteractionEnabled = false
		return control
	}()

	/// The button that plays or pauses the trailer.
	private let playPauseButton = KTrailerPlayerView.makeControlButton(pointSize: 20.0, diameter: 52.0)

	/// The button that toggles the trailer's sound.
	private let muteButton = KTrailerPlayerView.makeControlButton(pointSize: 12.0, diameter: 34.0)

	/// The button that opens the trailer fullscreen.
	private let fullscreenButton = KTrailerPlayerView.makeControlButton(pointSize: 12.0, diameter: 34.0)

	// MARK: - Properties
	/// A Boolean value indicating whether the sound toggle stays visible while the trailer plays.
	var showsMuteToggle = false

	/// A Boolean value indicating whether the controls are shown.
	var showsControls = true {
		didSet {
			self.updateControls(animated: false)
		}
	}

	/// The view hosting the playback buttons in place of the player.
	///
	/// Assign a view outside a mirrored subtree to keep the buttons out of its copies.
	weak var controlsHost: UIView? {
		didSet {
			guard oldValue !== self.controlsHost else { return }
			self.mountControls()
		}
	}

	/// Called when the trailer's picture appears or disappears.
	var onPictureVisibilityChanged: (() -> Void)?

	/// A Boolean value indicating whether the trailer's picture is on screen.
	var isShowingPicture: Bool {
		return self.player?.isShowingPicture ?? false
	}

	/// The constraints pinning the buttons to the player.
	private var controlConstraints: [NSLayoutConstraint] = []

	/// A closure called when the trailer's playing state changes.
	var onPlaybackStateChange: ((Bool) -> Void)?

	/// A Boolean value indicating whether the trailer is currently playing.
	var isTrailerPlaying: Bool {
		self.isPlaying
	}

	/// The YouTube URL of the trailer currently loaded.
	private(set) var trailerURLString: String?

	/// The identifier of the trailer currently loaded.
	private var videoID: String?

	/// The player rendering the trailer.
	private var player: TrailerWebPlayer?

	/// A Boolean value indicating whether the coordinator granted the play slot.
	private var isPlaybackAllowed = false

	/// A Boolean value indicating whether the user asked for this trailer.
	private var isReaderInitiated = false

	/// A Boolean value indicating whether the trailer's sound is off.
	private var isMuted = true

	/// A Boolean value indicating whether the user paused the trailer.
	private var isPausedByReader = false

	/// A Boolean value indicating whether the trailer is playing.
	private var isPlaying = false {
		didSet {
			guard self.isPlaying != oldValue else { return }
			self.onPlaybackStateChange?(self.isPlaying)
		}
	}

	/// A Boolean value indicating whether the user revealed the controls.
	private var areControlsVisible = false

	/// The task that hides the controls after a period of inactivity.
	private var controlsHideTask: Task<Void, Never>?

	/// A Boolean value indicating whether a trailer is loaded.
	private var hasTrailer: Bool {
		self.videoID != nil
	}

	/// A Boolean value indicating whether the trailer may start without the user asking.
	var isEligibleForAutoplay: Bool {
		self.videoID != nil && self.autoplayAllowed
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

	/// The view controller hosting the view.
	private var owningViewController: UIViewController? {
		var responder: UIResponder? = self.next

		while let current = responder {
			if let viewController = current as? UIViewController {
				return viewController
			}

			responder = current.next
		}

		return nil
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

	/// Configures the controls and observes the app-active notification.
	private func sharedInit() {
		self.configureControls()
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleApplicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	// MARK: - View
	override func didMoveToWindow() {
		super.didMoveToWindow()

		if self.window == nil {
			self.setPlaybackAllowed(false)
		} else if self.hasTrailer {
			TrailerPlaybackCoordinator.shared.register(self)
		}

		if self.window != nil {
			self.mountControls()
		}

		TrailerPlaybackCoordinator.shared.setNeedsReevaluation()
	}

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, with: event)

		guard self.hasTrailer else {
			return hitView === self ? nil : hitView
		}

		return hitView
	}

	// MARK: - Functions
	/// Loads the trailer at the given YouTube URL.
	///
	/// - Parameter urlString: The YouTube URL of the trailer.
	func loadTrailer(fromURL urlString: String?) {
		let videoID = urlString.flatMap { $0.isEmpty ? nil : TrailerWebPlayer.videoID(fromURL: $0) }

		guard let videoID = videoID else {
			self.stopTrailer()
			return
		}
		guard videoID != self.videoID else { return }

		self.stopTrailer()
		self.trailerURLString = urlString
		self.videoID = videoID
		self.isMuted = true
		self.isReaderInitiated = false
		self.isPausedByReader = false
		self.updateControls(animated: false)

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
			self.pausePlayback()
		}
	}

	/// Plays the loaded trailer at the user's request, ignoring the autoplay policy.
	func playByReader() {
		guard self.hasTrailer else { return }
		self.isPausedByReader = false
		self.isReaderInitiated = true

		if let player = self.player {
			player.play()
		} else {
			TrailerPlaybackCoordinator.shared.pin(self)
		}

		self.updateControls(animated: true)
		self.scheduleControlsAutoHide()
	}

	/// Pauses the loaded trailer at the user's request.
	func pauseByReader() {
		guard self.hasTrailer else { return }
		self.isPausedByReader = true
		self.player?.pause()
		self.updateControls(animated: true)
	}

	/// Stops playback and unloads the trailer.
	func stopTrailer() {
		self.isPlaybackAllowed = false
		self.controlsHideTask?.cancel()
		self.controlsHideTask = nil

		self.player?.detach()
		self.player = nil
		self.isPlaying = false
		self.onPictureVisibilityChanged?()

		self.trailerURLString = nil
		self.videoID = nil
		self.isReaderInitiated = false
		self.isPausedByReader = false
		self.isMuted = true
		self.areControlsVisible = false
		self.updateControls(animated: false)

		TrailerPlaybackCoordinator.shared.unregister(self)
	}

	/// Acquires a warm player for the trailer and begins playing.
	private func beginPlayback() {
		guard let videoID = self.videoID, !self.isPausedByReader else { return }

		let player = TrailerPlayerPool.shared.player(forVideoID: videoID)
		self.player = player
		player.attach(to: self, isMuted: self.isMuted, delegate: self)
		player.play()

		self.onPictureVisibilityChanged?()
	}

	/// Pauses the trailer while keeping its player warm.
	private func pausePlayback() {
		self.controlsHideTask?.cancel()
		self.controlsHideTask = nil

		self.player?.pause()
		self.isPlaying = false
		self.areControlsVisible = false

		if !self.isMuted {
			self.isMuted = true
			self.player?.setMuted(true)
			self.applyAudioSession(muted: true)
		}

		self.updateControls(animated: false)
	}

	/// Toggles playback in response to the play or pause button.
	@objc private func togglePlayPause() {
		guard self.hasTrailer else { return }

		if self.isPlaying {
			self.isPausedByReader = true
			self.player?.pause()
		} else {
			self.isPausedByReader = false
			self.isReaderInitiated = true

			if let player = self.player {
				player.play()
			} else {
				TrailerPlaybackCoordinator.shared.pin(self)
			}
		}

		self.updateControls(animated: true)
		self.scheduleControlsAutoHide()
	}

	/// Toggles the trailer's sound in response to the mute button.
	@objc private func toggleMute() {
		self.isMuted.toggle()
		self.player?.setMuted(self.isMuted)
		self.applyAudioSession(muted: self.isMuted)
		self.updateControls(animated: false)
		self.scheduleControlsAutoHide()

		if !self.isMuted {
			TrailerPlaybackCoordinator.shared.pin(self)
		}
	}

	/// Opens the trailer fullscreen in response to the fullscreen button.
	@objc private func enterFullscreen() {
		guard let videoID = self.videoID, let owningViewController = self.owningViewController else { return }

		let fullscreenViewController = TrailerFullscreenViewController(videoID: videoID, isMuted: self.isMuted)
		fullscreenViewController.modalPresentationStyle = .overFullScreen
		fullscreenViewController.modalTransitionStyle = .crossDissolve
		owningViewController.present(fullscreenViewController, animated: true)
	}

	/// Reveals or hides the controls in response to a tap on the trailer.
	@objc private func toggleControlsVisibility() {
		guard self.hasTrailer else { return }

		self.areControlsVisible.toggle()
		self.updateControls(animated: true)
		self.scheduleControlsAutoHide()
	}

	/// Hides the controls after a delay while the trailer plays.
	private func scheduleControlsAutoHide() {
		self.controlsHideTask?.cancel()
		guard self.areControlsVisible, self.isPlaying else { return }

		self.controlsHideTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 3_000_000_000)
			guard !Task.isCancelled, let self = self else { return }

			self.areControlsVisible = false
			self.updateControls(animated: true)
		}
	}

	/// Updates the controls' visibility and glyphs for the current state.
	///
	/// - Parameter animated: Whether the change is animated.
	private func updateControls(animated: Bool) {
		var overlayIsVisible: Bool

		if !self.hasTrailer {
			overlayIsVisible = false
		} else if self.isPlaying {
			overlayIsVisible = self.areControlsVisible
		} else {
			let willStartAutomatically = self.isPlaybackAllowed || self.isEligibleForAutoplay
			overlayIsVisible = self.areControlsVisible || self.isPausedByReader || !willStartAutomatically
		}

		overlayIsVisible = overlayIsVisible && self.showsControls
		let muteIsVisible = self.isPlaying && (self.showsMuteToggle || self.areControlsVisible) && self.showsControls
		let fullscreenIsVisible = self.isPlaying && self.areControlsVisible && self.showsControls

		self.playPauseButton.setImage(UIImage(systemName: self.isPlaying ? "pause.fill" : "play.fill"), for: .normal)
		self.playPauseButton.accessibilityLabel = self.isPlaying ? L10n.pause : L10n.play
		self.muteButton.setImage(UIImage(systemName: self.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"), for: .normal)
		self.muteButton.accessibilityLabel = self.isMuted ? L10n.unmute : L10n.mute

		self.tapControl.isUserInteractionEnabled = self.hasTrailer && self.showsControls
		self.playPauseButton.isUserInteractionEnabled = overlayIsVisible
		self.muteButton.isUserInteractionEnabled = muteIsVisible
		self.fullscreenButton.isUserInteractionEnabled = fullscreenIsVisible

		let apply = {
			self.playPauseButton.alpha = overlayIsVisible ? 1.0 : 0.0
			self.muteButton.alpha = muteIsVisible ? 1.0 : 0.0
			self.fullscreenButton.alpha = fullscreenIsVisible ? 1.0 : 0.0
		}

		if animated {
			UIView.animate(withDuration: 0.25, animations: apply)
		} else {
			apply()
		}
	}

	/// Updates the audio session for the current sound state.
	///
	/// - Parameter muted: Whether the trailer's sound is off.
	private func applyAudioSession(muted: Bool) {
		do {
			if muted {
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

	/// Resumes playback when the app returns to the foreground.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc private func handleApplicationDidBecomeActive(_ notification: Notification) {
		guard self.window != nil, self.isPlaybackAllowed, !self.isPausedByReader else { return }
		self.player?.play()
	}

	/// Pins the controls above the trailer.
	private func configureControls() {
		self.tapControl.addTarget(self, action: #selector(self.toggleControlsVisibility), for: .touchUpInside)
		self.playPauseButton.addTarget(self, action: #selector(self.togglePlayPause), for: .primaryActionTriggered)
		self.muteButton.addTarget(self, action: #selector(self.toggleMute), for: .primaryActionTriggered)
		self.fullscreenButton.addTarget(self, action: #selector(self.enterFullscreen), for: .primaryActionTriggered)

		self.fullscreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
		self.fullscreenButton.accessibilityLabel = L10n.fullscreen

		self.addSubview(self.tapControl)
		NSLayoutConstraint.activate([
			self.tapControl.topAnchor.constraint(equalTo: self.topAnchor),
			self.tapControl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.tapControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.tapControl.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])

		self.mountControls()
	}

	/// Moves the buttons into the current host, keeping them anchored to the player.
	private func mountControls() {
		var host: UIView = self

		if let controlsHost = self.controlsHost, let window = self.window, controlsHost.window === window {
			host = controlsHost
		}

		guard self.playPauseButton.superview !== host else { return }

		NSLayoutConstraint.deactivate(self.controlConstraints)

		host.addSubview(self.playPauseButton)
		host.addSubview(self.muteButton)
		host.addSubview(self.fullscreenButton)

		self.controlConstraints = [
			self.playPauseButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.playPauseButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.playPauseButton.widthAnchor.constraint(equalToConstant: 52.0),
			self.playPauseButton.heightAnchor.constraint(equalToConstant: 52.0),

			self.muteButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
			self.muteButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12.0),
			self.muteButton.widthAnchor.constraint(equalToConstant: 34.0),
			self.muteButton.heightAnchor.constraint(equalToConstant: 34.0),

			self.fullscreenButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
			self.fullscreenButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12.0),
			self.fullscreenButton.widthAnchor.constraint(equalToConstant: 34.0),
			self.fullscreenButton.heightAnchor.constraint(equalToConstant: 34.0)
		]
		NSLayoutConstraint.activate(self.controlConstraints)
	}

	/// Builds a circular, blurred control button matching the app's media controls.
	///
	/// - Parameters:
	///    - pointSize: The point size of the button's symbol.
	///    - diameter: The button's diameter.
	///
	/// - Returns: A configured button.
	private static func makeControlButton(pointSize: CGFloat, diameter: CGFloat) -> KButton {
		let button = KButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.highlightBackgroundColorEnabled = false
		button.springEnabled = true
		button.addBlurEffect()
		button.theme_tintColor = KThemePicker.textColor.rawValue
		button.layerCornerRadius = diameter / 2.0
		button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold), forImageIn: .normal)
		button.alpha = 0.0
		return button
	}
}

// MARK: - TrailerWebPlayerDelegate
extension KTrailerPlayerView: TrailerWebPlayerDelegate {
	func trailerWebPlayerDidStartPlaying(_ trailerWebPlayer: TrailerWebPlayer) {
		self.isPlaying = true
		self.updateControls(animated: true)
		self.scheduleControlsAutoHide()
	}

	func trailerWebPlayerDidPause(_ trailerWebPlayer: TrailerWebPlayer) {
		self.isPlaying = false
		self.updateControls(animated: true)
	}

	func trailerWebPlayerDidFail(_ trailerWebPlayer: TrailerWebPlayer) {
		self.player?.detach()
		self.player = nil
		self.isPlaying = false
		self.updateControls(animated: false)
		self.onPictureVisibilityChanged?()
	}

	func trailerWebPlayerDidRevealPicture(_ trailerWebPlayer: TrailerWebPlayer) {
		self.onPictureVisibilityChanged?()
	}
}
