//
//  TrailerFullscreenViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import AVKit
import MediaAccessibility
import SwiftTheme
import UIKit

/// A modal that plays a trailer fullscreen, reusing the trailer's warm player.
final class TrailerFullscreenViewController: UIViewController {
	// MARK: - Views
	/// The backdrop behind the player, faded in as the trailer zooms up.
	let backdropView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .black
		return view
	}()

	/// The window the trailer is cropped to while it zooms.
	let zoomWindowView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		view.clipsToBounds = true
		return view
	}()

	/// The view that zooms and pans the picture.
	let zoomScrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.backgroundColor = .clear
		scrollView.minimumZoomScale = 1.0
		scrollView.maximumZoomScale = 4.0
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.contentInsetAdjustmentBehavior = .never
		return scrollView
	}()

	/// The view hosting the player.
	let contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}()

	/// The notice covering the picture while the trailer plays on an AirPlay device.
	private let airPlayNoticeView = TrailerAirPlayNoticeView()

	/// The button that dismisses the fullscreen player.
	private let closeButton = TrailerFullscreenViewController.makeEdgeButton()

	#if targetEnvironment(macCatalyst)
	/// The floating bar the Mac drives playback from.
	private let controlBar = TrailerPlayerControlBar()
	#else
	/// The capsule grouping the floating window and AirPlay controls.
	private let outputGroupView = TrailerFullscreenViewController.makeGlassCapsule()

	/// The button that opens the trailer in a floating window.
	private let pictureInPictureButton = TrailerFullscreenViewController.makeGlyphButton(systemName: "pip.enter")

	/// The control that picks the AirPlay device the trailer plays on.
	private let airPlayRoutePickerView: AVRoutePickerView = {
		let routePickerView = AVRoutePickerView()
		routePickerView.translatesAutoresizingMaskIntoConstraints = false
		routePickerView.tintColor = .white
		routePickerView.activeTintColor = .white
		routePickerView.prioritizesVideoDevices = true
		return routePickerView
	}()

	/// The control that sets the volume.
	private let volumeControl = TrailerVolumeControl(diameter: 44.0)

	/// The veil dimming the picture while the controls are out.
	private let dimmingView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
		view.isUserInteractionEnabled = false
		return view
	}()

	/// The button that plays or pauses the trailer.
	private let playPauseButton = TrailerFullscreenViewController.makeControlButton(pointSize: 34.0, diameter: 96.0)

	/// The button that jumps back through the trailer.
	private let skipBackwardButton = TrailerFullscreenViewController.makeControlButton(pointSize: 26.0, diameter: 60.0)

	/// The button that jumps forward through the trailer.
	private let skipForwardButton = TrailerFullscreenViewController.makeControlButton(pointSize: 26.0, diameter: 60.0)

	/// The button showing the remaining options.
	private let optionsButton = TrailerFullscreenViewController.makeEdgeButton()

	/// The capsule carrying the timeline.
	private let timelineBarView: UIVisualEffectView = {
		let effectView = UIVisualEffectView()
		effectView.translatesAutoresizingMaskIntoConstraints = false
		effectView.overrideUserInterfaceStyle = .dark
		effectView.clipsToBounds = true
		effectView.layer.cornerCurve = .continuous

		if #available(iOS 26.0, *) {
			effectView.effect = UIGlassEffect()
			effectView.cornerConfiguration = .capsule()
		} else {
			effectView.effect = UIBlurEffect(style: .systemThickMaterialDark)
		}

		return effectView
	}()

	/// The slider that scrubs through the trailer.
	private let scrubber: UISlider = {
		let slider = UISlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.overrideUserInterfaceStyle = .dark
		slider.minimumTrackTintColor = .white
		slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
		slider.minimumValue = 0.0
		slider.maximumValue = 1.0
		slider.setContentHuggingPriority(.init(1.0), for: .horizontal)

		if #available(iOS 26.0, *) {
			slider.sliderStyle = .thumbless
		}

		return slider
	}()

	/// The label showing how far the trailer has played.
	private let elapsedTimeLabel = TrailerFullscreenViewController.makeTimeLabel()

	/// The label showing how much of the trailer is left.
	private let remainingTimeLabel = TrailerFullscreenViewController.makeTimeLabel()
	#endif

	// MARK: - Properties
	/// The frame the trailer occupies on the page, in window coordinates.
	var sourceFrame: CGRect?

	/// The view the trailer came from, which takes its player back on dismissal.
	weak var sourceTrailerView: KTrailerPlayerView?

	/// Shares what the trailer belongs to, from the given view.
	var shareHandler: ((UIView) -> Void)?

	/// Returns the next trailer's player once the queue advances.
	var advanceHandler: (() -> TrailerWebPlayer?)?

	/// The controls that fade in once the trailer fills the screen.
	var chromeViews: [UIView] {
		#if targetEnvironment(macCatalyst)
		return [self.closeButton, self.controlBar]
		#else
		return [self.dimmingView, self.closeButton, self.outputGroupView, self.volumeControl, self.skipBackwardButton, self.playPauseButton, self.skipForwardButton, self.optionsButton, self.timelineBarView]
		#endif
	}

	#if !targetEnvironment(macCatalyst)
	/// The controls along the top edge.
	private var topChromeViews: [UIView] {
		return [self.closeButton, self.outputGroupView, self.volumeControl]
	}

	/// The controls along the bottom edge.
	private var bottomChromeViews: [UIView] {
		return [self.optionsButton, self.timelineBarView]
	}
	#endif

	/// The seconds a skip button moves through the trailer.
	private let skipInterval = 10.0

	/// The speeds the trailer can play at.
	private let playbackRates: [Double] = [0.5, 1.0, 1.25, 1.5, 2.0]

	/// The speed the trailer is playing at.
	private var playbackRate = 1.0

	/// The seconds played so far.
	private var elapsedTime = 0.0

	/// The trailer's length in seconds.
	private var duration = 0.0

	/// A Boolean value indicating whether the reader is dragging the scrubber.
	private var isScrubbing = false

	/// A Boolean value indicating whether the trailer was playing before a swipe scrub began.
	private var wasPlayingBeforeScrub = false

	/// A Boolean value indicating whether the transient controls are on screen.
	private var areControlsVisible = true

	#if !targetEnvironment(macCatalyst)
	/// The helper that rotates the player when the device turns under the system's rotation lock.
	private lazy var portraitLockBuddy = PortraitLockBuddy(viewController: self)

	/// The drag that carries the trailer off the screen.
	private lazy var dismissGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDismissDrag(_:)))

	/// A Boolean value indicating whether a drag is carrying the trailer towards dismissal.
	private var isDraggingToDismiss = false

	/// The distance a drag travels before the backdrop is fully transparent.
	private var dismissDragDistance: CGFloat = 1.0
	#endif

	/// The length of the dismissal animation.
	private var dismissDuration = 0.4

	#if targetEnvironment(macCatalyst)
	/// A Boolean value indicating whether the pointer last rested over the control bar.
	private var isPointerOverControls = false

	/// A Boolean value indicating whether a synthesized press is on its way into the page.
	private var isSendingPagePress = false

	/// A Boolean value indicating whether the current swipe belongs to the volume.
	private var isAdjustingVolume = false

	/// A Boolean value indicating whether this player put the window into the Mac's fullscreen.
	var didEnterMacFullscreen = false

	/// The observer following the window back out of the Mac's fullscreen.
	private var macFullscreenObserver: NSObjectProtocol?

	/// The observer following the window into the Mac's fullscreen.
	private var macFullscreenEnterObserver: NSObjectProtocol?
	#endif

	/// A Boolean value indicating whether the keyboard is running the trailer fast.
	private var isKeyboardFastSeeking = false

	/// The place the pointer was last seen, which tells real movement from event noise.
	private var lastPointerLocation: CGPoint?

	/// The time the controls were last brought back by pointer movement rather than a press.
	private var pointerRevealDate: Date?

	/// The time the player's reported point is trusted again after a seek.
	private var seekSettleDate: Date?

	/// A Boolean value indicating whether the trailer was playing before a seek button was held.
	private var wasPlayingBeforeFastSeek = false

	/// A Boolean value indicating whether a held seek button runs the trailer forwards.
	private var isFastSeekingForward = true

	/// A Boolean value indicating whether a fast seek is in progress.
	private var isFastSeeking = false

	/// The speeds a held seek button climbs through.
	private let fastSeekRates: [Double] = [2.0, 5.0, 10.0, 30.0, 60.0]

	/// The speed a held seek button has climbed to.
	private var fastSeekRateIndex = 0

	/// The rung the ladder starts on, set when a seek button is first held.
	private var fastSeekBaseIndex = 0

	/// The task carrying a flicked scrub to a stop.
	private var scrubGlideTask: Task<Void, Never>?

	/// The frames the trailer shows each second, once it can be worked out.
	private var framesPerSecond: Double?

	/// A Boolean value indicating whether the player has been dismissed.
	private var hasLeftScreen = false

	#if targetEnvironment(macCatalyst)
	/// The monitor that handles the Escape key ahead of the responder chain.
	private var escapeMonitor: MacKeyDownMonitor?
	#endif

	/// The identifier of the trailer to play.
	private var videoID: String

	/// The player rendering the trailer.
	private var player: TrailerWebPlayer?

	/// A Boolean value indicating whether the trailer's sound is off.
	private var isMuted: Bool

	/// A Boolean value indicating whether the trailer was playing on the page.
	private let resumesPlayback: Bool

	/// A Boolean value indicating whether the trailer is playing.
	private var isPlaying = false

	/// The task that hides the controls after a period of inactivity.
	private var controlsHideTask: Task<Void, Never>?

	override var prefersStatusBarHidden: Bool {
		#if targetEnvironment(macCatalyst)
		return true
		#else
		return !self.areControlsVisible
		#endif
	}

	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .fade
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		#if targetEnvironment(macCatalyst)
		return .allButUpsideDown
		#else
		return self.portraitLockBuddy.forcedOrientation ?? .allButUpsideDown
		#endif
	}

	override var shouldAutorotate: Bool {
		return UserSettings.isPortraitLockBuddyEnabled || UserSettings.isSmartRotationLockEnabled
	}

	override var keyCommands: [UIKeyCommand]? {
		guard !self.hasLeftScreen else { return nil }

		let commands = [
			UIKeyCommand(action: #selector(self.close), input: UIKeyCommand.inputEscape),
			UIKeyCommand(action: #selector(self.close), input: "f", modifierFlags: .command),
			UIKeyCommand(action: #selector(self.togglePlayPause), input: " "),
			UIKeyCommand(action: #selector(self.stepBackward), input: UIKeyCommand.inputLeftArrow),
			UIKeyCommand(action: #selector(self.stepForward), input: UIKeyCommand.inputRightArrow),
			UIKeyCommand(action: #selector(self.keyboardRewind), input: UIKeyCommand.inputLeftArrow, modifierFlags: .command),
			UIKeyCommand(action: #selector(self.keyboardFastForward), input: UIKeyCommand.inputRightArrow, modifierFlags: .command),
			UIKeyCommand(action: #selector(self.jumpToBeginning), input: UIKeyCommand.inputLeftArrow, modifierFlags: .alternate),
			UIKeyCommand(action: #selector(self.jumpToEnd), input: UIKeyCommand.inputRightArrow, modifierFlags: .alternate),
			UIKeyCommand(action: #selector(self.increaseVolume), input: UIKeyCommand.inputUpArrow),
			UIKeyCommand(action: #selector(self.decreaseVolume), input: UIKeyCommand.inputDownArrow),
			UIKeyCommand(action: #selector(self.maximizeVolume), input: UIKeyCommand.inputUpArrow, modifierFlags: .alternate),
			UIKeyCommand(action: #selector(self.muteVolume), input: UIKeyCommand.inputDownArrow, modifierFlags: .alternate),
			UIKeyCommand(action: #selector(self.zoomIn), input: "+", modifierFlags: .command),
			// The plus lives on the equals key. Both readings work, shifted or not.
			UIKeyCommand(action: #selector(self.zoomIn), input: "=", modifierFlags: .command),
			UIKeyCommand(action: #selector(self.zoomOut), input: "-", modifierFlags: .command),
			UIKeyCommand(action: #selector(self.zoomActualSize), input: "0", modifierFlags: .command),
			UIKeyCommand(action: #selector(self.togglePictureInPicture), input: "p", modifierFlags: [.command, .alternate]),
			UIKeyCommand(action: #selector(self.goToTimestamp), input: "k", modifierFlags: [.command, .shift]),
			UIKeyCommand(action: #selector(self.goToFrame), input: "i", modifierFlags: [.command, .shift])
		]

		// The arrows and space belong to the player here, not to focus movement or scrolling.
		commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
		return commands
	}

	override var canBecomeFirstResponder: Bool {
		return true
	}

	// MARK: - Initializers
	init(videoID: String, isMuted: Bool, resumesPlayback: Bool) {
		self.videoID = videoID
		self.isMuted = isMuted
		self.resumesPlayback = resumesPlayback
		super.init(nibName: nil, bundle: nil)

		#if !targetEnvironment(macCatalyst)
		self.modalPresentationCapturesStatusBarAppearance = true
		#endif
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

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		#if !targetEnvironment(macCatalyst)
		if #unavailable(iOS 26.0) {
			self.timelineBarView.layer.cornerRadius = self.timelineBarView.bounds.height / 2.0
			self.outputGroupView.layer.cornerRadius = self.outputGroupView.bounds.height / 2.0
		}

		self.zoomScrollView.maximumZoomScale = max(4.0, self.fillZoomScale() * 2.0)
		#endif
	}

	#if !targetEnvironment(macCatalyst)
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		self.portraitLockBuddy.settle(with: coordinator)
	}
	#endif

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		TrailerPlaybackCoordinator.shared.beginFullscreen()

		// Attached before the zoom runs, so the trailer is on screen as it grows.
		let player = self.sourceTrailerView?.hostedWebPlayer ?? TrailerPlayerPool.shared.player(forVideoID: self.videoID)
		self.player = player
		player.attach(to: self.contentView, isMuted: self.isMuted, delegate: self)

		// Without a queue to advance, fullscreen keeps the trailer running on its own. The host it
		// came from restores its looping choice when it takes the player back.
		player.setLooping(self.advanceHandler == nil)

		if self.resumesPlayback {
			player.play()
		}

		self.isPlaying = self.resumesPlayback

		#if targetEnvironment(macCatalyst)
		// The paused frame's menu and the pressed-through controls both live in the page.
		player.setInteractionEnabled(true)
		#endif
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.becomeFirstResponder()
		self.updateControls(animated: false)
		self.scheduleControlsAutoHide()

		#if !targetEnvironment(macCatalyst)
		self.portraitLockBuddy.start()
		#endif

		#if targetEnvironment(macCatalyst)
		// The page's own web view takes Escape for itself, so it never reaches the chain.
		let escapeMonitor = MacKeyDownMonitor(keyCode: MacKeyDownMonitor.escapeKeyCode) { [weak self] in
			self?.close()
		}
		self.escapeMonitor = escapeMonitor
		escapeMonitor.start()

		// However the window leaves fullscreen, the player leaves with it.
		self.macFullscreenObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("NSWindowDidExitFullScreenNotification"), object: nil, queue: .main) { [weak self] _ in
			MainActor.assumeIsolated {
				guard let self = self else { return }
				self.didEnterMacFullscreen = false
				self.dismiss(animated: false)
			}
		}

		// The fullscreen transition clears the window's focus. It is taken back once settled.
		self.macFullscreenEnterObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("NSWindowDidEnterFullScreenNotification"), object: nil, queue: .main) { [weak self] _ in
			MainActor.assumeIsolated {
				_ = self?.becomeFirstResponder()
			}
		}

		if !self.didEnterMacFullscreen, !MacWindowFullscreen.isFullscreen {
			self.didEnterMacFullscreen = true
			MacWindowFullscreen.toggle()
		}
		#endif

		// A second claim, after presenting has finished handing focus around.
		DispatchQueue.main.async { [weak self] in
			_ = self?.becomeFirstResponder()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		guard self.isBeingDismissed else { return }

		// A dismissed controller keeps first responder, and the next player would find it taken.
		self.hasLeftScreen = true
		self.resignFirstResponder()

		#if !targetEnvironment(macCatalyst)
		self.portraitLockBuddy.restorePortrait()
		#endif

		#if targetEnvironment(macCatalyst)
		self.escapeMonitor?.stop()
		self.escapeMonitor = nil
		#endif
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		self.controlsHideTask?.cancel()
		self.controlsHideTask = nil

		#if !targetEnvironment(macCatalyst)
		self.portraitLockBuddy.stop()
		#endif

		#if targetEnvironment(macCatalyst)
		if let macFullscreenObserver = self.macFullscreenObserver {
			NotificationCenter.default.removeObserver(macFullscreenObserver)
			self.macFullscreenObserver = nil
		}

		if let macFullscreenEnterObserver = self.macFullscreenEnterObserver {
			NotificationCenter.default.removeObserver(macFullscreenEnterObserver)
			self.macFullscreenEnterObserver = nil
		}
		#endif

		// Handed straight back to the page, so the trailer carries on in place.
		#if targetEnvironment(macCatalyst)
		self.player?.setInteractionEnabled(false)
		#endif

		if let player = self.player {
			if let sourceTrailerView = self.sourceTrailerView {
				sourceTrailerView.reclaimPlayerFromFullscreen(player)
			} else {
				player.detach()
			}
		}

		self.player = nil
		TrailerPlaybackCoordinator.shared.endFullscreen()
	}

	// MARK: - Functions
	/// Dismisses the fullscreen player.
	@objc private func close() {
		// A close arriving after the player has left would hand the trailer back a second time.
		guard !self.hasLeftScreen else { return }

		// Let go of any pinch zoom before the zoom-back transforms the same host.
		self.zoomScrollView.setZoomScale(1.0, animated: false)

		#if targetEnvironment(macCatalyst)
		// The window's own contraction is the exit transition.
		if self.didEnterMacFullscreen, MacWindowFullscreen.isFullscreen {
			self.didEnterMacFullscreen = false
			MacWindowFullscreen.toggle()
			self.dismiss(animated: false)
			return
		}
		#else
		if self.portraitLockBuddy.restorePortrait() {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
				self?.dismiss(animated: true)
			}
			return
		}
		#endif

		self.dismiss(animated: true)
	}

	/// Toggles playback in response to the play or pause button.
	@objc func togglePlayPause() {
		if self.isKeyboardFastSeeking {
			self.endKeyboardFastSeek()
			return
		}

		if self.isPlaying {
			self.player?.pause()
		} else {
			self.player?.play()
		}

		self.updateControls(animated: true)
		self.scheduleControlsAutoHide()
	}

	/// Steps the paused trailer one frame back.
	@objc func stepBackward() {
		self.stepFrame(forward: false)
	}

	/// Steps the paused trailer one frame forward.
	@objc func stepForward() {
		self.stepFrame(forward: true)
	}

	/// Steps the paused trailer a single frame in the given direction.
	///
	/// - Parameter forward: Whether the trailer steps forwards.
	private func stepFrame(forward: Bool) {
		self.endKeyboardFastSeek()

		guard !self.isPlaying else { return }

		// A computed seek lands on whatever the stream allows, and each press cancels the last.
		if self.player?.stepFrames(forward ? 1 : -1) == true {
			self.seekSettleDate = nil
			return
		}

		let frameDuration = 1.0 / (self.framesPerSecond ?? 24.0)
		self.seek(to: self.elapsedTime + (forward ? frameDuration : -frameDuration))
	}

	/// Runs the trailer backwards from the keyboard, climbing a rung on each press.
	@objc func keyboardRewind() {
		self.keyboardFastSeek(forward: false)
	}

	/// Runs the trailer forwards from the keyboard, climbing a rung on each press.
	@objc func keyboardFastForward() {
		self.keyboardFastSeek(forward: true)
	}

	/// Runs the trailer fast in the given direction, climbing a rung when already running.
	///
	/// - Parameter forward: Whether the trailer runs forwards.
	private func keyboardFastSeek(forward: Bool) {
		if self.isKeyboardFastSeeking, self.isFastSeekingForward == forward {
			guard self.fastSeekRateIndex + 1 < self.fastSeekRates.count else { return }

			self.fastSeekRateIndex += 1
			self.runFastSeek()
			return
		}

		// Switching direction keeps the play state from before the whole fast run.
		if !self.isKeyboardFastSeeking {
			self.wasPlayingBeforeFastSeek = self.isPlaying
		}

		self.isKeyboardFastSeeking = true
		self.isFastSeekingForward = forward
		self.isFastSeeking = true
		self.fastSeekBaseIndex = self.fastSeekRates.firstIndex { $0 > self.playbackRate } ?? 0
		self.fastSeekRateIndex = self.fastSeekBaseIndex
		self.runFastSeek()
	}

	/// Returns a keyboard-driven fast run to normal playback.
	private func endKeyboardFastSeek() {
		guard self.isKeyboardFastSeeking else { return }

		self.isKeyboardFastSeeking = false

		#if targetEnvironment(macCatalyst)
		self.controlBar.setFastSeekRate(nil, isForward: self.isFastSeekingForward)
		#endif

		self.endFastSeek()
	}

	/// Jumps to the trailer's beginning.
	@objc func jumpToBeginning() {
		self.endKeyboardFastSeek()
		self.seek(to: 0.0)
	}

	/// Jumps to the trailer's end.
	@objc func jumpToEnd() {
		self.endKeyboardFastSeek()

		guard self.duration > 0.0 else { return }
		self.seek(to: self.duration - 0.1)
	}

	/// Raises the volume a step.
	@objc func increaseVolume() {
		self.adjustVolumeFromKeyboard(by: 0.0625)
	}

	/// Lowers the volume a step.
	@objc func decreaseVolume() {
		self.adjustVolumeFromKeyboard(by: -0.0625)
	}

	/// Raises the volume to its loudest.
	@objc func maximizeVolume() {
		self.adjustVolumeFromKeyboard(by: 1.0)
	}

	/// Silences the volume.
	@objc func muteVolume() {
		self.adjustVolumeFromKeyboard(by: -1.0)
	}

	/// Moves the volume by the given amount.
	///
	/// - Parameter delta: The change to apply, where the whole range spans `0` to `1`.
	private func adjustVolumeFromKeyboard(by delta: Double) {
		#if targetEnvironment(macCatalyst)
		self.controlBar.adjustVolume(by: delta)
		self.setControls(visible: true, animated: true)
		self.scheduleControlsAutoHide()
		#endif
	}

	/// Enlarges the picture a step.
	@objc func zoomIn() {
		self.setZoom(self.zoomScrollView.zoomScale * 1.25)
	}

	/// Shrinks the picture a step.
	@objc func zoomOut() {
		self.setZoom(self.zoomScrollView.zoomScale / 1.25)
	}

	/// Returns the picture to its actual size.
	@objc func zoomActualSize() {
		self.setZoom(1.0)
	}

	/// Zooms the picture to the given scale.
	///
	/// - Parameter scale: The scale to zoom to.
	private func setZoom(_ scale: CGFloat) {
		let clampedScale = min(max(self.zoomScrollView.minimumZoomScale, scale), self.zoomScrollView.maximumZoomScale)
		self.zoomScrollView.setZoomScale(clampedScale, animated: true)
	}

	#if !targetEnvironment(macCatalyst)
	/// Zooms the picture in around a double tap, or back out.
	///
	/// - Parameter gesture: The tap being followed.
	@objc private func handleZoomTap(_ gesture: UITapGestureRecognizer) {
		guard self.zoomScrollView.zoomScale <= 1.01 else {
			self.zoomScrollView.setZoomScale(1.0, animated: true)
			return
		}

		let scale = self.fillZoomScale()
		let location = gesture.location(in: self.contentView)
		let size = CGSize(width: self.zoomScrollView.bounds.width / scale, height: self.zoomScrollView.bounds.height / scale)
		self.zoomScrollView.zoom(to: CGRect(x: location.x - size.width / 2.0, y: location.y - size.height / 2.0, width: size.width, height: size.height), animated: true)
	}

	/// Returns the area the picture occupies at its natural fit.
	///
	/// - Returns: The fitted rect, in the zoom view's coordinates.
	private func fittedPictureRect() -> CGRect {
		let bounds = self.zoomScrollView.bounds
		let referenceSize = TrailerWebPlayer.referenceSize
		guard bounds.width > 0.0, bounds.height > 0.0 else { return bounds }

		let fitScale = min(bounds.width / referenceSize.width, bounds.height / referenceSize.height)
		let size = CGSize(width: referenceSize.width * fitScale, height: referenceSize.height * fitScale)
		return CGRect(x: (bounds.width - size.width) / 2.0, y: (bounds.height - size.height) / 2.0, width: size.width, height: size.height)
	}

	/// Returns the scale at which the picture fills the screen.
	///
	/// - Returns: The fill scale.
	private func fillZoomScale() -> CGFloat {
		let bounds = self.zoomScrollView.bounds
		let pictureRect = self.fittedPictureRect()
		guard pictureRect.width > 0.0, pictureRect.height > 0.0 else { return 2.0 }

		let fillScale = max(bounds.width / pictureRect.width, bounds.height / pictureRect.height)
		return fillScale > 1.1 ? fillScale : 2.0
	}

	/// Carries the trailer off the screen with the reader's drag.
	///
	/// - Parameter gesture: The drag being followed.
	@objc private func handleDismissDrag(_ gesture: UIPanGestureRecognizer) {
		let translation = gesture.translation(in: self.view)
		let progress = min(1.0, abs(translation.y) / self.dismissDragDistance)

		switch gesture.state {
		case .began:
			self.isDraggingToDismiss = true
			self.dismissDragDistance = max(1.0, self.fittedPictureRect().maxY * 0.9)
			self.controlsHideTask?.cancel()
			self.scrubGlideTask?.cancel()
		case .changed:
			let scale = (3.0 - progress) / 3.0
			self.zoomWindowView.transform = CGAffineTransform(translationX: translation.x, y: translation.y).scaledBy(x: scale, y: scale)
			self.backdropView.alpha = 1.0 - progress
			self.chromeViews.forEach { $0.alpha = max(0.0, 1.0 - progress * 4.0) }
		case .ended:
			let velocity = gesture.velocity(in: self.view)
			let isFlick = abs(velocity.y) > 250.0 && abs(velocity.x) < abs(velocity.y)

			guard isFlick || progress >= 0.35 else {
				self.restoreFromDismissDrag()
				return
			}

			self.isDraggingToDismiss = false
			self.dismissDuration = isFlick ? 0.25 : 0.4
			self.close()
		default:
			self.restoreFromDismissDrag()
		}
	}

	/// Returns the trailer, backdrop and controls to rest after a drag lets go short of dismissal.
	private func restoreFromDismissDrag() {
		guard self.isDraggingToDismiss else { return }

		self.isDraggingToDismiss = false
		let controlsAlpha: CGFloat = self.areControlsVisible ? 1.0 : 0.0

		UIView.animate(withDuration: 0.175, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState]) {
			self.zoomWindowView.transform = .identity
			self.backdropView.alpha = 1.0
			self.chromeViews.forEach { $0.alpha = controlsAlpha }
		}

		self.scheduleControlsAutoHide()
	}
	#endif

	/// Leaves fullscreen in response to the fullscreen command.
	@objc func toggleTrailerFullscreen() {
		self.close()
	}

	/// Reads the timeline as time.
	@objc func showElapsedTime() {
		#if targetEnvironment(macCatalyst)
		self.controlBar.setTimeDisplayShowsFrames(false)
		#endif
	}

	/// Reads the timeline as frames.
	@objc func showFrameCount() {
		#if targetEnvironment(macCatalyst)
		self.controlBar.setTimeDisplayShowsFrames(true)
		#endif
	}

	/// Asks for a time and jumps the trailer to it.
	@objc func goToTimestamp() {
		self.presentJumpPrompt(title: L10n.goToTimestamp, currentValue: Self.timeText(forSeconds: self.elapsedTime)) { [weak self] input in
			guard let self = self, let seconds = Self.seconds(fromTimestamp: input) else { return }
			self.seek(to: seconds)
		}
	}

	/// Asks for a frame number and jumps the trailer to it.
	@objc func goToFrame() {
		guard let framesPerSecond = self.framesPerSecond else { return }

		let currentFrame = Int((self.elapsedTime * framesPerSecond).rounded())
		self.presentJumpPrompt(title: L10n.goToFrame, currentValue: "\(currentFrame) F") { [weak self] input in
			guard let self = self, let framesPerSecond = self.framesPerSecond else { return }

			let digits = input.filter { $0.isNumber }
			guard let frame = Int(digits) else { return }

			self.seek(to: Double(frame) / framesPerSecond)
		}
	}

	/// Asks where to jump to, offering the current point to edit.
	///
	/// - Parameters:
	///    - title: The title of the prompt.
	///    - currentValue: The current point, written the way the answer is expected.
	///    - jumpHandler: The closure taking the answer.
	private func presentJumpPrompt(title: String, currentValue: String, jumpHandler: @escaping (String) -> Void) {
		let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)

		alertController.addTextField { textField in
			textField.text = currentValue
			textField.keyboardType = .numbersAndPunctuation
			textField.clearButtonMode = .whileEditing
		}

		alertController.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
		alertController.addAction(UIAlertAction(title: L10n.go, style: .default) { [weak alertController] _ in
			guard let input = alertController?.textFields?.first?.text else { return }
			jumpHandler(input)
		})

		self.present(alertController, animated: true)
	}

	/// Returns the seconds a written timestamp stands for.
	///
	/// Reads plain seconds as well as minute and hour forms.
	///
	/// - Parameter timestamp: The written timestamp.
	///
	/// - Returns: The seconds the timestamp stands for.
	private static func seconds(fromTimestamp timestamp: String) -> Double? {
		let parts = timestamp.split(separator: ":").map { $0.trimmingCharacters(in: .whitespaces) }
		guard !parts.isEmpty, parts.count <= 3 else { return nil }

		var seconds = 0.0
		for part in parts {
			guard let value = Double(part), value >= 0.0 else { return nil }
			seconds = seconds * 60.0 + value
		}

		return seconds
	}

	override func validate(_ command: UICommand) {
		#if targetEnvironment(macCatalyst)
		switch command.action {
		case #selector(self.showElapsedTime):
			command.state = self.controlBar.showsFrames ? .off : .on
		case #selector(self.showFrameCount):
			command.state = self.controlBar.showsFrames ? .on : .off
		default:
			super.validate(command)
		}
		#else
		super.validate(command)
		#endif
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		switch action {
		// Frame readings need the frame rate, which takes a moment of playback to settle.
		case #selector(self.showFrameCount), #selector(self.goToFrame):
			return self.framesPerSecond != nil
		default:
			return super.canPerformAction(action, withSender: sender)
		}
	}

	/// Opens the trailer in a floating window, or brings it back.
	@objc func togglePictureInPicture() {
		#if targetEnvironment(macCatalyst)
		self.sendPagePress {
			self.player?.requestPictureInPicture()
		}
		#else
		self.player?.requestPictureInPicture()
		self.scheduleControlsAutoHide()
		#endif
	}

	#if !targetEnvironment(macCatalyst)
	/// Toggles the trailer's sound in response to the speaker glyph.
	private func toggleMute() {
		self.isMuted.toggle()
		self.player?.setMuted(self.isMuted)
		self.updateControls(animated: false)
		self.scheduleControlsAutoHide()
	}

	/// Shows or hides the controls the volume slider covers.
	private func updateVolumeNeighbors() {
		let isVisible = self.areControlsVisible && !self.volumeControl.isExpanded

		for view in [self.closeButton, self.outputGroupView] {
			view.alpha = isVisible ? 1.0 : 0.0
			view.isUserInteractionEnabled = isVisible
		}
	}
	#endif

	/// Brings the controls back as the pointer moves over the trailer.
	///
	/// - Parameter gesture: The pointer movement being followed.
	@objc private func handlePointerMovement(_ gesture: UIHoverGestureRecognizer) {
		switch gesture.state {
		case .began, .changed:
			let location = gesture.location(in: self.view)

			if let lastPointerLocation = self.lastPointerLocation, abs(location.x - lastPointerLocation.x) < 2.0, abs(location.y - lastPointerLocation.y) < 2.0 {
				return
			}

			self.lastPointerLocation = location

			if !self.areControlsVisible {
				self.setControls(visible: true, animated: true)
				self.pointerRevealDate = Date()
			}

			#if targetEnvironment(macCatalyst)
			self.isPointerOverControls = self.controlBar.frame.contains(location)
			#endif

			self.scheduleControlsAutoHide()
		default:
			self.lastPointerLocation = nil

			#if targetEnvironment(macCatalyst)
			self.isPointerOverControls = false
			#endif

			self.scheduleControlsAutoHide()
		}
	}

	/// Reveals or hides the controls in response to a tap.
	@objc private func toggleControlsVisibility() {
		#if targetEnvironment(macCatalyst)
		// A press the app itself sent into the page asks nothing of the controls.
		guard !self.isSendingPagePress else { return }
		#endif

		self.controlsHideTask?.cancel()

		// A click whose pointer movement just revealed the controls means "show", not "hide".
		if self.areControlsVisible, let pointerRevealDate = self.pointerRevealDate, Date().timeIntervalSince(pointerRevealDate) < 0.5 {
			self.pointerRevealDate = nil
			self.scheduleControlsAutoHide()
			return
		}

		self.setControls(visible: !self.areControlsVisible, animated: true)

		if self.areControlsVisible {
			self.scheduleControlsAutoHide()
		}
	}

	/// Hides the controls after a delay while the trailer plays.
	private func scheduleControlsAutoHide() {
		self.controlsHideTask?.cancel()

		self.controlsHideTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 3_000_000_000)
			guard !Task.isCancelled, let self = self else { return }
			guard self.isPlaying, !self.isScrubbing else { return }

			#if targetEnvironment(macCatalyst)
			guard !self.isPointerOverControls, !self.controlBar.isEngaged else { return }
			#else
			guard !self.isDraggingToDismiss, !self.volumeControl.isExpanded else { return }
			#endif

			self.setControls(visible: false, animated: true)
		}
	}

	/// Updates the controls' glyphs for the current state.
	///
	/// - Parameter animated: Whether the change is animated.
	private func updateControls(animated: Bool) {
		let isStreamingExternally = TrailerAirPlayStreamer.shared.isStreaming(from: self.player)
		self.airPlayNoticeView.isHidden = !isStreamingExternally

		if isStreamingExternally {
			self.airPlayNoticeView.refresh()
		}

		#if targetEnvironment(macCatalyst)
		self.controlBar.setPlaying(self.isPlaying)
		self.controlBar.setVolume(self.isMuted ? 0.0 : (self.player?.volume ?? 1.0))
		#else
		self.playPauseButton.setImage(UIImage(systemName: self.isPlaying ? "pause.fill" : "play.fill"), for: .normal)
		self.playPauseButton.accessibilityLabel = self.isPlaying ? L10n.pause : L10n.play
		self.volumeControl.isMuted = self.isMuted
		#endif

		self.setControls(visible: true, animated: animated)
	}

	/// Shows or hides the transient controls.
	///
	/// - Parameters:
	///    - visible: Whether the controls are shown.
	///    - animated: Whether the change is animated.
	private func setControls(visible: Bool, animated: Bool) {
		#if targetEnvironment(macCatalyst)
		let transientViews: [UIView] = [self.controlBar]
		let interactiveViews = transientViews
		#else
		guard !self.isDraggingToDismiss else { return }

		let transientViews = self.chromeViews
		let interactiveViews = transientViews.filter { $0 !== self.dimmingView }
		let topViews = self.topChromeViews
		let bottomViews = self.bottomChromeViews

		if !visible {
			self.volumeControl.setExpanded(false)
		}
		#endif

		self.areControlsVisible = visible
		self.player?.setSubtitlesRaised(visible)
		interactiveViews.forEach { $0.isUserInteractionEnabled = visible }

		let apply = {
			transientViews.forEach { $0.alpha = visible ? 1.0 : 0.0 }

			#if !targetEnvironment(macCatalyst)
			topViews.forEach { $0.transform = visible ? .identity : CGAffineTransform(translationX: 0.0, y: -12.0) }
			bottomViews.forEach { $0.transform = visible ? .identity : CGAffineTransform(translationX: 0.0, y: 12.0) }
			self.updateVolumeNeighbors()
			self.setNeedsStatusBarAppearanceUpdate()
			#endif
		}

		if animated {
			UIView.animate(withDuration: 0.25, animations: apply)
		} else {
			apply()
		}
	}

	/// Scrubs the trailer as the reader swipes across the picture.
	///
	/// - Parameter gesture: The swipe being followed.
	@objc private func handleScrubGesture(_ gesture: UIPanGestureRecognizer) {
		guard self.duration > 0.0, self.view.bounds.width > 0.0 else { return }

		#if targetEnvironment(macCatalyst)
		// Scroll gestures carry no touches. A pointer drag does, and is left alone.
		guard gesture.numberOfTouches == 0 else { return }

		// A swipe over the volume controls belongs to the volume for as long as it lasts.
		if gesture.state == .began, self.areControlsVisible, self.controlBar.isVolumeSpot(gesture.location(in: self.view), from: self.view) {
			self.isAdjustingVolume = true
		}

		if self.isAdjustingVolume {
			switch gesture.state {
			case .began, .changed:
				let translation = gesture.translation(in: self.view)
				gesture.setTranslation(.zero, in: self.view)
				self.controlBar.adjustVolume(by: Double(translation.x - translation.y) / 250.0)
				self.controlsHideTask?.cancel()
			default:
				self.isAdjustingVolume = false
				self.scheduleControlsAutoHide()
			}

			return
		}
		#endif

		// Zoomed in, the swipe moves the picture instead.
		guard self.zoomScrollView.zoomScale <= 1.01 else { return }

		// Well under a screen-width per trailer, so the timeline can be worked frame by frame.
		let secondsPerPoint = (self.duration / Double(self.view.bounds.width)) * 0.35

		switch gesture.state {
		case .began:
			self.isScrubbing = true
			self.scrubGlideTask?.cancel()
			self.controlsHideTask?.cancel()
			self.setControls(visible: true, animated: true)

			// Playback picks back up when the fingers lift.
			self.wasPlayingBeforeScrub = self.isPlaying
			self.player?.pause()
		case .changed:
			let translation = gesture.translation(in: self.view)
			gesture.setTranslation(.zero, in: self.view)
			self.scrub(by: Double(translation.x) * secondsPerPoint)
		default:
			if self.wasPlayingBeforeScrub {
				self.wasPlayingBeforeScrub = false
				self.player?.play()
			}

			// A flick keeps running and eases to a stop, the way a scroll does.
			let velocity = Double(gesture.velocity(in: self.view).x) * secondsPerPoint
			self.glideScrub(startingAt: velocity)
		}
	}

	/// Moves the trailer along by the given amount, keeping it inside the timeline.
	///
	/// - Parameter seconds: The seconds to move by.
	private func scrub(by seconds: Double) {
		self.elapsedTime = min(max(0.0, self.elapsedTime + seconds), self.duration)
		self.seekSettleDate = Date().addingTimeInterval(0.5)
		self.player?.seek(to: self.elapsedTime)
		self.updateProgressControls()

		#if !targetEnvironment(macCatalyst)
		if self.duration > 0.0 {
			self.scrubber.value = Float(self.elapsedTime / self.duration)
		}
		#endif
	}

	/// Carries a flicked scrub onwards, slowing it until it settles.
	///
	/// - Parameter velocity: The speed the flick left off at, in trailer seconds per second.
	private func glideScrub(startingAt velocity: Double) {
		self.scrubGlideTask?.cancel()

		guard abs(velocity) > 0.5 else {
			self.isScrubbing = false
			self.scheduleControlsAutoHide()
			return
		}

		self.scrubGlideTask = Task { @MainActor [weak self] in
			var remainingVelocity = velocity
			let frameDuration = 1.0 / 60.0

			while !Task.isCancelled, abs(remainingVelocity) > 0.5 {
				guard let self = self else { return }

				self.scrub(by: remainingVelocity * frameDuration)
				remainingVelocity *= 0.82

				try? await Task.sleep(nanoseconds: UInt64(frameDuration * 1_000_000_000.0))
			}

			guard let self = self, !Task.isCancelled else { return }
			self.isScrubbing = false
			self.scheduleControlsAutoHide()
		}
	}

	/// Runs the trailer fast for as long as a seek button is held.
	///
	/// - Parameter isForward: Whether the trailer runs forwards.
	private func beginFastSeek(isForward: Bool) {
		self.wasPlayingBeforeFastSeek = self.isPlaying
		self.isFastSeekingForward = isForward
		self.isFastSeeking = true

		// Holding starts above whatever speed is already chosen, so 2× playback begins the climb at 5×.
		self.fastSeekBaseIndex = self.fastSeekRates.firstIndex { $0 > self.playbackRate } ?? 0
		self.fastSeekRateIndex = self.fastSeekBaseIndex
		self.runFastSeek()
	}

	/// Sets the ladder's rung for how hard the held seek button is pressed.
	///
	/// - Parameter progression: The press beyond the opening click, from `0` to `1`.
	private func setFastSeekProgression(_ progression: Double) {
		guard self.isFastSeeking else { return }

		let stepCount = self.fastSeekRates.count - 1 - self.fastSeekBaseIndex
		guard stepCount > 0 else { return }

		// Rounding would give the lowest rate half a band, which is near impossible to hold.
		let steps = min(stepCount, Int(progression * Double(stepCount + 1)))
		let index = self.fastSeekBaseIndex + max(0, steps)
		guard index != self.fastSeekRateIndex else { return }

		self.fastSeekRateIndex = index
		self.runFastSeek()

		if UserSettings.hapticsAllowed {
			#if targetEnvironment(macCatalyst)
			TrackpadPressureMonitor.performLevelChangeHaptic()
			#else
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			#endif
		}
	}

	/// Runs the trailer along at the ladder's current speed.
	private func runFastSeek() {
		let rate = self.fastSeekRates[self.fastSeekRateIndex]

		#if targetEnvironment(macCatalyst)
		self.controlBar.setFastSeekRate(rate, isForward: self.isFastSeekingForward)
		#endif

		// A held rate is not the chosen rate.
		self.player?.setPlaybackRate(self.isFastSeekingForward ? rate : -rate, remembers: false)
		self.player?.play()
	}

	/// Returns the trailer to the speed and play state it was at before the button was held.
	private func endFastSeek() {
		guard self.isFastSeeking else { return }

		self.settleFastSeek()

		if self.wasPlayingBeforeFastSeek {
			self.player?.play()
		} else {
			self.player?.pause()
		}

		self.scheduleControlsAutoHide()
	}

	/// Ends the fast run and hands the trailer back its chosen speed.
	private func settleFastSeek() {
		self.isFastSeeking = false
		self.isKeyboardFastSeeking = false

		#if targetEnvironment(macCatalyst)
		self.controlBar.setFastSeekRate(nil, isForward: self.isFastSeekingForward)
		#endif

		self.player?.setPlaybackRate(self.playbackRate)
	}

	#if !targetEnvironment(macCatalyst)
	/// Moves the trailer back through its timeline.
	@objc private func skipBackward() {
		self.seek(to: self.elapsedTime - self.skipInterval)
	}

	/// Moves the trailer forward through its timeline.
	@objc private func skipForward() {
		self.seek(to: self.elapsedTime + self.skipInterval)
	}

	/// Holds the controls open while the reader drags the scrubber.
	@objc private func scrubbingDidBegin() {
		self.isScrubbing = true
		self.controlsHideTask?.cancel()
	}

	/// Previews the point the reader is dragging to.
	@objc private func scrubbingDidChange() {
		guard self.duration > 0.0 else { return }
		self.showTimeline(at: Double(self.scrubber.value) * self.duration)
	}

	/// Plays from the point the reader dragged to.
	@objc private func scrubbingDidEnd() {
		self.isScrubbing = false

		if self.duration > 0.0 {
			self.seek(to: Double(self.scrubber.value) * self.duration)
		}

		self.scheduleControlsAutoHide()
	}

	/// Writes the timeline's readings for the given point.
	///
	/// - Parameter seconds: The point in the trailer.
	private func showTimeline(at seconds: Double) {
		self.elapsedTimeLabel.text = Self.timeText(forSeconds: seconds)
		self.remainingTimeLabel.text = "−" + Self.timeText(forSeconds: max(0.0, self.duration - seconds))
	}
	#endif

	/// Moves playback to the given point, keeping it inside the trailer.
	///
	/// - Parameter seconds: The point to play from.
	private func seek(to seconds: Double) {
		let target = self.duration > 0.0 ? min(max(0.0, seconds), self.duration) : max(0.0, seconds)

		self.elapsedTime = target
		self.seekSettleDate = Date().addingTimeInterval(0.5)
		self.player?.seek(to: target)
		self.updateProgressControls()
		self.scheduleControlsAutoHide()
	}

	/// Builds the menu of extra actions for the given control.
	///
	/// - Parameter sourceView: The control the menu opens from.
	///
	/// - Returns: The menu to show.
	private func makeOptionsMenu(from sourceView: UIView) -> UIMenu {
		let speedActions = self.playbackRates.map { rate in
			UIAction(title: Self.speedText(forRate: rate), state: rate == self.playbackRate ? .on : .off) { [weak self] _ in
				self?.setPlaybackRate(rate)
			}
		}

		var children: [UIMenuElement] = []

		if let shareHandler = self.shareHandler {
			children.append(UIAction(title: L10n.share, image: UIImage(systemName: "square.and.arrow.up")) { [weak sourceView] _ in
				guard let sourceView = sourceView else { return }
				shareHandler(sourceView)
			})
		}

		if let downloadMenu = self.player?.downloadMenu() {
			children.append(downloadMenu)
		}

		children.append(UIMenu(title: L10n.playbackSpeed, image: UIImage(systemName: "speedometer"), children: speedActions))

		if self.player?.captionTracks.isEmpty == false {
			children.append(UIMenu(title: L10n.subtitles, image: UIImage(systemName: "captions.bubble"), children: self.captionMenuElements()))
		}

		children.append(UIMenu(title: L10n.videoQuality, image: UIImage(systemName: "sparkles.tv"), children: self.qualityMenuActions()))

		return UIMenu(children: children)
	}

	/// Builds the elements that switch, style, and pick the trailer's subtitles.
	///
	/// - Returns: The on and off pair followed by the style and language menus.
	private func captionMenuElements() -> [UIMenuElement] {
		let selectedTrack = self.player?.selectedCaptionTrack
		let switchActions = [
			UIAction(title: L10n.on, state: selectedTrack == nil ? .off : .on) { [weak self] _ in
				self?.player?.enableCaptions()
			},
			UIAction(title: L10n.off, state: selectedTrack == nil ? .on : .off) { [weak self] _ in
				self?.player?.selectCaptionTrack(nil)
			}
		]
		var elements: [UIMenuElement] = [UIMenu(options: .displayInline, children: switchActions)]

		if #available(iOS 26.0, macCatalyst 26.0, *) {
			elements.append(UIMenu(title: L10n.style, children: self.captionStyleActions()))
		}

		let languageActions = (self.player?.captionTracks ?? []).map { track in
			UIAction(title: track.title, subtitle: track.isAutoGenerated ? L10n.autoGenerated : nil, state: track == selectedTrack ? .on : .off) { [weak self] _ in
				self?.player?.selectCaptionTrack(track)
			}
		}
		elements.append(UIMenu(title: L10n.languageSingular, children: languageActions))

		return elements
	}

	/// Builds the actions that pick the system's subtitle style.
	///
	/// - Returns: An action per caption style profile.
	@available(iOS 26.0, macCatalyst 26.0, *)
	private func captionStyleActions() -> [UIMenuElement] {
		let activeProfileID = MACaptionAppearanceCopyActiveProfileID() as String
		let profileIDs = MACaptionAppearanceCopyProfileIDs() as? [String] ?? []

		return profileIDs.map { profileID in
			UIAction(title: MACaptionAppearanceCopyProfileName(profileID as CFString) as String, state: profileID == activeProfileID ? .on : .off) { _ in
				MACaptionAppearanceSetActiveProfileID(profileID as CFString)
			}
		}
	}

	/// Builds the actions that choose the trailer's quality.
	///
	/// - Returns: An action per quality level.
	private func qualityMenuActions() -> [UIMenuElement] {
		var preferredLevel = self.player?.preferredQualityLevel ?? "auto"

		if preferredLevel != "auto" {
			preferredLevel = self.player?.resolvedQualityLevel() ?? preferredLevel
		}

		var actions: [UIMenuElement] = [
			UIAction(title: L10n.automatic, state: preferredLevel == "auto" ? .on : .off) { [weak self] _ in
				self?.setPreferredQuality("auto")
			}
		]

		for level in self.player?.availableQualityLevels ?? [] {
			actions.append(UIAction(title: level, state: level == preferredLevel ? .on : .off) { [weak self] _ in
				self?.setPreferredQuality(level)
			})
		}

		return actions
	}

	/// Holds playback at the given quality level.
	///
	/// - Parameter level: The quality level to hold.
	private func setPreferredQuality(_ level: String) {
		self.player?.setPreferredQualityLevel(level)
		self.scheduleControlsAutoHide()
	}

	/// Sets how fast the trailer plays.
	///
	/// - Parameter rate: The multiple of normal speed to play at.
	private func setPlaybackRate(_ rate: Double) {
		self.playbackRate = rate
		self.player?.setPlaybackRate(rate)

		#if targetEnvironment(macCatalyst)
		self.controlBar.setPlaybackRate(rate)
		#endif

		self.scheduleControlsAutoHide()
	}

	/// Moves the scrubber and time labels to the current point.
	private func updateProgressControls() {
		#if targetEnvironment(macCatalyst)
		self.controlBar.setProgress(elapsedTime: self.elapsedTime, duration: self.duration)
		#else
		self.showTimeline(at: self.elapsedTime)

		guard !self.isScrubbing, self.duration > 0.0 else { return }
		self.scrubber.value = Float(self.elapsedTime / self.duration)
		#endif
	}

	/// Moves the presentation onto the given trailer, continuing the queue.
	///
	/// - Parameter player: The player rendering the next trailer.
	private func switchTo(_ player: TrailerWebPlayer) {
		let previousPlayer = self.player
		self.videoID = player.videoID
		self.player = player

		player.attach(to: self.contentView, isMuted: self.isMuted, delegate: self)
		player.setLooping(false)
		player.setPlaybackRate(self.playbackRate)
		TrailerAirPlayStreamer.shared.continueStream(with: player)
		player.play()
		self.isPlaying = true

		if player !== previousPlayer {
			self.duration = 0.0
		}

		self.elapsedTime = 0.0
		self.framesPerSecond = nil
		self.seekSettleDate = nil
		self.updateProgressControls()
		self.updateControls(animated: false)

		#if targetEnvironment(macCatalyst)
		player.setInteractionEnabled(true)
		self.controlBar.reloadOptionsMenu()
		#endif
	}

	/// Pins the player and controls in the view.
	private func configureViews() {
		self.view.backgroundColor = .clear
		self.view.addSubview(self.backdropView)
		self.view.addSubview(self.zoomWindowView)
		self.zoomWindowView.addSubview(self.zoomScrollView)
		self.zoomScrollView.addSubview(self.contentView)
		self.contentView.addSubview(self.airPlayNoticeView)
		self.zoomScrollView.delegate = self
		self.view.addSubview(self.closeButton)

		let revealGesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleControlsVisibility))
		revealGesture.cancelsTouchesInView = false
		revealGesture.delegate = self
		self.view.addGestureRecognizer(revealGesture)

		let pointerGesture = UIHoverGestureRecognizer(target: self, action: #selector(self.handlePointerMovement(_:)))
		self.view.addGestureRecognizer(pointerGesture)

		let scrubGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleScrubGesture(_:)))
		scrubGesture.cancelsTouchesInView = false
		scrubGesture.delegate = self
		self.view.addGestureRecognizer(scrubGesture)

		self.closeButton.addTarget(self, action: #selector(self.close), for: .primaryActionTriggered)
		self.closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
		self.closeButton.accessibilityLabel = L10n.dismiss

		let layoutMarginsGuide = self.view.layoutMarginsGuide

		NSLayoutConstraint.activate([
			self.backdropView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.backdropView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.backdropView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.backdropView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.zoomWindowView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.zoomWindowView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.zoomWindowView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.zoomWindowView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.zoomScrollView.topAnchor.constraint(equalTo: self.zoomWindowView.topAnchor),
			self.zoomScrollView.leadingAnchor.constraint(equalTo: self.zoomWindowView.leadingAnchor),
			self.zoomScrollView.trailingAnchor.constraint(equalTo: self.zoomWindowView.trailingAnchor),
			self.zoomScrollView.bottomAnchor.constraint(equalTo: self.zoomWindowView.bottomAnchor),

			self.contentView.topAnchor.constraint(equalTo: self.zoomScrollView.contentLayoutGuide.topAnchor),
			self.contentView.leadingAnchor.constraint(equalTo: self.zoomScrollView.contentLayoutGuide.leadingAnchor),
			self.contentView.trailingAnchor.constraint(equalTo: self.zoomScrollView.contentLayoutGuide.trailingAnchor),
			self.contentView.bottomAnchor.constraint(equalTo: self.zoomScrollView.contentLayoutGuide.bottomAnchor),
			self.contentView.widthAnchor.constraint(equalTo: self.zoomScrollView.frameLayoutGuide.widthAnchor),
			self.contentView.heightAnchor.constraint(equalTo: self.zoomScrollView.frameLayoutGuide.heightAnchor),

			self.airPlayNoticeView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.airPlayNoticeView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.airPlayNoticeView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.airPlayNoticeView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.closeButton.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
		])

		#if targetEnvironment(macCatalyst)
		let exitGesture = UITapGestureRecognizer(target: self, action: #selector(self.close))
		exitGesture.numberOfTapsRequired = 2
		exitGesture.cancelsTouchesInView = false
		exitGesture.delegate = self
		self.view.addGestureRecognizer(exitGesture)
		revealGesture.require(toFail: exitGesture)
		scrubGesture.allowedScrollTypesMask = .all

		self.controlBar.translatesAutoresizingMaskIntoConstraints = false
		self.controlBar.delegate = self
		self.view.addSubview(self.controlBar)
		self.controlBar.reloadOptionsMenu()

		NSLayoutConstraint.activate([
			self.closeButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			self.controlBar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.controlBar.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -24.0)
		])
		#else
		self.configureTouchChrome(revealGesture: revealGesture, scrubGesture: scrubGesture)
		#endif
	}

	#if !targetEnvironment(macCatalyst)
	/// Lays out the touch controls and gestures.
	///
	/// - Parameters:
	///    - revealGesture: The tap that toggles the controls.
	///    - scrubGesture: The swipe that scrubs the trailer.
	private func configureTouchChrome(revealGesture: UITapGestureRecognizer, scrubGesture: UIPanGestureRecognizer) {
		let zoomGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleZoomTap(_:)))
		zoomGesture.numberOfTapsRequired = 2
		zoomGesture.delegate = self
		self.view.addGestureRecognizer(zoomGesture)
		revealGesture.require(toFail: zoomGesture)

		scrubGesture.maximumNumberOfTouches = 1
		self.dismissGesture.maximumNumberOfTouches = 1
		self.dismissGesture.delegate = self
		self.view.addGestureRecognizer(self.dismissGesture)

		self.airPlayRoutePickerView.delegate = self
		self.airPlayRoutePickerView.accessibilityLabel = L10n.airPlay
		self.pictureInPictureButton.accessibilityLabel = L10n.pictureInPicture
		self.pictureInPictureButton.isHidden = !AVPictureInPictureController.isPictureInPictureSupported()
		self.pictureInPictureButton.addTarget(self, action: #selector(self.togglePictureInPicture), for: .primaryActionTriggered)

		let outputStackView = UIStackView(arrangedSubviews: [self.pictureInPictureButton, self.airPlayRoutePickerView])
		outputStackView.translatesAutoresizingMaskIntoConstraints = false
		self.outputGroupView.contentView.addSubview(outputStackView)

		self.volumeControl.onInteraction = { [weak self] in
			self?.scheduleControlsAutoHide()
		}
		self.volumeControl.onToggleMute = { [weak self] in
			self?.toggleMute()
		}
		self.volumeControl.onVolumeAdjust = { [weak self] in
			guard let self = self, self.isMuted else { return }
			self.toggleMute()
		}
		self.volumeControl.onSystemVolumeChange = { [weak self] in
			guard let self = self, !self.areControlsVisible else { return }

			self.volumeControl.alpha = 1.0
			self.volumeControl.transform = .identity
			self.volumeControl.isUserInteractionEnabled = true
		}
		self.volumeControl.onExpansionChange = { [weak self] isExpanded in
			guard let self = self else { return }

			self.updateVolumeNeighbors()

			if !isExpanded, !self.areControlsVisible {
				self.volumeControl.alpha = 0.0
				self.volumeControl.isUserInteractionEnabled = false
			}
		}

		self.playPauseButton.addTarget(self, action: #selector(self.togglePlayPause), for: .primaryActionTriggered)
		self.skipBackwardButton.addTarget(self, action: #selector(self.skipBackward), for: .primaryActionTriggered)
		self.skipForwardButton.addTarget(self, action: #selector(self.skipForward), for: .primaryActionTriggered)
		self.skipBackwardButton.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
		self.skipBackwardButton.accessibilityLabel = L10n.skipBackward
		self.skipForwardButton.setImage(UIImage(systemName: "goforward.10"), for: .normal)
		self.skipForwardButton.accessibilityLabel = L10n.skipForward

		self.optionsButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
		self.optionsButton.accessibilityLabel = L10n.more
		self.optionsButton.showsMenuAsPrimaryAction = true
		self.optionsButton.menu = UIMenu(children: [
			UIDeferredMenuElement.uncached { [weak self] completion in
				guard let self = self else {
					completion([])
					return
				}

				completion(self.makeOptionsMenu(from: self.optionsButton).children)
			}
		])

		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidBegin), for: [.touchDown])
		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidChange), for: [.valueChanged])
		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])

		let transportStackView = UIStackView(arrangedSubviews: [self.skipBackwardButton, self.playPauseButton, self.skipForwardButton])
		transportStackView.translatesAutoresizingMaskIntoConstraints = false
		transportStackView.alignment = .center
		transportStackView.spacing = 26.0

		let timelineStackView = UIStackView(arrangedSubviews: [self.elapsedTimeLabel, self.scrubber, self.remainingTimeLabel])
		timelineStackView.translatesAutoresizingMaskIntoConstraints = false
		timelineStackView.alignment = .center
		timelineStackView.spacing = 12.0
		self.timelineBarView.contentView.addSubview(timelineStackView)

		self.view.insertSubview(self.dimmingView, aboveSubview: self.zoomWindowView)
		[self.outputGroupView, self.volumeControl, transportStackView, self.optionsButton, self.timelineBarView].forEach { self.view.addSubview($0) }

		let safeAreaGuide = self.view.safeAreaLayoutGuide

		NSLayoutConstraint.activate([
			self.dimmingView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.dimmingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.dimmingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.dimmingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.closeButton.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: 20.0),

			self.outputGroupView.leadingAnchor.constraint(equalTo: self.closeButton.trailingAnchor, constant: 12.0),
			self.outputGroupView.centerYAnchor.constraint(equalTo: self.closeButton.centerYAnchor),
			outputStackView.topAnchor.constraint(equalTo: self.outputGroupView.topAnchor),
			outputStackView.leadingAnchor.constraint(equalTo: self.outputGroupView.leadingAnchor),
			outputStackView.trailingAnchor.constraint(equalTo: self.outputGroupView.trailingAnchor),
			outputStackView.bottomAnchor.constraint(equalTo: self.outputGroupView.bottomAnchor),
			self.airPlayRoutePickerView.widthAnchor.constraint(equalToConstant: 56.0),
			self.airPlayRoutePickerView.heightAnchor.constraint(equalToConstant: 44.0),

			self.volumeControl.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: -20.0),
			self.volumeControl.centerYAnchor.constraint(equalTo: self.closeButton.centerYAnchor),

			transportStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			transportStackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),

			self.timelineBarView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: 20.0),
			self.timelineBarView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: -20.0),
			self.timelineBarView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor),
			self.timelineBarView.heightAnchor.constraint(equalToConstant: 44.0),

			timelineStackView.leadingAnchor.constraint(equalTo: self.timelineBarView.leadingAnchor, constant: 18.0),
			timelineStackView.trailingAnchor.constraint(equalTo: self.timelineBarView.trailingAnchor, constant: -18.0),
			timelineStackView.centerYAnchor.constraint(equalTo: self.timelineBarView.centerYAnchor),

			self.optionsButton.trailingAnchor.constraint(equalTo: self.timelineBarView.trailingAnchor),
			self.optionsButton.bottomAnchor.constraint(equalTo: self.timelineBarView.topAnchor, constant: -12.0)
		])
	}

	/// Builds a label for a point in the trailer's timeline.
	///
	/// - Returns: A configured label.
	private static func makeTimeLabel() -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .monospacedDigitSystemFont(ofSize: 15.0, weight: .regular)
		label.textColor = UIColor(white: 0.7, alpha: 1.0)
		label.text = Self.timeText(forSeconds: 0.0)
		return label
	}

	/// Builds a glass capsule for a row of controls.
	///
	/// - Returns: A configured effect view.
	private static func makeGlassCapsule() -> UIVisualEffectView {
		let effectView = UIVisualEffectView()
		effectView.translatesAutoresizingMaskIntoConstraints = false
		effectView.overrideUserInterfaceStyle = .dark
		effectView.clipsToBounds = true
		effectView.layer.cornerCurve = .continuous

		if #available(iOS 26.0, *) {
			let glassEffect = UIGlassEffect(style: .clear)
			glassEffect.isInteractive = true
			effectView.effect = glassEffect
			effectView.cornerConfiguration = .capsule()
		} else {
			effectView.effect = UIBlurEffect(style: .dark)
		}

		return effectView
	}

	/// Builds a bare glyph button for a glass capsule.
	///
	/// - Parameter systemName: The name of the symbol to show.
	///
	/// - Returns: A configured button.
	private static func makeGlyphButton(systemName: String) -> UIButton {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tintColor = .white
		button.setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 17.0, weight: .semibold)), for: .normal)

		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: 56.0),
			button.heightAnchor.constraint(equalToConstant: 44.0)
		])

		return button
	}
	#endif

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

	/// Returns the given speed written for display.
	///
	/// - Parameter rate: The multiple of normal speed.
	///
	/// - Returns: The speed written as a multiplier.
	private static func speedText(forRate rate: Double) -> String {
		let measurement = rate.formatted(.number.precision(.fractionLength(0 ... 2)))
		return "\(measurement)×"
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

		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: diameter),
			button.heightAnchor.constraint(equalToConstant: diameter)
		])

		return button
	}

	/// Builds a round button for the screen's edges.
	///
	/// - Returns: A configured button.
	private static func makeEdgeButton() -> AdaptiveCornerButton {
		#if targetEnvironment(macCatalyst)
		return Self.makeControlButton(pointSize: 14.0, diameter: 40.0)
		#else
		return Self.makeControlButton(pointSize: 17.0, diameter: 44.0)
		#endif
	}
}

#if targetEnvironment(macCatalyst)
// MARK: - TrailerPlayerControlBarDelegate
extension TrailerFullscreenViewController: TrailerPlayerControlBarDelegate {
	func trailerPlayerControlBarDidTogglePlayback(_ controlBar: TrailerPlayerControlBar) {
		self.togglePlayPause()
	}

	func trailerPlayerControlBar(_ controlBar: TrailerPlayerControlBar, didSeekTo seconds: Double) {
		self.seek(to: seconds)
	}

	func trailerPlayerControlBarDidBeginScrubbing(_ controlBar: TrailerPlayerControlBar) {
		self.controlsHideTask?.cancel()

		// The picture holds still under the drag, the same as the swipe scrub.
		self.wasPlayingBeforeScrub = self.isPlaying
		self.player?.pause()
	}

	func trailerPlayerControlBarDidEndScrubbing(_ controlBar: TrailerPlayerControlBar) {
		if self.wasPlayingBeforeScrub {
			self.wasPlayingBeforeScrub = false
			self.player?.play()
		}

		self.scheduleControlsAutoHide()
	}

	func trailerPlayerControlBar(_ controlBar: TrailerPlayerControlBar, didChangeVolume volume: Double) {
		self.player?.setVolume(volume)

		// Sliding to silence is muting, and sliding back up is unmuting.
		let shouldBeMuted = volume <= 0.0
		if self.isMuted != shouldBeMuted {
			self.isMuted = shouldBeMuted
			self.player?.setMuted(shouldBeMuted)
		}

		self.scheduleControlsAutoHide()
	}

	func trailerPlayerControlBarDidRequestPictureInPicture(_ controlBar: TrailerPlayerControlBar) {
		self.sendPagePress {
			self.player?.requestPictureInPicture()
		}
	}

	func trailerPlayerControlBarTrailerPlayer(_ controlBar: TrailerPlayerControlBar) -> TrailerWebPlayer? {
		return self.player
	}

	/// Runs the given press into the page while the tap gesture looks away.
	///
	/// - Parameter press: The closure sending the press.
	private func sendPagePress(_ press: () -> Void) {
		self.isSendingPagePress = true
		press()

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			self?.isSendingPagePress = false
		}
	}

	func trailerPlayerControlBar(_ controlBar: TrailerPlayerControlBar, didBeginFastSeekForward isForward: Bool) {
		self.beginFastSeek(isForward: isForward)
	}

	func trailerPlayerControlBar(_ controlBar: TrailerPlayerControlBar, didChangeFastSeekProgression progression: Double) {
		self.setFastSeekProgression(progression)
	}

	func trailerPlayerControlBarDidEndFastSeek(_ controlBar: TrailerPlayerControlBar) {
		self.endFastSeek()
	}

	func trailerPlayerControlBarOptionsMenu(_ controlBar: TrailerPlayerControlBar) -> UIMenu {
		return self.makeOptionsMenu(from: controlBar)
	}
}
#endif

// MARK: - UIScrollViewDelegate
extension TrailerFullscreenViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.contentView
	}
}

// MARK: - UIGestureRecognizerDelegate
extension TrailerFullscreenViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}

	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		#if targetEnvironment(macCatalyst)
		return true
		#else
		guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
		guard self.zoomScrollView.zoomScale <= 1.01, self.player?.hasActiveTextSelection != true else { return false }

		let velocity = panGesture.velocity(in: self.view)
		let isVertical = abs(velocity.y) > abs(velocity.x)
		return panGesture === self.dismissGesture ? isVertical : !isVertical
		#endif
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		#if targetEnvironment(macCatalyst)
		if self.areControlsVisible, self.controlBar.frame.contains(touch.location(in: self.view)) {
			return false
		}

		return true
		#else
		var view = touch.view

		while let candidate = view, candidate !== self.view {
			if candidate is UIControl || candidate === self.timelineBarView || candidate === self.outputGroupView || candidate === self.volumeControl {
				return false
			}

			view = candidate.superview
		}

		return true
		#endif
	}
}

// MARK: - UIViewControllerTransitioningDelegate
extension TrailerFullscreenViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return TrailerFullscreenTransitionAnimator(isPresenting: true, sourceFrame: self.sourceFrame)
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return TrailerFullscreenTransitionAnimator(isPresenting: false, sourceFrame: self.sourceFrame, duration: self.dismissDuration)
	}
}

#if !targetEnvironment(macCatalyst)
// MARK: - AVRoutePickerViewDelegate
extension TrailerFullscreenViewController: AVRoutePickerViewDelegate {
	func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
		TrailerAirPlayStreamer.shared.arm(with: self.player, for: routePickerView)
	}

	func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
		TrailerAirPlayStreamer.shared.probe()
	}
}
#endif

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

	func trailerWebPlayerDidRevealPicture(_ trailerWebPlayer: TrailerWebPlayer) {}

	func trailerWebPlayerDidReachEnd(_ trailerWebPlayer: TrailerWebPlayer) {
		guard self.advanceHandler != nil else { return }

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
			guard self.videoID == endedVideoID, self.view.window != nil else { return }
			guard let nextPlayer = self.advanceHandler?() else { return }
			self.switchTo(nextPlayer)

			if self.isFastSeeking {
				self.runFastSeek()
			}
		}
	}

	func trailerWebPlayerDidLoop(_ trailerWebPlayer: TrailerWebPlayer) {
		self.elapsedTime = 0.0
		self.seekSettleDate = nil
		self.updateProgressControls()
	}

	func trailerWebPlayer(_ trailerWebPlayer: TrailerWebPlayer, didPlayTo currentTime: Double, duration: Double) {
		self.duration = duration

		if self.framesPerSecond == nil, let framesPerSecond = trailerWebPlayer.framesPerSecond {
			self.framesPerSecond = framesPerSecond

			#if targetEnvironment(macCatalyst)
			self.controlBar.setFramesPerSecond(framesPerSecond)
			#endif
		}

		// A seek takes a moment to land, and until it does the player still reports the old point. Taking
		// it would drag the scrubber and labels back to where the reader just left, so it is ignored
		// while they are moving and briefly after, letting playback catch up instead of fighting them.
		let isAwaitingSeek = self.seekSettleDate.map { $0 > Date() } ?? false
		guard !self.isScrubbing, !isAwaitingSeek else { return }

		// A fast run reports its position unevenly, often behind the last report.
		if self.isFastSeeking {
			guard self.isFastSeekingForward ? currentTime > self.elapsedTime : currentTime < self.elapsedTime else { return }
		}

		self.elapsedTime = currentTime
		self.updateProgressControls()
	}
}
