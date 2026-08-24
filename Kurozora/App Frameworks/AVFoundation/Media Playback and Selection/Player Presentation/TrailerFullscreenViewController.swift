//
//  TrailerFullscreenViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import SwiftTheme
import UIKit

/// A modal that plays a trailer fullscreen, reusing the trailer's warm player.
final class TrailerFullscreenViewController: UIViewController {
	// MARK: - Views
	/// The view hosting the player.
	private let contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .black
		return view
	}()

	/// The transparent control that reveals the playback controls when tapped.
	private let tapControl: UIControl = {
		let control = UIControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		return control
	}()

	/// The button that dismisses the fullscreen player.
	private let closeButton = TrailerFullscreenViewController.makeControlButton(pointSize: 14.0, diameter: 40.0)

	/// The button that plays or pauses the trailer.
	private let playPauseButton = TrailerFullscreenViewController.makeControlButton(pointSize: 24.0, diameter: 64.0)

	/// The button that toggles the trailer's sound.
	private let muteButton = TrailerFullscreenViewController.makeControlButton(pointSize: 14.0, diameter: 40.0)

	// MARK: - Properties
	/// The identifier of the trailer to play.
	private let videoID: String

	/// The player rendering the trailer.
	private var player: TrailerWebPlayer?

	/// A Boolean value indicating whether the trailer's sound is off.
	private var isMuted: Bool

	/// A Boolean value indicating whether the trailer is playing.
	private var isPlaying = false

	/// The task that hides the controls after a period of inactivity.
	private var controlsHideTask: Task<Void, Never>?

	override var prefersStatusBarHidden: Bool {
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .allButUpsideDown
	}

	// MARK: - Initializers
	init(videoID: String, isMuted: Bool) {
		self.videoID = videoID
		self.isMuted = isMuted
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureViews()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		TrailerPlaybackCoordinator.shared.beginFullscreen()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		let player = TrailerPlayerPool.shared.player(forVideoID: self.videoID)
		self.player = player
		player.attach(to: self.contentView, isMuted: self.isMuted, delegate: self)
		player.play()

		self.updateControls(animated: false)
		self.scheduleControlsAutoHide()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		self.controlsHideTask?.cancel()
		self.controlsHideTask = nil
		self.player?.detach()
		self.player = nil
		TrailerPlaybackCoordinator.shared.endFullscreen()
	}

	// MARK: - Functions
	/// Dismisses the fullscreen player.
	@objc private func close() {
		self.dismiss(animated: true)
	}

	/// Toggles playback in response to the play or pause button.
	@objc private func togglePlayPause() {
		if self.isPlaying {
			self.player?.pause()
		} else {
			self.player?.play()
		}

		self.updateControls(animated: true)
		self.scheduleControlsAutoHide()
	}

	/// Toggles the trailer's sound in response to the mute button.
	@objc private func toggleMute() {
		self.isMuted.toggle()
		self.player?.setMuted(self.isMuted)
		self.updateControls(animated: false)
		self.scheduleControlsAutoHide()
	}

	/// Reveals or hides the controls in response to a tap.
	@objc private func toggleControlsVisibility() {
		self.controlsHideTask?.cancel()
		let shouldShow = self.playPauseButton.alpha == 0.0
		self.setControls(visible: shouldShow, animated: true)

		if shouldShow {
			self.scheduleControlsAutoHide()
		}
	}

	/// Hides the controls after a delay while the trailer plays.
	private func scheduleControlsAutoHide() {
		self.controlsHideTask?.cancel()
		guard self.isPlaying else { return }

		self.controlsHideTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 3_000_000_000)
			guard !Task.isCancelled, let self = self else { return }
			self.setControls(visible: false, animated: true)
		}
	}

	/// Updates the controls' glyphs for the current state.
	///
	/// - Parameter animated: Whether the change is animated.
	private func updateControls(animated: Bool) {
		self.playPauseButton.setImage(UIImage(systemName: self.isPlaying ? "pause.fill" : "play.fill"), for: .normal)
		self.playPauseButton.accessibilityLabel = self.isPlaying ? L10n.pause : L10n.play
		self.muteButton.setImage(UIImage(systemName: self.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"), for: .normal)
		self.muteButton.accessibilityLabel = self.isMuted ? L10n.unmute : L10n.mute
		self.setControls(visible: true, animated: animated)
	}

	/// Shows or hides the transient controls.
	///
	/// - Parameters:
	///    - visible: Whether the controls are shown.
	///    - animated: Whether the change is animated.
	private func setControls(visible: Bool, animated: Bool) {
		let apply = {
			self.playPauseButton.alpha = visible ? 1.0 : 0.0
			self.muteButton.alpha = visible ? 1.0 : 0.0
		}

		if animated {
			UIView.animate(withDuration: 0.25, animations: apply)
		} else {
			apply()
		}
	}

	/// Pins the player and controls in the view.
	private func configureViews() {
		self.view.backgroundColor = .black
		self.view.addSubview(self.contentView)
		self.view.addSubview(self.tapControl)
		self.view.addSubview(self.closeButton)
		self.view.addSubview(self.playPauseButton)
		self.view.addSubview(self.muteButton)

		self.tapControl.addTarget(self, action: #selector(self.toggleControlsVisibility), for: .touchUpInside)
		self.closeButton.addTarget(self, action: #selector(self.close), for: .primaryActionTriggered)
		self.playPauseButton.addTarget(self, action: #selector(self.togglePlayPause), for: .primaryActionTriggered)
		self.muteButton.addTarget(self, action: #selector(self.toggleMute), for: .primaryActionTriggered)

		self.closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
		self.closeButton.accessibilityLabel = L10n.dismiss
		self.closeButton.alpha = 1.0

		let layoutMarginsGuide = self.view.layoutMarginsGuide

		NSLayoutConstraint.activate([
			self.contentView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.tapControl.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.tapControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.tapControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.tapControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.closeButton.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			self.closeButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			self.closeButton.widthAnchor.constraint(equalToConstant: 40.0),
			self.closeButton.heightAnchor.constraint(equalToConstant: 40.0),

			self.playPauseButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.playPauseButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
			self.playPauseButton.widthAnchor.constraint(equalToConstant: 64.0),
			self.playPauseButton.heightAnchor.constraint(equalToConstant: 64.0),

			self.muteButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			self.muteButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
			self.muteButton.widthAnchor.constraint(equalToConstant: 40.0),
			self.muteButton.heightAnchor.constraint(equalToConstant: 40.0)
		])
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
		return button
	}
}

// MARK: - TrailerWebPlayerDelegate
extension TrailerFullscreenViewController: TrailerWebPlayerDelegate {
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
		self.close()
	}
}
