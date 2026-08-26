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

#if targetEnvironment(macCatalyst)
import Obfuscation
#endif

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


	/// The button that dismisses the fullscreen player.
	private let closeButton = TrailerFullscreenViewController.makeControlButton(pointSize: 14.0, diameter: 40.0)

	/// The button that plays or pauses the trailer.
	private let playPauseButton = TrailerFullscreenViewController.makeControlButton(pointSize: 24.0, diameter: 64.0)

	/// The button that toggles the trailer's sound.
	private let muteButton = TrailerFullscreenViewController.makeControlButton(pointSize: 14.0, diameter: 40.0)

	/// The button that jumps back through the trailer.
	private let skipBackwardButton = TrailerFullscreenViewController.makeControlButton(pointSize: 16.0, diameter: 44.0)

	/// The button that jumps forward through the trailer.
	private let skipForwardButton = TrailerFullscreenViewController.makeControlButton(pointSize: 16.0, diameter: 44.0)

	/// The button that chooses how fast the trailer plays.
	private let speedButton = TrailerFullscreenViewController.makeControlButton(pointSize: 13.0, diameter: 40.0)

	/// The slider that scrubs through the trailer.
	private let scrubber: UISlider = {
		let slider = UISlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.overrideUserInterfaceStyle = .dark
		#if !targetEnvironment(macCatalyst)
		slider.minimumTrackTintColor = .white
		slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
		#endif
		slider.minimumValue = 0.0
		slider.maximumValue = 1.0
		// Takes the slack in the row, so the time labels and buttons keep their intrinsic width.
		slider.setContentHuggingPriority(.init(1.0), for: .horizontal)
		return slider
	}()

	/// The label showing how far the trailer has played.
	private let elapsedTimeLabel = TrailerFullscreenViewController.makeTimeLabel()

	/// The label showing the trailer's length.
	private let durationLabel = TrailerFullscreenViewController.makeTimeLabel()

	#if targetEnvironment(macCatalyst)
	/// The floating bar the Mac drives playback from, matching the system's own video controls.
	private let controlBar = TrailerPlayerControlBar()
	#endif

	// MARK: - Properties
	/// The frame the trailer occupies on the page, in window coordinates.
	var sourceFrame: CGRect?

	/// The view the trailer came from, which takes its player back on dismissal.
	weak var sourceTrailerView: KTrailerPlayerView?

	/// Shares what the trailer belongs to, from the given view.
	var shareHandler: ((UIView) -> Void)?

	/// The controls that fade in once the trailer fills the screen.
	var chromeViews: [UIView] {
		#if targetEnvironment(macCatalyst)
		return [self.closeButton, self.controlBar]
		#else
		return [self.closeButton, self.playPauseButton, self.muteButton, self.skipBackwardButton, self.skipForwardButton, self.speedButton, self.scrubber, self.elapsedTimeLabel, self.durationLabel]
		#endif
	}

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

	/// The task running the trailer while a seek button is held.
	private var fastSeekTask: Task<Void, Never>?

	/// A Boolean value indicating whether the trailer was playing before a seek button was held.
	private var wasPlayingBeforeFastSeek = false

	/// A Boolean value indicating whether a held seek button runs the trailer forwards.
	private var isFastSeekingForward = true

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

	#if targetEnvironment(macCatalyst)
	/// A Boolean value indicating whether the scrubber's filled track has been colored.
	private var didApplyTrackFill = false
	#endif

	/// The identifier of the trailer to play.
	private let videoID: String

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
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .allButUpsideDown
	}

	override var keyCommands: [UIKeyCommand]? {
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
			// The plus lives on the equals key; both readings work, shifted or not.
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

		#if targetEnvironment(macCatalyst)
		self.applyTrackFill()
		#endif
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		TrailerPlaybackCoordinator.shared.beginFullscreen()

		// Attached before the zoom runs, so the trailer is on screen as it grows.
		let player = TrailerPlayerPool.shared.player(forVideoID: self.videoID)
		self.player = player
		player.attach(to: self.contentView, isMuted: self.isMuted, delegate: self)

		if self.resumesPlayback {
			player.play()
		}

		self.isPlaying = self.resumesPlayback

		#if targetEnvironment(macCatalyst)
		// The floating-window and device-picker requests are pressed into the page itself.
		player.setInteractionEnabled(true)
		#endif
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.becomeFirstResponder()
		self.updateControls(animated: false)
		self.scheduleControlsAutoHide()

		#if targetEnvironment(macCatalyst)
		// However the window leaves fullscreen, the player leaves with it.
		self.macFullscreenObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("NSWindowDidExitFullScreenNotification"), object: nil, queue: .main) { [weak self] _ in
			MainActor.assumeIsolated {
				guard let self = self else { return }
				self.didEnterMacFullscreen = false
				self.dismiss(animated: false)
			}
		}

		// The fullscreen transition clears the window's focus; it is taken back once settled.
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

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		self.controlsHideTask?.cancel()
		self.controlsHideTask = nil

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

		if let sourceTrailerView = self.sourceTrailerView {
			sourceTrailerView.reclaimPlayerFromFullscreen()
		} else {
			self.player?.detach()
		}

		self.player = nil
		TrailerPlaybackCoordinator.shared.endFullscreen()
	}

	// MARK: - Functions
	/// Dismisses the fullscreen player.
	@objc private func close() {
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
		#endif
	}

	/// Toggles the trailer's sound in response to the mute button.
	@objc private func toggleMute() {
		self.isMuted.toggle()
		self.player?.setMuted(self.isMuted)
		self.updateControls(animated: false)
		self.scheduleControlsAutoHide()
	}

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
			#endif

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

		#if targetEnvironment(macCatalyst)
		self.controlBar.setPlaying(self.isPlaying)
		self.controlBar.setVolume(self.isMuted ? 0.0 : (self.player?.volume ?? 1.0))
		#endif

		self.setControls(visible: true, animated: animated)
	}

	/// Shows or hides the transient controls.
	///
	/// - Parameters:
	///    - visible: Whether the controls are shown.
	///    - animated: Whether the change is animated.
	private func setControls(visible: Bool, animated: Bool) {
		var transientViews = [self.playPauseButton, self.muteButton, self.skipBackwardButton, self.skipForwardButton, self.speedButton, self.scrubber, self.elapsedTimeLabel, self.durationLabel] as [UIView]

		#if targetEnvironment(macCatalyst)
		transientViews = [self.controlBar]
		#endif

		self.areControlsVisible = visible

		// A hidden control still takes presses, which would swallow the tap asking for it back.
		transientViews.forEach { $0.isUserInteractionEnabled = visible }

		let apply = {
			transientViews.forEach { $0.alpha = visible ? 1.0 : 0.0 }
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
		// Scroll gestures carry no touches; a pointer drag does, and is left alone.
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
		self.fastSeekTask?.cancel()

		// Holding starts above whatever speed is already chosen, so 2× playback begins the climb at 5×.
		self.fastSeekBaseIndex = self.fastSeekRates.firstIndex { $0 > self.playbackRate } ?? 0
		self.fastSeekRateIndex = self.fastSeekBaseIndex
		self.runFastSeek()
	}

	/// Sets the ladder's rung for how hard the held seek button is pressed.
	///
	/// - Parameter progression: The press beyond the opening click, from `0` to `1`.
	private func setFastSeekProgression(_ progression: Double) {
		let stepCount = self.fastSeekRates.count - 1 - self.fastSeekBaseIndex
		guard stepCount > 0 else { return }

		let steps = min(stepCount, Int((progression * Double(stepCount)).rounded()))
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

		self.fastSeekTask?.cancel()

		if self.isFastSeekingForward {
			self.player?.setPlaybackRate(2.0)
			self.player?.play()

			guard rate > 2.0 else {
				self.fastSeekTask = nil
				return
			}

			let tickDuration = 0.25
			self.fastSeekTask = Task { @MainActor [weak self] in
				while !Task.isCancelled {
					try? await Task.sleep(nanoseconds: UInt64(tickDuration * 1_000_000_000.0))
					guard !Task.isCancelled, let self = self else { return }
					self.seek(to: self.elapsedTime + rate * tickDuration)
				}
			}
		} else {
			self.player?.pause()

			let tickDuration = 0.1
			self.fastSeekTask = Task { @MainActor [weak self] in
				while !Task.isCancelled {
					guard let self = self else { return }
					self.seek(to: self.elapsedTime - rate * tickDuration)
					try? await Task.sleep(nanoseconds: UInt64(tickDuration * 1_000_000_000.0))
				}
			}
		}
	}

	/// Returns the trailer to the speed and play state it was at before the button was held.
	private func endFastSeek() {
		self.fastSeekTask?.cancel()
		self.fastSeekTask = nil

		self.player?.setPlaybackRate(self.playbackRate)

		if self.wasPlayingBeforeFastSeek {
			self.player?.play()
		} else {
			self.player?.pause()
		}

		self.scheduleControlsAutoHide()
	}

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
		self.elapsedTimeLabel.text = Self.timeText(forSeconds: Double(self.scrubber.value) * self.duration)
	}

	/// Plays from the point the reader dragged to.
	@objc private func scrubbingDidEnd() {
		self.isScrubbing = false

		if self.duration > 0.0 {
			self.seek(to: Double(self.scrubber.value) * self.duration)
		}

		self.scheduleControlsAutoHide()
	}

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

	/// Builds the menu that chooses how fast the trailer plays.
	private func configureSpeedButton() {
		self.speedButton.showsMenuAsPrimaryAction = true
		self.speedButton.accessibilityLabel = L10n.playbackSpeed
		self.updateSpeedButton()
	}

	/// Applies the current speed to the button's title and menu.
	private func updateSpeedButton() {
		let title = Self.speedText(forRate: self.playbackRate)

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.speedButton.configuration?.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 13.0, weight: .semibold), .foregroundColor: UIColor.white]))
		} else {
			self.speedButton.setTitle(title, for: .normal)
			self.speedButton.setTitleColor(.white, for: .normal)
			self.speedButton.titleLabel?.font = .systemFont(ofSize: 13.0, weight: .semibold)
		}

		self.speedButton.menu = UIMenu(children: self.playbackRates.map { rate in
			UIAction(title: Self.speedText(forRate: rate), state: rate == self.playbackRate ? .on : .off) { [weak self] _ in
				self?.setPlaybackRate(rate)
			}
		})
	}

	/// Sets how fast the trailer plays.
	///
	/// - Parameter rate: The multiple of normal speed to play at.
	private func setPlaybackRate(_ rate: Double) {
		self.playbackRate = rate
		self.player?.setPlaybackRate(rate)
		self.updateSpeedButton()

		#if targetEnvironment(macCatalyst)
		self.controlBar.setPlaybackRate(rate)
		#endif

		self.scheduleControlsAutoHide()
	}

	/// Moves the scrubber and time labels to the current point.
	private func updateProgressControls() {
		self.elapsedTimeLabel.text = Self.timeText(forSeconds: self.elapsedTime)
		self.durationLabel.text = Self.timeText(forSeconds: self.duration)

		#if targetEnvironment(macCatalyst)
		self.controlBar.setProgress(elapsedTime: self.elapsedTime, duration: self.duration)
		#endif

		guard !self.isScrubbing, self.duration > 0.0 else { return }
		self.scrubber.value = Float(self.elapsedTime / self.duration)
	}

	/// Pins the player and controls in the view.
	private func configureViews() {
		self.view.backgroundColor = .clear
		self.view.addSubview(self.backdropView)
		self.view.addSubview(self.zoomWindowView)
		self.zoomWindowView.addSubview(self.zoomScrollView)
		self.zoomScrollView.addSubview(self.contentView)
		self.zoomScrollView.delegate = self
		self.view.addSubview(self.closeButton)

		let transportStackView = UIStackView(arrangedSubviews: [self.skipBackwardButton, self.playPauseButton, self.skipForwardButton])
		transportStackView.translatesAutoresizingMaskIntoConstraints = false
		transportStackView.alignment = .center
		transportStackView.spacing = 28.0
		self.view.addSubview(transportStackView)

		let scrubberStackView = UIStackView(arrangedSubviews: [self.elapsedTimeLabel, self.scrubber, self.durationLabel, self.speedButton, self.muteButton])
		scrubberStackView.translatesAutoresizingMaskIntoConstraints = false
		scrubberStackView.alignment = .center
		scrubberStackView.spacing = 12.0
		self.view.addSubview(scrubberStackView)

		// The gestures live on the view itself, leaving the picture's presses to the embed.
		let revealGesture = UITapGestureRecognizer(target: self, action: #selector(self.toggleControlsVisibility))
		revealGesture.cancelsTouchesInView = false
		revealGesture.delegate = self
		self.view.addGestureRecognizer(revealGesture)

		// A double press leaves fullscreen, so a single press waits out the chance of a second.
		let exitGesture = UITapGestureRecognizer(target: self, action: #selector(self.close))
		exitGesture.numberOfTapsRequired = 2
		exitGesture.cancelsTouchesInView = false
		exitGesture.delegate = self
		self.view.addGestureRecognizer(exitGesture)
		revealGesture.require(toFail: exitGesture)

		let pointerGesture = UIHoverGestureRecognizer(target: self, action: #selector(self.handlePointerMovement(_:)))
		self.view.addGestureRecognizer(pointerGesture)
		self.closeButton.addTarget(self, action: #selector(self.close), for: .primaryActionTriggered)
		self.playPauseButton.addTarget(self, action: #selector(self.togglePlayPause), for: .primaryActionTriggered)
		self.muteButton.addTarget(self, action: #selector(self.toggleMute), for: .primaryActionTriggered)
		self.skipBackwardButton.addTarget(self, action: #selector(self.skipBackward), for: .primaryActionTriggered)
		self.skipForwardButton.addTarget(self, action: #selector(self.skipForward), for: .primaryActionTriggered)

		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidBegin), for: [.touchDown])
		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidChange), for: [.valueChanged])
		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])

		self.closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
		self.closeButton.accessibilityLabel = L10n.dismiss
		self.closeButton.alpha = 1.0

		self.skipBackwardButton.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
		self.skipBackwardButton.accessibilityLabel = L10n.skipBackward
		self.skipForwardButton.setImage(UIImage(systemName: "goforward.10"), for: .normal)
		self.skipForwardButton.accessibilityLabel = L10n.skipForward

		self.configureSpeedButton()

		let scrubGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleScrubGesture(_:)))
		#if targetEnvironment(macCatalyst)
		// The Mac scrubs from a two-finger swipe, which arrives as a scroll rather than a drag.
		scrubGesture.allowedScrollTypesMask = .all
		#endif
		scrubGesture.cancelsTouchesInView = false
		scrubGesture.delegate = self
		self.view.addGestureRecognizer(scrubGesture)

		#if targetEnvironment(macCatalyst)
		// The Mac drives playback from the floating bar.
		[self.playPauseButton, self.muteButton, self.skipBackwardButton, self.skipForwardButton, self.speedButton, self.scrubber, self.elapsedTimeLabel, self.durationLabel].forEach { $0.isHidden = true }

		self.controlBar.translatesAutoresizingMaskIntoConstraints = false
		self.controlBar.delegate = self
		self.view.addSubview(self.controlBar)
		self.controlBar.reloadOptionsMenu()
		#endif

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

			self.closeButton.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			self.closeButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			self.closeButton.widthAnchor.constraint(equalToConstant: 40.0),
			self.closeButton.heightAnchor.constraint(equalToConstant: 40.0),

			transportStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			transportStackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),

			self.playPauseButton.widthAnchor.constraint(equalToConstant: 64.0),
			self.playPauseButton.heightAnchor.constraint(equalToConstant: 64.0),
			self.skipBackwardButton.widthAnchor.constraint(equalToConstant: 44.0),
			self.skipBackwardButton.heightAnchor.constraint(equalToConstant: 44.0),
			self.skipForwardButton.widthAnchor.constraint(equalToConstant: 44.0),
			self.skipForwardButton.heightAnchor.constraint(equalToConstant: 44.0),

			scrubberStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			scrubberStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			scrubberStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

			self.speedButton.widthAnchor.constraint(equalToConstant: 44.0),
			self.speedButton.heightAnchor.constraint(equalToConstant: 40.0),
			self.muteButton.widthAnchor.constraint(equalToConstant: 40.0),
			self.muteButton.heightAnchor.constraint(equalToConstant: 40.0)
		])

		#if targetEnvironment(macCatalyst)
		NSLayoutConstraint.activate([
			self.controlBar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.controlBar.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -24.0)
		])
		#endif
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

	/// Builds a label for a point in the trailer's timeline.
	///
	/// - Returns: A configured label.
	private static func makeTimeLabel() -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .monospacedDigitSystemFont(ofSize: 12.0, weight: .medium)
		label.textColor = .white
		label.text = Self.timeText(forSeconds: 0.0)
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
		let speedActions = self.playbackRates.map { rate in
			UIAction(title: Self.speedText(forRate: rate), state: rate == self.playbackRate ? .on : .off) { [weak self] _ in
				self?.setPlaybackRate(rate)
			}
		}

		var children: [UIMenuElement] = []

		if let shareHandler = self.shareHandler {
			children.append(UIAction(title: L10n.share, image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
				guard let self = self else { return }
				shareHandler(self.controlBar)
			})
		}

		children.append(UIMenu(title: L10n.playbackSpeed, image: UIImage(systemName: "speedometer"), children: speedActions))
		children.append(UIMenu(title: L10n.videoQuality, image: UIImage(systemName: "sparkles.tv"), children: self.qualityMenuActions()))

		return UIMenu(children: children)
	}

	/// Builds the actions that choose the trailer's quality.
	///
	/// - Returns: An action per quality level the video offers, led by automatic.
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
	/// - Parameter level: The quality level to hold, with `auto` letting the video adapt.
	private func setPreferredQuality(_ level: String) {
		self.player?.setPreferredQualityLevel(level)
		self.scheduleControlsAutoHide()
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

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		// A press on the bar is the bar's — its buttons, its drag, or the two spots it leaves open for
		// the page — so only presses on the picture itself toggle the controls.
		#if targetEnvironment(macCatalyst)
		if self.areControlsVisible, self.controlBar.frame.contains(touch.location(in: self.view)) {
			return false
		}
		#endif

		return true
	}
}

// MARK: - UIViewControllerTransitioningDelegate
extension TrailerFullscreenViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return TrailerFullscreenTransitionAnimator(isPresenting: true, sourceFrame: self.sourceFrame)
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return TrailerFullscreenTransitionAnimator(isPresenting: false, sourceFrame: self.sourceFrame)
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

	func trailerWebPlayerDidRevealPicture(_ trailerWebPlayer: TrailerWebPlayer) {}

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

		self.elapsedTime = currentTime
		self.updateProgressControls()
	}
}
