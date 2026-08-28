//
//  KTrailerPlayerView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import AVKit
import SwiftTheme
import UIKit

#if targetEnvironment(macCatalyst)
import Obfuscation
#endif

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

	/// The notice covering the picture while the trailer plays on an AirPlay device.
	private let airPlayNoticeView = TrailerAirPlayNoticeView()

	/// The layer dimming the picture while the full controls show.
	private let scrimView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
		view.isUserInteractionEnabled = false
		view.alpha = 0.0
		return view
	}()

	/// The button that plays or pauses the trailer.
	private let playPauseButton = KTrailerPlayerView.makeControlButton(pointSize: 17.0, diameter: 44.0)

	/// The button that toggles the trailer's sound.
	private let muteButton = KTrailerPlayerView.makeControlButton(pointSize: 11.0, diameter: 30.0)

	/// The button that opens the trailer fullscreen.
	private let fullscreenButton = KTrailerPlayerView.makeControlButton(pointSize: 11.0, diameter: 30.0)

	/// The capsule grouping the floating window and AirPlay controls.
	private let outputGroupView = KTrailerPlayerView.makeControlBar(cornerRadius: 15.0)

	#if targetEnvironment(macCatalyst)
	/// The button that opens the trailer in a floating window.
	private let pictureInPictureButton = KTrailerPlayerView.makeGroupedGlyphButton(systemName: "pip.enter")
	#endif

	/// The control that picks the AirPlay device the native side-stream plays on.
	private let airPlayRoutePickerView: AVRoutePickerView = {
		let routePickerView = AVRoutePickerView()
		routePickerView.translatesAutoresizingMaskIntoConstraints = false
		routePickerView.tintColor = .white
		routePickerView.activeTintColor = .white
		routePickerView.prioritizesVideoDevices = true
		return routePickerView
	}()

	/// The capsule holding the timeline controls.
	private let timeBarView = KTrailerPlayerView.makeControlBar(cornerRadius: 20.0)

	/// The label showing how far the trailer has played.
	private let elapsedTimeLabel = KTrailerPlayerView.makeTimeLabel()

	/// The label showing the time left in the trailer.
	private let remainingTimeLabel = KTrailerPlayerView.makeTimeLabel()

	/// The slider scrubbing through the trailer.
	private let scrubber: UISlider = {
		let slider = UISlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.minimumValue = 0.0
		slider.maximumValue = 1.0
		slider.setContentHuggingPriority(.init(1.0), for: .horizontal)

		#if !targetEnvironment(macCatalyst)
		slider.minimumTrackTintColor = .white
		slider.maximumTrackTintColor = UIColor(white: 0.32, alpha: 1.0)
		#endif

		return slider
	}()

	// MARK: - Properties
	/// A Boolean value indicating whether the sound toggle stays visible while the trailer plays.
	var showsMuteToggle = false

	/// A Boolean value indicating whether the player shows the compact control set with the timeline and output controls.
	var showsCompactControls = false {
		didSet {
			guard oldValue != self.showsCompactControls else { return }
			self.applyControlGlyphs()
			self.remountControls()
			self.updateControls(animated: false)
		}
	}

	/// A Boolean value indicating whether the controls are shown.
	var showsControls = true {
		didSet {
			self.updateControls(animated: false)
		}
	}

	/// A Boolean value indicating whether the sound and fullscreen buttons appear over the trailer.
	///
	/// Turn this off where those controls are offered elsewhere, such as in the navigation bar.
	var showsSecondaryControls = true {
		didSet {
			self.updateControls(animated: false)
		}
	}

	/// A Boolean value indicating whether the trailer's sound is off.
	var isTrailerMuted: Bool {
		self.isMuted
	}

	/// A Boolean value indicating whether a trailer is loaded.
	var hasLoadedTrailer: Bool {
		self.hasTrailer
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

	/// A Boolean value indicating whether the trailer starts over when it ends.
	var loopsPlayback = true

	/// Called when the trailer plays to its end, once looping is off.
	var onPlaybackEnded: (() -> Void)?

	/// Shares what the trailer belongs to, from the given view.
	var shareHandler: ((UIView) -> Void)?

	/// The details the trailer shows wherever it plays outside the app.
	var streamMetadata: TrailerStreamMetadata? {
		didSet {
			self.webPlayer?.streamMetadata = self.streamMetadata
		}
	}

	/// A Boolean value indicating whether the trailer stands for the reader's viewing, and so
	/// belongs on the system's display even while silent.
	var reportsNowPlaying = false {
		didSet {
			self.webPlayer?.reportsNowPlaying = self.reportsNowPlaying
		}
	}

	/// A Boolean value indicating whether the trailer's picture is on screen.
	var isShowingPicture: Bool {
		return self.webPlayer?.isShowingPicture ?? false
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

	/// The web player rendering the trailer.
	private var webPlayer: TrailerWebPlayer?

	/// A Boolean value indicating whether the coordinator granted the play slot.
	private var isPlaybackAllowed = false

	/// A Boolean value indicating whether the user asked for this trailer.
	private var isReaderInitiated = false

	/// A Boolean value indicating whether the trailer's sound is off.
	private var isMuted = true

	/// A Boolean value indicating whether the user paused the trailer.
	private var isPausedByReader = false

	/// A Boolean value indicating whether playback is suspended while the trailer is out of sight.
	private var isSuspended = false

	/// A Boolean value indicating whether the trailer was playing when it was suspended.
	private var wasPlayingBeforeSuspension = false

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

	/// The trailer's length in seconds.
	private var duration = 0.0

	/// The seconds played so far.
	private var elapsedTime = 0.0

	/// A Boolean value indicating whether the reader is dragging the scrubber.
	private var isScrubbing = false

	/// The time the player's reported point is trusted again after a seek.
	private var seekSettleDate: Date?

	/// The stand-in holding the last picture while the next trailer loads.
	private var transitionSnapshotView: UIView?

	/// A Boolean value indicating whether the last picture is held while the next trailer loads.
	var isHoldingLastFrame: Bool {
		self.transitionSnapshotView != nil
	}

	/// The pointer's last reported location over the trailer.
	private var lastPointerLocation: CGPoint?

	/// A Boolean value indicating whether a synthesized press is on its way to the page.
	private var isSendingPagePress = false

	#if targetEnvironment(macCatalyst)
	/// A Boolean value indicating whether the scrubber's filled track has been colored.
	private var didApplyTrackFill = false
	#endif

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

	override func layoutSubviews() {
		super.layoutSubviews()

		#if targetEnvironment(macCatalyst)
		self.applyTrackFill()
		#endif
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

		// The outgoing picture holds still until the next trailer's is up, so the swap never
		// falls back to an empty player.
		let outgoingSnapshotView = self.isShowingPicture ? self.snapshotView(afterScreenUpdates: false) : nil

		self.stopTrailer()

		if let outgoingSnapshotView = outgoingSnapshotView {
			outgoingSnapshotView.frame = self.bounds
			outgoingSnapshotView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			outgoingSnapshotView.isUserInteractionEnabled = false
			self.insertSubview(outgoingSnapshotView, belowSubview: self.tapControl)
			self.transitionSnapshotView = outgoingSnapshotView
		}

		self.trailerURLString = urlString
		self.videoID = videoID
		self.isReaderInitiated = false
		self.isPausedByReader = false

		// A trailer that is still warm is put back on screen straight away, paused at the frame the
		// reader left it on, so returning to it shows the video instead of the banner while the
		// coordinator decides who may play.
		if let warmPlayer = TrailerPlayerPool.shared.warmPlayer(forVideoID: videoID) {
			self.webPlayer = warmPlayer
			warmPlayer.attach(to: self, isMuted: self.isMuted, delegate: self)
			warmPlayer.setLooping(self.loopsPlayback)
			warmPlayer.streamMetadata = self.streamMetadata
			warmPlayer.reportsNowPlaying = self.reportsNowPlaying
			self.onPictureVisibilityChanged?()
		}

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

		if !self.resumeWarmPlayer() {
			TrailerPlaybackCoordinator.shared.pin(self)
		}

		self.updateControls(animated: true)
		self.scheduleControlsAutoHide()
	}

	/// Toggles the trailer's sound at the user's request.
	func toggleMuteByReader() {
		self.toggleMute()
	}

	/// Opens the trailer fullscreen at the user's request.
	func enterFullscreenByReader() {
		self.enterFullscreen()
	}

	/// Pauses the trailer while it is out of sight, resuming it when it comes back.
	///
	/// Unlike pausing at the user's request, this remembers whether the trailer was playing, so a
	/// trailer the user never started stays stopped when it returns.
	///
	/// - Parameter isSuspended: Whether the trailer is out of sight.
	func setPlaybackSuspended(_ isSuspended: Bool) {
		guard self.isSuspended != isSuspended else { return }
		self.isSuspended = isSuspended

		if isSuspended {
			self.wasPlayingBeforeSuspension = self.isPlaying
			guard self.isPlaying else { return }

			self.webPlayer?.pause()
			self.clearNowPlayingReport()
			self.isPlaying = false
			self.updateControls(animated: true)
		} else if self.wasPlayingBeforeSuspension {
			self.wasPlayingBeforeSuspension = false
			self.beginPlayback()
		}
	}

	/// Pauses the loaded trailer at the user's request.
	func pauseByReader() {
		guard self.hasTrailer else { return }
		self.isPausedByReader = true
		self.webPlayer?.pause()
		self.updateControls(animated: true)
	}

	/// Stops playback and unloads the trailer.
	func stopTrailer() {
		self.isPlaybackAllowed = false
		self.controlsHideTask?.cancel()
		self.controlsHideTask = nil
		self.clearTransitionSnapshot(animated: false)

		self.webPlayer?.detach()
		self.webPlayer = nil
		self.isPlaying = false
		self.onPictureVisibilityChanged?()

		self.trailerURLString = nil
		self.videoID = nil
		self.isReaderInitiated = false
		self.isPausedByReader = false
		self.isSuspended = false
		self.wasPlayingBeforeSuspension = false
		self.areControlsVisible = false
		self.duration = 0.0
		self.elapsedTime = 0.0
		self.isScrubbing = false
		self.seekSettleDate = nil
		self.updateProgressControls()
		self.updateControls(animated: false)

		TrailerPlaybackCoordinator.shared.unregister(self)
	}

	/// Begins playing the trailer through the pooled web player.
	private func beginPlayback() {
		guard let videoID = self.videoID, self.window != nil, !self.isPausedByReader, !self.isSuspended else { return }

		if self.resumeWarmPlayer() {
			return
		}

		self.startWebPlayback(forVideoID: videoID)
	}

	/// Takes the player back when the fullscreen presentation closes.
	func reclaimPlayerFromFullscreen() {
		guard let webPlayer = self.webPlayer else { return }

		self.isMuted = webPlayer.isMuted

		if !webPlayer.isHosting(self) {
			webPlayer.attach(to: self, isMuted: self.isMuted, delegate: self)
		}

		webPlayer.setLooping(self.loopsPlayback)

		self.layoutIfNeeded()

		// The trailer comes back exactly as the reader left it in fullscreen.
		if webPlayer.isPaused {
			self.isPausedByReader = true
			self.isPlaying = false
		} else if !self.isSuspended {
			self.isPausedByReader = false
			self.isPlaying = true
			webPlayer.play()
		}

		self.updateControls(animated: false)
		self.onPictureVisibilityChanged?()
	}

	/// Resumes the warm player, taking its picture back when another host borrowed it.
	///
	/// - Returns: `true` if a warm player was resumed.
	private func resumeWarmPlayer() -> Bool {
		guard let webPlayer = self.webPlayer else { return false }

		if !webPlayer.isHosting(self) {
			webPlayer.attach(to: self, isMuted: self.isMuted, delegate: self)
		}

		webPlayer.setMuted(self.isMuted)
		webPlayer.play()
		return true
	}

	/// Plays the trailer through the pooled web player.
	///
	/// - Parameter videoID: The identifier of the trailer to play.
	private func startWebPlayback(forVideoID videoID: String) {
		let webPlayer = TrailerPlayerPool.shared.player(forVideoID: videoID)
		self.webPlayer = webPlayer

		webPlayer.attach(to: self, isMuted: self.isMuted, delegate: self)
		webPlayer.setLooping(self.loopsPlayback)
		webPlayer.streamMetadata = self.streamMetadata
		webPlayer.reportsNowPlaying = self.reportsNowPlaying

		if !self.loopsPlayback {
			TrailerAirPlayStreamer.shared.continueStream(with: webPlayer)
		}

		webPlayer.play()

		self.updateControls(animated: false)
		self.onPictureVisibilityChanged?()
	}

	/// Pauses the trailer while keeping its web player warm.
	private func pausePlayback() {
		self.controlsHideTask?.cancel()
		self.controlsHideTask = nil

		// The sound is deliberately left alone: pausing already silences the trailer, and keeping the
		// reader's choice means scrolling back resumes it exactly as they left it.
		self.webPlayer?.pause()
		self.clearNowPlayingReport()
		self.isPlaying = false
		self.areControlsVisible = false

		self.updateControls(animated: false)
	}

	/// Takes the trailer off the system's display, which only stands for a trailer the reader is on.
	private func clearNowPlayingReport() {
		guard let webPlayer = self.webPlayer else { return }
		TrailerNowPlayingReporter.shared.clear(for: webPlayer)
	}

	/// Toggles playback in response to the play or pause button.
	@objc private func togglePlayPause() {
		guard self.hasTrailer else { return }

		if self.isPlaying {
			self.isPausedByReader = true
			self.webPlayer?.pause()
		} else {
			self.isPausedByReader = false
			self.isReaderInitiated = true

			if !self.resumeWarmPlayer() {
				TrailerPlaybackCoordinator.shared.pin(self)
			}
		}

		self.updateControls(animated: true)
		self.scheduleControlsAutoHide()
	}

	/// Toggles the trailer's sound in response to the mute button.
	@objc private func toggleMute() {
		self.isMuted.toggle()
		self.webPlayer?.setMuted(self.isMuted)
		self.updateControls(animated: false)
		self.scheduleControlsAutoHide()

		if !self.isMuted {
			TrailerPlaybackCoordinator.shared.pin(self)
		}
	}

	/// Moves playback to the given point, keeping it inside the trailer.
	///
	/// - Parameter seconds: The point to play from.
	private func seek(to seconds: Double) {
		let target = self.duration > 0.0 ? min(max(0.0, seconds), self.duration) : max(0.0, seconds)

		self.elapsedTime = target
		self.seekSettleDate = Date().addingTimeInterval(0.5)
		self.webPlayer?.seek(to: target)
		self.updateProgressControls()
		self.scheduleControlsAutoHide()
	}

	/// Holds the timeline still while the reader takes the scrubber.
	@objc private func scrubbingDidBegin() {
		self.isScrubbing = true
		self.controlsHideTask?.cancel()
	}

	/// Previews the point the reader is dragging to.
	@objc private func scrubbingDidChange() {
		guard self.duration > 0.0 else { return }
		self.updateTimeLabels(forSeconds: Double(self.scrubber.value) * self.duration)
	}

	/// Plays from the point the reader dragged to.
	@objc private func scrubbingDidEnd() {
		self.isScrubbing = false

		if self.duration > 0.0 {
			self.seek(to: Double(self.scrubber.value) * self.duration)
		}

		self.scheduleControlsAutoHide()
	}

	/// Moves the scrubber and time labels to the current point.
	private func updateProgressControls() {
		self.updateTimeLabels(forSeconds: self.elapsedTime)

		guard !self.isScrubbing else { return }
		self.scrubber.value = self.duration > 0.0 ? Float(self.elapsedTime / self.duration) : 0.0
	}

	/// Shows the given point and the time left from it.
	///
	/// - Parameter seconds: The point in the timeline.
	private func updateTimeLabels(forSeconds seconds: Double) {
		self.elapsedTimeLabel.text = Self.timeText(forSeconds: seconds)
		self.remainingTimeLabel.text = "-" + Self.timeText(forSeconds: max(0.0, self.duration - seconds))
	}

	#if targetEnvironment(macCatalyst)
	/// Opens the trailer in a floating window.
	@objc private func requestPictureInPicture() {
		self.sendPagePress { [weak self] in
			self?.webPlayer?.requestPictureInPicture()
		}
	}

	/// Clears the overlay out of the synthesized press's way, then sends it.
	///
	/// - Parameter press: The closure that presses through to the page.
	private func sendPagePress(_ press: () -> Void) {
		self.isSendingPagePress = true
		self.areControlsVisible = false
		self.updateControls(animated: false)

		// The tap layer steps out of hit testing so the synthesized press reaches the page.
		self.tapControl.isUserInteractionEnabled = false
		press()

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
			guard let self = self else { return }
			self.isSendingPagePress = false
			self.updateControls(animated: false)
		}
	}
	#endif

	/// Opens the trailer fullscreen in response to the fullscreen button.
	@objc private func enterFullscreen() {
		guard let owningViewController = self.owningViewController, let videoID = self.videoID else { return }

		// Fullscreen means the reader wants to watch, so the sound comes on.
		let fullscreenViewController = TrailerFullscreenViewController(videoID: videoID, isMuted: false, resumesPlayback: self.isTrailerPlaying)
		fullscreenViewController.sourceFrame = self.window.map { self.convert(self.bounds, to: $0) }
		fullscreenViewController.sourceTrailerView = self
		fullscreenViewController.shareHandler = self.shareHandler

		if !self.loopsPlayback {
			fullscreenViewController.advanceHandler = { [weak self] in
				guard let self = self else { return nil }
				let previousVideoID = self.videoID
				self.onPlaybackEnded?()
				guard let videoID = self.videoID, videoID != previousVideoID else { return nil }

				// The next trailer's player is adopted here, so closing fullscreen hands it back in place.
				let webPlayer = TrailerPlayerPool.shared.player(forVideoID: videoID)
				self.webPlayer = webPlayer
				return webPlayer
			}
		}
		// Keeps the page behind the trailer on screen, so the zoom grows out of it.
		fullscreenViewController.modalPresentationStyle = .overFullScreen
		fullscreenViewController.transitioningDelegate = fullscreenViewController

		#if targetEnvironment(macCatalyst)
		// The system's own window expansion is the enter transition.
		if !MacWindowFullscreen.isFullscreen {
			fullscreenViewController.didEnterMacFullscreen = true
			MacWindowFullscreen.toggle()
			owningViewController.present(fullscreenViewController, animated: false)
			return
		}
		#endif

		owningViewController.present(fullscreenViewController, animated: true)
	}

	/// Reveals the controls while the pointer rests on the trailer.
	///
	/// - Parameter gesture: The pointer movement being followed.
	@objc private func handlePointerHover(_ gesture: UIHoverGestureRecognizer) {
		guard self.showsCompactControls, self.hasTrailer, self.showsControls, !self.isSendingPagePress else { return }

		switch gesture.state {
		case .began, .changed:
			let location = gesture.location(in: self)

			// A press wiggles the pointer, and revealing on that would fight the press's own toggle.
			if let lastPointerLocation = self.lastPointerLocation, abs(location.x - lastPointerLocation.x) < 2.0, abs(location.y - lastPointerLocation.y) < 2.0 {
				return
			}

			self.lastPointerLocation = location

			if !self.areControlsVisible {
				self.areControlsVisible = true
				self.updateControls(animated: true)
			}

			self.scheduleControlsAutoHide()
		case .ended, .cancelled, .failed:
			self.lastPointerLocation = nil

			guard self.isPlaying, self.areControlsVisible else { return }
			self.areControlsVisible = false
			self.updateControls(animated: true)
		default:
			break
		}
	}

	/// Keeps the revealed controls up after a press on a bar's open stretch.
	@objc private func keepControlsVisible() {
		self.scheduleControlsAutoHide()
	}

	/// Applies the glyph sizes for the current control style.
	private func applyControlGlyphs() {
		let pointSize: CGFloat = self.showsCompactControls ? 24.0 : 17.0
		let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.playPauseButton.configuration?.preferredSymbolConfigurationForImage = symbolConfiguration
		} else {
			self.playPauseButton.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)
		}
	}

	/// Lets go of the held picture.
	///
	/// - Parameter animated: Whether the picture fades out.
	private func clearTransitionSnapshot(animated: Bool) {
		guard let transitionSnapshotView = self.transitionSnapshotView else { return }
		self.transitionSnapshotView = nil

		guard animated else {
			transitionSnapshotView.removeFromSuperview()
			return
		}

		UIView.animate(withDuration: 0.25, animations: {
			transitionSnapshotView.alpha = 0.0
		}, completion: { _ in
			transitionSnapshotView.removeFromSuperview()
		})
	}

	/// Reveals or hides the controls in response to a tap.
	@objc private func handleSingleTap() {
		guard !self.isSendingPagePress else { return }

		self.toggleControlsVisibility()
	}

	/// Opens the trailer fullscreen in response to a double tap.
	@objc private func handleDoubleTap() {
		guard self.hasTrailer else { return }
		self.enterFullscreen()
	}

	/// Reveals or hides the controls in response to a tap on the trailer.
	private func toggleControlsVisibility() {
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

		let chromeIsVisible = self.showsCompactControls && overlayIsVisible && self.isShowingPicture
		let secondaryIsVisible: Bool
		let muteIsVisible: Bool

		if self.showsCompactControls {
			secondaryIsVisible = chromeIsVisible && self.showsSecondaryControls
			muteIsVisible = secondaryIsVisible || (self.isPlaying && self.showsMuteToggle && self.showsControls && self.showsSecondaryControls)
		} else {
			muteIsVisible = self.isPlaying && (self.showsMuteToggle || self.areControlsVisible) && self.showsControls && self.showsSecondaryControls
			secondaryIsVisible = self.isPlaying && self.areControlsVisible && self.showsControls && self.showsSecondaryControls
		}

		let isStreamingExternally = TrailerAirPlayStreamer.shared.isStreaming(from: self.webPlayer)
		self.airPlayNoticeView.isHidden = !isStreamingExternally

		if isStreamingExternally {
			self.airPlayNoticeView.refresh()
		}

		self.playPauseButton.setImage(UIImage(systemName: self.isPlaying ? "pause.fill" : "play.fill"), for: .normal)
		self.playPauseButton.accessibilityLabel = self.isPlaying ? L10n.pause : L10n.play
		self.muteButton.setImage(UIImage(systemName: self.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"), for: .normal)
		self.muteButton.accessibilityLabel = self.isMuted ? L10n.unmute : L10n.mute

		self.tapControl.isUserInteractionEnabled = self.hasTrailer && self.showsControls
		self.playPauseButton.isUserInteractionEnabled = overlayIsVisible
		self.timeBarView.isUserInteractionEnabled = chromeIsVisible
		self.muteButton.isUserInteractionEnabled = muteIsVisible
		self.fullscreenButton.isUserInteractionEnabled = secondaryIsVisible
		self.outputGroupView.isUserInteractionEnabled = chromeIsVisible && secondaryIsVisible

		let apply = {
			self.scrimView.alpha = chromeIsVisible ? 1.0 : 0.0
			self.playPauseButton.alpha = overlayIsVisible ? 1.0 : 0.0
			self.timeBarView.alpha = chromeIsVisible ? 1.0 : 0.0
			self.muteButton.alpha = muteIsVisible ? 1.0 : 0.0
			self.fullscreenButton.alpha = secondaryIsVisible ? 1.0 : 0.0
			self.outputGroupView.alpha = chromeIsVisible && secondaryIsVisible ? 1.0 : 0.0
		}

		if animated {
			UIView.animate(withDuration: 0.25, animations: apply)
		} else {
			apply()
		}
	}

	/// Resumes playback when the app returns to the foreground.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc private func handleApplicationDidBecomeActive(_ notification: Notification) {
		guard self.window != nil, self.isPlaybackAllowed, !self.isPausedByReader else { return }
		self.webPlayer?.play()
	}

	/// Pins the controls above the trailer.
	private func configureControls() {
		self.tapControl.addTarget(self, action: #selector(self.handleSingleTap), for: .touchUpInside)

		let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap))
		doubleTapGesture.numberOfTapsRequired = 2
		// Holding taps back until a double is ruled out makes the toggle feel unresponsive.
		doubleTapGesture.delaysTouchesEnded = false
		self.tapControl.addGestureRecognizer(doubleTapGesture)
		self.playPauseButton.addTarget(self, action: #selector(self.togglePlayPause), for: .primaryActionTriggered)
		self.muteButton.addTarget(self, action: #selector(self.toggleMute), for: .primaryActionTriggered)
		self.fullscreenButton.addTarget(self, action: #selector(self.enterFullscreen), for: .primaryActionTriggered)

		let hoverGesture = UIHoverGestureRecognizer(target: self, action: #selector(self.handlePointerHover(_:)))
		self.addGestureRecognizer(hoverGesture)

		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidBegin), for: [.touchDown])
		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidChange), for: [.valueChanged])
		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])

		self.fullscreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
		self.fullscreenButton.accessibilityLabel = L10n.fullscreen

		// The bars' content sits inside backing controls, so presses on their open stretches never
		// fall through to the cell's selection.
		let outputBackingControl = KTrailerPlayerView.makeBarBackingControl()
		let timeBarBackingControl = KTrailerPlayerView.makeBarBackingControl()
		outputBackingControl.addTarget(self, action: #selector(self.keepControlsVisible), for: .touchUpInside)
		timeBarBackingControl.addTarget(self, action: #selector(self.keepControlsVisible), for: .touchUpInside)
		self.outputGroupView.contentView.addSubview(outputBackingControl)
		self.timeBarView.contentView.addSubview(timeBarBackingControl)

		timeBarBackingControl.addSubview(self.elapsedTimeLabel)
		timeBarBackingControl.addSubview(self.scrubber)
		timeBarBackingControl.addSubview(self.remainingTimeLabel)

		var groupConstraints = [
			outputBackingControl.topAnchor.constraint(equalTo: self.outputGroupView.contentView.topAnchor),
			outputBackingControl.leadingAnchor.constraint(equalTo: self.outputGroupView.contentView.leadingAnchor),
			outputBackingControl.trailingAnchor.constraint(equalTo: self.outputGroupView.contentView.trailingAnchor),
			outputBackingControl.bottomAnchor.constraint(equalTo: self.outputGroupView.contentView.bottomAnchor),

			timeBarBackingControl.topAnchor.constraint(equalTo: self.timeBarView.contentView.topAnchor),
			timeBarBackingControl.leadingAnchor.constraint(equalTo: self.timeBarView.contentView.leadingAnchor),
			timeBarBackingControl.trailingAnchor.constraint(equalTo: self.timeBarView.contentView.trailingAnchor),
			timeBarBackingControl.bottomAnchor.constraint(equalTo: self.timeBarView.contentView.bottomAnchor),

			self.elapsedTimeLabel.leadingAnchor.constraint(equalTo: timeBarBackingControl.leadingAnchor, constant: 14.0),
			self.elapsedTimeLabel.centerYAnchor.constraint(equalTo: timeBarBackingControl.centerYAnchor),

			self.scrubber.leadingAnchor.constraint(equalTo: self.elapsedTimeLabel.trailingAnchor, constant: 10.0),
			self.scrubber.trailingAnchor.constraint(equalTo: self.remainingTimeLabel.leadingAnchor, constant: -10.0),
			self.scrubber.centerYAnchor.constraint(equalTo: timeBarBackingControl.centerYAnchor),

			self.remainingTimeLabel.trailingAnchor.constraint(equalTo: timeBarBackingControl.trailingAnchor, constant: -14.0),
			self.remainingTimeLabel.centerYAnchor.constraint(equalTo: timeBarBackingControl.centerYAnchor)
		]

		self.airPlayRoutePickerView.delegate = self
		self.airPlayRoutePickerView.accessibilityLabel = L10n.airPlay
		outputBackingControl.addSubview(self.airPlayRoutePickerView)

		groupConstraints.append(contentsOf: [
			self.airPlayRoutePickerView.trailingAnchor.constraint(equalTo: outputBackingControl.trailingAnchor, constant: -8.0),
			self.airPlayRoutePickerView.centerYAnchor.constraint(equalTo: outputBackingControl.centerYAnchor),
			self.airPlayRoutePickerView.widthAnchor.constraint(equalToConstant: 22.0),
			self.airPlayRoutePickerView.heightAnchor.constraint(equalToConstant: 12.0)
		])

		#if targetEnvironment(macCatalyst)
		self.pictureInPictureButton.addTarget(self, action: #selector(self.requestPictureInPicture), for: .primaryActionTriggered)
		self.pictureInPictureButton.accessibilityLabel = L10n.pictureInPicture
		outputBackingControl.addSubview(self.pictureInPictureButton)

		groupConstraints.append(contentsOf: [
			self.pictureInPictureButton.leadingAnchor.constraint(equalTo: outputBackingControl.leadingAnchor, constant: 6.0),
			self.pictureInPictureButton.centerYAnchor.constraint(equalTo: outputBackingControl.centerYAnchor),
			self.pictureInPictureButton.widthAnchor.constraint(equalToConstant: 30.0),
			self.pictureInPictureButton.heightAnchor.constraint(equalToConstant: 24.0),

			self.airPlayRoutePickerView.leadingAnchor.constraint(equalTo: self.pictureInPictureButton.trailingAnchor, constant: 4.0)
		])
		#else
		groupConstraints.append(
			self.airPlayRoutePickerView.leadingAnchor.constraint(equalTo: outputBackingControl.leadingAnchor, constant: 8.0)
		)
		#endif

		NSLayoutConstraint.activate(groupConstraints)

		self.updateProgressControls()

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

		self.mountControls(in: host)
	}

	/// Rebuilds the controls' layout in their current host.
	private func remountControls() {
		self.mountControls(in: self.playPauseButton.superview ?? self)
	}

	/// Places the controls in the given host under the current control style.
	///
	/// - Parameter host: The view that holds the controls.
	private func mountControls(in host: UIView) {
		NSLayoutConstraint.deactivate(self.controlConstraints)

		// The notice stays inside the picture's own bounds, under any chrome laid over the player.
		self.addSubview(self.airPlayNoticeView)
		host.addSubview(self.scrimView)
		host.addSubview(self.playPauseButton)
		host.addSubview(self.fullscreenButton)
		host.addSubview(self.outputGroupView)
		host.addSubview(self.muteButton)
		host.addSubview(self.timeBarView)

		self.controlConstraints = [
			self.airPlayNoticeView.topAnchor.constraint(equalTo: self.topAnchor),
			self.airPlayNoticeView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.airPlayNoticeView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.airPlayNoticeView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			self.scrimView.topAnchor.constraint(equalTo: self.topAnchor),
			self.scrimView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.scrimView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.scrimView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			self.playPauseButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.playPauseButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.playPauseButton.widthAnchor.constraint(equalToConstant: 44.0),
			self.playPauseButton.heightAnchor.constraint(equalToConstant: 44.0),

			self.muteButton.widthAnchor.constraint(equalToConstant: 30.0),
			self.muteButton.heightAnchor.constraint(equalToConstant: 30.0),

			self.fullscreenButton.widthAnchor.constraint(equalToConstant: 30.0),
			self.fullscreenButton.heightAnchor.constraint(equalToConstant: 30.0),

			self.outputGroupView.leadingAnchor.constraint(equalTo: self.fullscreenButton.trailingAnchor, constant: 8.0),
			self.outputGroupView.centerYAnchor.constraint(equalTo: self.fullscreenButton.centerYAnchor),
			self.outputGroupView.heightAnchor.constraint(equalToConstant: 30.0),

			self.timeBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
			self.timeBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
			self.timeBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12.0),
			self.timeBarView.heightAnchor.constraint(equalToConstant: 40.0)
		]

		if self.showsCompactControls {
			self.controlConstraints.append(contentsOf: [
				self.fullscreenButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 12.0),
				self.fullscreenButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),

				self.muteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 12.0),
				self.muteButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0)
			])
		} else {
			self.controlConstraints.append(contentsOf: [
				self.fullscreenButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
				self.fullscreenButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12.0),

				self.muteButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
				self.muteButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12.0)
			])
		}

		NSLayoutConstraint.activate(self.controlConstraints)
	}

	/// Builds a circular control button matching the platform's own media controls.
	///
	/// - Parameters:
	///    - pointSize: The point size of the button's symbol.
	///    - diameter: The button's diameter.
	///
	/// - Returns: A configured button.
	private static func makeControlButton(pointSize: CGFloat, diameter: CGFloat) -> AdaptiveCornerButton {
		let button = AdaptiveCornerButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.alpha = 0.0

		// Media controls stay put instead of following the picture: the glass is left untinted, and a
		// fixed dark appearance stops it from flipping light and dark as the video plays under it.
		button.overrideUserInterfaceStyle = .dark

		let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .semibold)

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			button.configuration = .clearGlass()
			button.configuration?.preferredSymbolConfigurationForImage = symbolConfiguration
			button.configuration?.baseForegroundColor = .white
		} else {
			button.tintColor = .white
			button.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)
			button.addBlurEffect(style: .dark, cornerRadius: diameter / 2.0)
		}

		button.cornerStyle = .capsule
		return button
	}

	/// Builds a translucent capsule that backs a group of controls.
	///
	/// - Parameter cornerRadius: The capsule's corner radius.
	///
	/// - Returns: A configured effect view.
	private static func makeControlBar(cornerRadius: CGFloat) -> UIVisualEffectView {
		let effectView = UIVisualEffectView()

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			effectView.effect = UIGlassEffect()
		} else {
			effectView.effect = UIBlurEffect(style: .systemThickMaterialDark)
		}

		effectView.translatesAutoresizingMaskIntoConstraints = false
		effectView.overrideUserInterfaceStyle = .dark
		effectView.clipsToBounds = true
		effectView.layer.cornerCurve = .continuous
		effectView.layerCornerRadius = cornerRadius
		effectView.alpha = 0.0
		return effectView
	}

	/// Builds a borderless glyph button shown inside a control capsule.
	///
	/// - Parameter systemName: The name of the button's symbol.
	///
	/// - Returns: A configured button.
	private static func makeGroupedGlyphButton(systemName: String) -> UIButton {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false

		// Left to itself the Mac renders the button natively, bordered and dropping the glyph once
		// a menu is attached. `KButton` pins the same style for the same reason.
		button.preferredBehavioralStyle = .pad

		button.tintColor = .white
		button.setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 9.0, weight: .semibold)), for: .normal)
		return button
	}

	/// Builds the control that takes presses on a bar's open stretches.
	///
	/// - Returns: A configured control.
	private static func makeBarBackingControl() -> UIControl {
		let control = UIControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		return control
	}

	/// Builds a label for a point in the trailer's timeline.
	///
	/// - Returns: A configured label.
	private static func makeTimeLabel() -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .monospacedDigitSystemFont(ofSize: 12.0, weight: .medium)
		label.textColor = .white
		return label
	}

	/// Returns the given point in the timeline written for display.
	///
	/// - Parameter seconds: The point in the timeline.
	///
	/// - Returns: The point written as minutes and seconds, gaining an hours field when needed.
	private static func timeText(forSeconds seconds: Double) -> String {
		guard seconds.isFinite, seconds >= 0.0 else { return "0:00" }

		let totalSeconds = Int(seconds.rounded(.down))
		let hours = totalSeconds / 3600
		let minutes = (totalSeconds % 3600) / 60
		let remainingSeconds = totalSeconds % 60

		if hours > 0 {
			return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
		}

		return String(format: "%d:%02d", minutes, remainingSeconds)
	}

	#if targetEnvironment(macCatalyst)
	/// Colors the hosted AppKit slider's filled track.
	private func applyTrackFill() {
		guard !self.didApplyTrackFill, let appKitSlider = self.hostedAppKitSlider() else { return }

		let selector = NSSelectorFromString(#obfuscated("setTrackFillColor:"))
		guard
			appKitSlider.responds(to: selector),
			let colorClass = NSClassFromString("NSColor") as? NSObject.Type,
			let whiteColor = colorClass.perform(NSSelectorFromString("whiteColor"))?.takeUnretainedValue()
		else { return }

		appKitSlider.perform(selector, with: whiteColor)
		self.didApplyTrackFill = true
	}

	/// Returns the AppKit control the scrubber hosts.
	///
	/// - Returns: The hosted control.
	private func hostedAppKitSlider() -> NSObject? {
		let contentKey = #obfuscated("contentNSView")
		var candidates: [UIView] = [self.scrubber]

		while let view = candidates.popLast() {
			if view.responds(to: NSSelectorFromString(contentKey)), let hosted = view.value(forKey: contentKey) as? NSObject {
				return hosted
			}
			candidates.append(contentsOf: view.subviews)
		}

		return nil
	}
	#endif
}

// MARK: - AVRoutePickerViewDelegate
extension KTrailerPlayerView: AVRoutePickerViewDelegate {
	func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
		TrailerAirPlayStreamer.shared.arm(with: self.webPlayer, for: routePickerView)
	}

	func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
		TrailerAirPlayStreamer.shared.probe()
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
		self.clearTransitionSnapshot(animated: false)
		self.webPlayer?.detach()
		self.webPlayer = nil
		self.isPlaying = false
		self.updateControls(animated: false)
		self.onPictureVisibilityChanged?()
	}

	func trailerWebPlayerDidRevealPicture(_ trailerWebPlayer: TrailerWebPlayer) {
		self.clearTransitionSnapshot(animated: true)
		self.updateControls(animated: true)
		self.onPictureVisibilityChanged?()
	}

	func trailerWebPlayerDidReachEnd(_ trailerWebPlayer: TrailerWebPlayer) {
		self.seekSettleDate = Date().addingTimeInterval(5.0)

		let endedVideoID = self.videoID
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			// The trailer ends short of its reported length, so the last stretch sweeps closed
			// instead of jumping, then holds a beat.
			let step = max(0.05, (self.duration - self.elapsedTime) / 12.0)
			while self.videoID == endedVideoID, self.elapsedTime < self.duration {
				self.elapsedTime = min(self.duration, self.elapsedTime + step)
				self.updateProgressControls()
				try? await Task.sleep(nanoseconds: 40_000_000)
			}

			try? await Task.sleep(nanoseconds: 400_000_000)
			guard self.videoID == endedVideoID else { return }
			self.onPlaybackEnded?()
		}
	}

	func trailerWebPlayer(_ trailerWebPlayer: TrailerWebPlayer, didPlayTo currentTime: Double, duration: Double) {
		let isAwaitingSeek = self.seekSettleDate.map { $0 > Date() } ?? false
		guard !self.isScrubbing, !isAwaitingSeek else { return }

		self.elapsedTime = currentTime
		self.duration = duration
		self.updateProgressControls()
	}
}
