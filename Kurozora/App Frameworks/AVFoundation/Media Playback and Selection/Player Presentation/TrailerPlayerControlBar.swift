//
//  TrailerPlayerControlBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVKit
import UIKit

#if targetEnvironment(macCatalyst)
import Obfuscation
#endif

/// Reports what the reader asked of a floating trailer control bar.
@MainActor
protocol TrailerPlayerControlBarDelegate: AnyObject {
	/// Tells the delegate the reader asked to play or pause.
	///
	/// - Parameter controlBar: The bar reporting the request.
	func trailerPlayerControlBarDidTogglePlayback(_ controlBar: TrailerPlayerControlBar)

	/// Tells the delegate the reader asked to move through the trailer.
	///
	/// - Parameters:
	///    - controlBar: The bar reporting the request.
	///    - seconds: The point to play from.
	func trailerPlayerControlBar(_ controlBar: TrailerPlayerControlBar, didSeekTo seconds: Double)

	/// Tells the delegate the reader took hold of the scrubber.
	///
	/// - Parameter controlBar: The bar reporting the change.
	func trailerPlayerControlBarDidBeginScrubbing(_ controlBar: TrailerPlayerControlBar)

	/// Tells the delegate the reader let the scrubber go.
	///
	/// - Parameter controlBar: The bar reporting the change.
	func trailerPlayerControlBarDidEndScrubbing(_ controlBar: TrailerPlayerControlBar)

	/// Tells the delegate the reader changed how loud the trailer plays.
	///
	/// - Parameters:
	///    - controlBar: The bar reporting the change.
	///    - volume: The loudness, from silent at `0` to full at `1`.
	func trailerPlayerControlBar(_ controlBar: TrailerPlayerControlBar, didChangeVolume volume: Double)

	/// Tells the delegate the reader is holding a seek button.
	///
	/// - Parameters:
	///    - controlBar: The bar reporting the request.
	///    - isForward: Whether the trailer runs forwards.
	func trailerPlayerControlBar(_ controlBar: TrailerPlayerControlBar, didBeginFastSeekForward isForward: Bool)

	/// Tells the delegate how much harder than its opening click a held seek button is pressed.
	///
	/// - Parameters:
	///    - controlBar: The bar reporting the change.
	///    - progression: The press beyond the opening click, from `0` to `1` at the trackpad's deepest.
	func trailerPlayerControlBar(_ controlBar: TrailerPlayerControlBar, didChangeFastSeekProgression progression: Double)

	/// Tells the delegate the reader let a seek button go.
	///
	/// - Parameter controlBar: The bar reporting the request.
	func trailerPlayerControlBarDidEndFastSeek(_ controlBar: TrailerPlayerControlBar)

	/// Tells the delegate the reader asked for a floating window.
	///
	/// - Parameter controlBar: The bar reporting the request.
	func trailerPlayerControlBarDidRequestPictureInPicture(_ controlBar: TrailerPlayerControlBar)

	/// Returns the menu of extra actions for the trailing control.
	///
	/// - Parameter controlBar: The bar asking for the menu.
	///
	/// - Returns: The menu to show.
	func trailerPlayerControlBarOptionsMenu(_ controlBar: TrailerPlayerControlBar) -> UIMenu
}

/// A floating control bar for a trailer, matching the system's own video controls on the Mac.
final class TrailerPlayerControlBar: UIView {
	// MARK: - Views
	/// The bar's translucent background.
	private let backgroundEffectView: UIVisualEffectView = {
		let effectView = UIVisualEffectView()

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			let glassEffect = UIGlassEffect()
			glassEffect.isInteractive = true
			effectView.effect = glassEffect
		} else {
			effectView.effect = UIBlurEffect(style: .systemThickMaterialDark)
		}

		effectView.translatesAutoresizingMaskIntoConstraints = false
		effectView.isUserInteractionEnabled = false
		effectView.clipsToBounds = true
		effectView.layer.cornerCurve = .continuous
		return effectView
	}()

	/// The button silencing the trailer, which also shows how loud it is.
	private let volumeButton = TrailerPlayerControlBar.makeGlyphButton(systemName: "speaker.wave.2.fill", pointSize: 14.0)

	/// The slider setting how loud the trailer plays.
	private let volumeSlider = TrailerPlayerControlBar.makeSlider()

	/// The row holding the volume controls, which a swipe over adjusts the volume through.
	private lazy var volumeStackView = UIStackView(arrangedSubviews: [self.volumeButton, self.volumeSlider])

	/// The button moving playback back through the trailer.
	private let rewindButton = TrailerPlayerControlBar.makeGlyphButton(systemName: "backward.fill", pointSize: 16.0)

	/// The button playing or pausing the trailer.
	private let playPauseButton = TrailerPlayerControlBar.makeGlyphButton(systemName: "play.fill", pointSize: 26.0)

	/// The button moving playback forward through the trailer.
	private let forwardButton = TrailerPlayerControlBar.makeGlyphButton(systemName: "forward.fill", pointSize: 16.0)

	/// The label showing how fast a held rewind is running.
	private let rewindRateLabel = TrailerPlayerControlBar.makeRateLabel()

	/// The label showing how fast a held fast forward is running.
	private let forwardRateLabel = TrailerPlayerControlBar.makeRateLabel()

	/// The control asking to play on another device.
	private let airPlayRoutePickerView: AVRoutePickerView = {
		let routePickerView = AVRoutePickerView()
		routePickerView.translatesAutoresizingMaskIntoConstraints = false
		routePickerView.tintColor = UIColor(white: 0.82, alpha: 1.0)
		routePickerView.activeTintColor = .white
		routePickerView.prioritizesVideoDevices = true
		return routePickerView
	}()

	/// The button asking for a floating window.
	private let pictureInPictureButton = TrailerPlayerControlBar.makeGlyphButton(systemName: "pip.enter", pointSize: 15.0)

	/// The button showing the remaining options.
	private let optionsButton = TrailerPlayerControlBar.makeGlyphButton(systemName: "chevron.right.2", pointSize: 15.0, weight: .semibold)

	/// The reading showing how far the trailer has played, rolling its digits in the frame count.
	private let elapsedCounterView: RollingCounterView = {
		let counterView = RollingCounterView(font: .monospacedDigitSystemFont(ofSize: 12.0, weight: .regular), textColor: UIColor(white: 0.86, alpha: 1.0))
		counterView.translatesAutoresizingMaskIntoConstraints = false
		return counterView
	}()

	/// The label showing the trailer's length.
	private let durationLabel = TrailerPlayerControlBar.makeTimeLabel()

	/// The glyph the play or pause button shows, swapped with the system's replace transition.
	private let playPauseSymbolImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26.0, weight: .regular)))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.tintColor = UIColor(white: 0.82, alpha: 1.0)
		imageView.isUserInteractionEnabled = false
		return imageView
	}()

	/// The conveyor glyph riding the rewind button, matching the music controls' skip animation.
	private let rewindChevronView = SkipChevronView(direction: .backward)

	/// The conveyor glyph riding the fast-forward button, matching the music controls' skip animation.
	private let forwardChevronView = SkipChevronView(direction: .forward)

	/// The slider scrubbing through the trailer.
	private let scrubber = TrailerPlayerControlBar.makeSlider()

	// MARK: - Properties
	/// The object told what the reader asked of the bar.
	weak var delegate: TrailerPlayerControlBarDelegate?

	/// A Boolean value indicating whether the reader is dragging the scrubber.
	private(set) var isScrubbing = false

	/// A Boolean value indicating whether the reader is working one of the bar's controls.
	var isEngaged: Bool {
		return self.isScrubbing || self.volumeSlider.isTracking || self.fastSeekTask != nil
	}

	/// The trailer's length in seconds.
	private var duration = 0.0

	/// The seconds played so far.
	private var elapsedTime = 0.0

	/// The frames the trailer shows each second, once it can be worked out.
	private var framesPerSecond: Double?

	/// A Boolean value indicating whether the trailer is playing.
	private var isPlaying = false

	/// A Boolean value indicating whether a seek button is being held.
	private var isFastSeeking = false

	/// The name of the symbol the play or pause button shows.
	private var playPauseSymbolName = "play.fill"

	/// The task stepping the held skip button's conveyor.
	private var conveyorTask: Task<Void, Never>?

	/// The clock stepping the frame count between the player's progress reports.
	private var frameTicker: CADisplayLink?

	/// The clock's reading at its previous step.
	private var lastTickTimestamp: CFTimeInterval = 0.0

	/// The speed the trailer is playing at, which paces the clock.
	private var playbackRate = 1.0

	/// The reading shown while the trailer's length is not known.
	private static let timePlaceholder = "--:--"

	/// The frame reading shown while the trailer's length is not known.
	private static let framePlaceholder = "-- F"

	/// A Boolean value indicating whether the length label shows the time left instead.
	private var showsTimeRemaining = false

	/// A Boolean value indicating whether the elapsed label counts frames instead of time.
	private(set) var showsFrames = false

	/// The task waiting to turn a held seek button into fast playback.
	private var fastSeekTask: Task<Void, Never>?

	/// A Boolean value indicating whether the held seek button runs the trailer forwards.
	private var isFastSeekingForward = true

	#if targetEnvironment(macCatalyst)
	/// The monitor reading how hard the trackpad presses a held seek button.
	private var pressureMonitor: TrackpadPressureMonitor?
	#endif

	/// The bar's centre when the current drag began.
	private var dragOriginCenter: CGPoint = .zero

	/// The distance from the screen's centre the bar settles onto it from.
	private let centerSnapDistance = 18.0

	/// The speed a drag has to stay under for the bar to settle onto the centre.
	private let centerSnapSpeed = 220.0

	#if targetEnvironment(macCatalyst)
	/// A Boolean value indicating whether the sliders' filled tracks have been colored.
	private var didApplyTrackFill = false
	#endif

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.backgroundEffectView.layer.cornerRadius = 28.0

		#if targetEnvironment(macCatalyst)
		self.applyTrackFill()
		#endif
	}

	override var intrinsicContentSize: CGSize {
		return CGSize(width: 468.0, height: 99.0)
	}

	// MARK: - Functions
	/// Shows the given play state.
	///
	/// - Parameter isPlaying: Whether the trailer is playing.
	func setPlaying(_ isPlaying: Bool) {
		// A held seek button keeps showing the state playback returns to.
		guard !self.isFastSeeking else { return }

		self.isPlaying = isPlaying
		self.showPlayPauseSymbol(named: isPlaying ? "pause.fill" : "play.fill")
		self.playPauseButton.accessibilityLabel = isPlaying ? L10n.pause : L10n.play
		self.updateFrameTicker()
	}

	/// Swaps the play or pause glyph with the system's replace transition.
	///
	/// - Parameter symbolName: The name of the symbol to show.
	private func showPlayPauseSymbol(named symbolName: String) {
		guard symbolName != self.playPauseSymbolName else { return }
		self.playPauseSymbolName = symbolName

		guard let image = UIImage(systemName: symbolName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 26.0, weight: .regular)) else { return }

		if #available(iOS 17.0, macCatalyst 17.0, *) {
			self.playPauseSymbolImageView.setSymbolImage(image, contentTransition: .replace, options: .speed(1.8))
		} else {
			self.playPauseSymbolImageView.image = image
		}
	}

	/// Shows the given loudness.
	///
	/// - Parameter volume: The loudness, from silent at `0` to full at `1`.
	func setVolume(_ volume: Double) {
		if !self.volumeSlider.isTracking {
			self.volumeSlider.value = Float(volume)
		}

		// The bare speaker for silence, the way the system's own controls show it.
		let symbolName: String
		switch volume {
		case ..<0.01: symbolName = "speaker.fill"
		case ..<0.5: symbolName = "speaker.wave.1.fill"
		default: symbolName = "speaker.wave.2.fill"
		}

		self.volumeButton.setImage(UIImage(systemName: symbolName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 14.0, weight: .regular)), for: .normal)
	}

	/// Reports the trailer's frame rate.
	///
	/// - Parameter framesPerSecond: The frames shown each second.
	func setFramesPerSecond(_ framesPerSecond: Double?) {
		self.framesPerSecond = framesPerSecond
	}

	/// Shows the given point in the trailer.
	///
	/// - Parameters:
	///    - elapsedTime: The seconds played so far.
	///    - duration: The trailer's length in seconds.
	func setProgress(elapsedTime: Double, duration: Double) {
		self.duration = duration

		guard !self.isScrubbing else { return }

		// While the frame clock runs, the player's reports only correct drift.
		if self.frameTicker == nil || abs(elapsedTime - self.elapsedTime) > 0.35 {
			self.elapsedTime = elapsedTime
		}

		self.refreshProgressViews()
	}

	/// Sets how fast the trailer plays, pacing the frame clock with it.
	///
	/// - Parameter playbackRate: The multiple of normal speed.
	func setPlaybackRate(_ playbackRate: Double) {
		self.playbackRate = playbackRate
	}

	/// Writes the timeline's readings and moves the scrubber to the current point.
	private func refreshProgressViews() {
		self.updateTimeLabels()

		guard !self.isScrubbing, self.duration > 0.0 else { return }
		self.scrubber.value = Float(self.elapsedTime / self.duration)
	}

	/// Starts or stops the frame clock for the current state.
	private func updateFrameTicker() {
		let wantsTicker = self.showsFrames && self.isPlaying && !self.isScrubbing && !self.isFastSeeking

		if wantsTicker, self.frameTicker == nil {
			let ticker = CADisplayLink(target: self, selector: #selector(self.tickFrames(_:)))
			ticker.add(to: .main, forMode: .common)
			self.frameTicker = ticker
			self.lastTickTimestamp = 0.0
		} else if !wantsTicker, let ticker = self.frameTicker {
			ticker.invalidate()
			self.frameTicker = nil
		}
	}

	/// Steps the count along by the time one screen frame took.
	///
	/// - Parameter ticker: The clock reporting the step.
	@objc private func tickFrames(_ ticker: CADisplayLink) {
		if self.lastTickTimestamp > 0.0 {
			self.elapsedTime = min(self.elapsedTime + (ticker.timestamp - self.lastTickTimestamp) * self.playbackRate, self.duration)
			self.refreshProgressViews()
		}

		self.lastTickTimestamp = ticker.timestamp
	}

	/// Writes the timeline's two readings for what each is currently showing.
	private func updateTimeLabels() {
		guard self.duration > 0.0 else {
			let placeholder = self.showsFrames ? Self.framePlaceholder : Self.timePlaceholder
			self.elapsedCounterView.setText(placeholder, value: 0.0, rolling: false)
			self.durationLabel.text = placeholder
			return
		}

		if self.showsFrames, let framesPerSecond = self.framesPerSecond {
			let elapsedFrames = Int((self.elapsedTime * framesPerSecond).rounded())
			let totalFrames = Int((self.duration * framesPerSecond).rounded())
			self.elapsedCounterView.setText("\(elapsedFrames) F", value: Double(elapsedFrames), rolling: true)
			self.durationLabel.text = "\(totalFrames) F"
			return
		}

		self.elapsedCounterView.setText(Self.timeText(forSeconds: self.elapsedTime), value: self.elapsedTime, rolling: false)

		if self.showsTimeRemaining {
			self.durationLabel.text = "-" + Self.timeText(forSeconds: max(0.0, self.duration - self.elapsedTime))
		} else {
			self.durationLabel.text = Self.timeText(forSeconds: self.duration)
		}
	}

	/// Swaps the length reading for the time left, and back.
	@objc private func toggleTimeRemaining() {
		self.showsTimeRemaining.toggle()
		self.showsFrames = false
		self.updateTimeLabels()
	}

	/// Swaps the timeline for a frame count, and back.
	@objc private func toggleFrames() {
		self.setTimeDisplayShowsFrames(!self.showsFrames)
	}

	/// Reads the timeline as frames, or as time.
	///
	/// - Parameter showsFrames: Whether the timeline counts frames.
	func setTimeDisplayShowsFrames(_ showsFrames: Bool) {
		if showsFrames {
			guard self.framesPerSecond != nil else { return }
		}

		self.showsFrames = showsFrames
		self.updateTimeLabels()
		self.updateFrameTicker()
	}

	/// Moves the bar so it stays on screen after its host resizes.
	///
	/// - Parameter bounds: The area the bar may sit in.
	func keepInside(_ bounds: CGRect) {
		guard bounds.width > 0.0, bounds.height > 0.0 else { return }

		let halfWidth = self.bounds.width / 2.0
		let halfHeight = self.bounds.height / 2.0
		let clampedX = min(max(bounds.minX + halfWidth, self.center.x), bounds.maxX - halfWidth)
		let clampedY = min(max(bounds.minY + halfHeight, self.center.y), bounds.maxY - halfHeight)
		self.center = CGPoint(x: clampedX, y: clampedY)
	}

	/// Applies the menu the delegate offers for the trailing control.
	func reloadOptionsMenu() {
		self.optionsButton.showsMenuAsPrimaryAction = true
		self.optionsButton.menu = UIMenu(children: [
			UIDeferredMenuElement.uncached { [weak self] completion in
				guard let self = self, let menu = self.delegate?.trailerPlayerControlBarOptionsMenu(self) else {
					completion([])
					return
				}

				completion(menu.children)
			}
		])
	}

	/// Builds the bar's contents and gestures.
	private func sharedInit() {
		// The system's video controls stay dark whatever is playing behind them.
		self.overrideUserInterfaceStyle = .dark
		self.addSubview(self.backgroundEffectView)

		let volumeStackView = self.volumeStackView
		volumeStackView.translatesAutoresizingMaskIntoConstraints = false
		volumeStackView.alignment = .center
		volumeStackView.spacing = 10.0

		let transportStackView = UIStackView(arrangedSubviews: [self.rewindRateLabel, self.rewindButton, self.playPauseButton, self.forwardButton, self.forwardRateLabel])
		transportStackView.translatesAutoresizingMaskIntoConstraints = false
		transportStackView.alignment = .center
		transportStackView.spacing = 8.0

		let outputStackView = UIStackView(arrangedSubviews: [self.airPlayRoutePickerView, self.pictureInPictureButton, self.optionsButton])
		outputStackView.translatesAutoresizingMaskIntoConstraints = false
		outputStackView.alignment = .center
		outputStackView.spacing = 20.0

		let progressStackView = UIStackView(arrangedSubviews: [self.elapsedCounterView, self.scrubber, self.durationLabel])
		progressStackView.translatesAutoresizingMaskIntoConstraints = false
		progressStackView.alignment = .center
		progressStackView.spacing = 12.0

		[volumeStackView, transportStackView, outputStackView, progressStackView].forEach { self.addSubview($0) }

		self.playPauseButton.addTarget(self, action: #selector(self.togglePlayback), for: .primaryActionTriggered)
		self.volumeButton.addTarget(self, action: #selector(self.toggleMute), for: .primaryActionTriggered)

		// The speaker body stays put while the waves come and go, instead of re-centering per state.
		self.volumeButton.contentHorizontalAlignment = .leading

		self.elapsedCounterView.isUserInteractionEnabled = true
		self.elapsedCounterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.toggleFrames)))
		self.durationLabel.isUserInteractionEnabled = true
		self.durationLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.toggleTimeRemaining)))

		// The transport glyphs live in their own views so they can run the music controls' animations.
		self.playPauseButton.setImage(nil, for: .normal)
		self.playPauseSymbolImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26.0, weight: .regular)
		self.playPauseButton.addSubview(self.playPauseSymbolImageView)
		self.rewindButton.setImage(nil, for: .normal)
		self.rewindChevronView.translatesAutoresizingMaskIntoConstraints = false
		self.rewindChevronView.setMetrics(pointSize: 15.0, spacing: 11.0)
		self.rewindButton.addSubview(self.rewindChevronView)
		self.forwardButton.setImage(nil, for: .normal)
		self.forwardChevronView.translatesAutoresizingMaskIntoConstraints = false
		self.forwardChevronView.setMetrics(pointSize: 15.0, spacing: 11.0)
		self.forwardButton.addSubview(self.forwardChevronView)

		self.elapsedCounterView.setText(Self.timePlaceholder, value: 0.0, rolling: false)

		self.rewindButton.addTarget(self, action: #selector(self.rewindDidBegin), for: [.touchDown])
		self.rewindButton.addTarget(self, action: #selector(self.rewindDidEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])
		self.forwardButton.addTarget(self, action: #selector(self.forwardDidBegin), for: [.touchDown])
		self.forwardButton.addTarget(self, action: #selector(self.forwardDidEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])

		self.volumeSlider.addTarget(self, action: #selector(self.volumeDidChange), for: .valueChanged)
		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidBegin), for: [.touchDown])
		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidChange), for: [.valueChanged])
		self.scrubber.addTarget(self, action: #selector(self.scrubbingDidEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])

		self.pictureInPictureButton.addTarget(self, action: #selector(self.requestPictureInPicture), for: .primaryActionTriggered)

		self.rewindButton.accessibilityLabel = L10n.skipBackward
		self.forwardButton.accessibilityLabel = L10n.skipForward
		self.airPlayRoutePickerView.accessibilityLabel = L10n.airPlay
		self.pictureInPictureButton.accessibilityLabel = L10n.pictureInPicture
		self.volumeButton.accessibilityLabel = L10n.volume
		self.optionsButton.accessibilityLabel = L10n.more

		let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDrag(_:)))
		dragGesture.delegate = self
		self.addGestureRecognizer(dragGesture)

		self.layoutMargins = UIEdgeInsets(top: 14.0, left: 24.0, bottom: 14.0, right: 24.0)
		let layoutMarginsGuide = self.layoutMarginsGuide

		NSLayoutConstraint.activate([
			self.backgroundEffectView.topAnchor.constraint(equalTo: self.topAnchor),
			self.backgroundEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.backgroundEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.backgroundEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			volumeStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			volumeStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			self.volumeSlider.widthAnchor.constraint(equalToConstant: 80.0),
			// A fixed width keeps the slider still while the glyph changes between its wave states.
			self.volumeButton.widthAnchor.constraint(equalToConstant: 22.0),
			self.volumeButton.heightAnchor.constraint(equalToConstant: 24.0),

			transportStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			transportStackView.centerYAnchor.constraint(equalTo: volumeStackView.centerYAnchor),
			// Fixed sizes keep the row still while glyphs swap.
			self.playPauseButton.widthAnchor.constraint(equalToConstant: 36.0),
			self.playPauseButton.heightAnchor.constraint(equalToConstant: 36.0),
			self.rewindButton.widthAnchor.constraint(equalToConstant: 32.0),
			self.rewindButton.heightAnchor.constraint(equalToConstant: 32.0),
			self.forwardButton.widthAnchor.constraint(equalToConstant: 32.0),
			self.forwardButton.heightAnchor.constraint(equalToConstant: 32.0),
			self.rewindRateLabel.widthAnchor.constraint(equalToConstant: 30.0),
			self.forwardRateLabel.widthAnchor.constraint(equalToConstant: 30.0),

			outputStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			outputStackView.centerYAnchor.constraint(equalTo: volumeStackView.centerYAnchor),
			outputStackView.leadingAnchor.constraint(greaterThanOrEqualTo: transportStackView.trailingAnchor, constant: 16.0),
			self.airPlayRoutePickerView.widthAnchor.constraint(equalToConstant: 30.0),
			self.airPlayRoutePickerView.heightAnchor.constraint(equalToConstant: 28.0),

			progressStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			progressStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			progressStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
			progressStackView.topAnchor.constraint(greaterThanOrEqualTo: transportStackView.bottomAnchor, constant: 4.0),

			self.playPauseSymbolImageView.centerXAnchor.constraint(equalTo: self.playPauseButton.centerXAnchor),
			self.playPauseSymbolImageView.centerYAnchor.constraint(equalTo: self.playPauseButton.centerYAnchor),
			self.rewindChevronView.centerXAnchor.constraint(equalTo: self.rewindButton.centerXAnchor),
			self.rewindChevronView.centerYAnchor.constraint(equalTo: self.rewindButton.centerYAnchor),
			self.forwardChevronView.centerXAnchor.constraint(equalTo: self.forwardButton.centerXAnchor),
			self.forwardChevronView.centerYAnchor.constraint(equalTo: self.forwardButton.centerYAnchor)
		])
	}

	#if targetEnvironment(macCatalyst)
	/// Colors the hosted AppKit sliders' filled tracks.
	func applyTrackFill() {
		guard !self.didApplyTrackFill else { return }

		let selector = NSSelectorFromString(#obfuscated("setTrackFillColor:"))
		guard
			let colorClass = NSClassFromString("NSColor") as? NSObject.Type,
			let whiteColor = colorClass.perform(NSSelectorFromString("whiteColor"))?.takeUnretainedValue()
		else { return }

		var didApplyAll = true

		for slider in [self.volumeSlider, self.scrubber] {
			guard let appKitSlider = self.hostedAppKitControl(in: slider), appKitSlider.responds(to: selector) else {
				didApplyAll = false
				continue
			}

			appKitSlider.perform(selector, with: whiteColor)
		}

		self.didApplyTrackFill = didApplyAll
	}

	/// Returns the AppKit control the given slider hosts.
	///
	/// - Parameter slider: The slider to look inside.
	///
	/// - Returns: The hosted control.
	private func hostedAppKitControl(in slider: UISlider) -> NSObject? {
		let contentKey = #obfuscated("contentNSView")
		var candidates: [UIView] = [slider]

		while let view = candidates.popLast() {
			if view.responds(to: NSSelectorFromString(contentKey)), let hosted = view.value(forKey: contentKey) as? NSObject {
				return hosted
			}
			candidates.append(contentsOf: view.subviews)
		}

		return nil
	}
	#endif

	/// Moves the bar with the reader's drag, settling it onto the centre when eased close.
	///
	/// - Parameter gesture: The drag being followed.
	@objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
		guard let superview = self.superview else { return }

		switch gesture.state {
		case .began:
			self.dragOriginCenter = self.center
		case .changed:
			let translation = gesture.translation(in: superview)
			var proposedCenter = CGPoint(x: self.dragOriginCenter.x + translation.x, y: self.dragOriginCenter.y + translation.y)

			// Easing the bar near the middle settles it there, while a quick pass carries straight by.
			let speed = gesture.velocity(in: superview)
			let isEasing = abs(speed.x) < self.centerSnapSpeed
			if isEasing, abs(proposedCenter.x - superview.bounds.midX) < self.centerSnapDistance {
				proposedCenter.x = superview.bounds.midX
			}

			self.center = proposedCenter
			self.keepInside(superview.bounds.inset(by: superview.safeAreaInsets))
		default:
			break
		}
	}

	/// Asks the delegate for a floating window.
	@objc private func requestPictureInPicture() {
		self.delegate?.trailerPlayerControlBarDidRequestPictureInPicture(self)
	}

	/// Returns whether the given spot rests on the volume controls.
	///
	/// - Parameters:
	///    - point: The spot to test.
	///    - view: The view the spot is expressed in.
	///
	/// - Returns: `true` if the spot is on the volume controls.
	func isVolumeSpot(_ point: CGPoint, from view: UIView) -> Bool {
		let localPoint = self.convert(point, from: view)
		return self.volumeStackView.frame.insetBy(dx: -8.0, dy: -10.0).contains(localPoint)
	}

	/// Moves the volume by the given amount.
	///
	/// - Parameter delta: The change to apply, where the whole range spans `0` to `1`.
	func adjustVolume(by delta: Double) {
		let volume = min(max(0.0, Double(self.volumeSlider.value) + delta), 1.0)

		self.volumeSlider.value = Float(volume)
		self.setVolume(volume)
		self.delegate?.trailerPlayerControlBar(self, didChangeVolume: volume)
	}

	/// Asks the delegate to play or pause.
	@objc private func togglePlayback() {
		self.delegate?.trailerPlayerControlBarDidTogglePlayback(self)
	}

	/// Runs the trailer backwards at double speed while the button is held.
	@objc private func rewindDidBegin() {
		self.beginFastSeek(isForward: false)
	}

	/// Returns the trailer to normal, jumping back instead when the button was only tapped.
	@objc private func rewindDidEnd() {
		self.endFastSeek(tapStep: -10.0)
	}

	/// Runs the trailer forwards at double speed while the button is held.
	@objc private func forwardDidBegin() {
		self.beginFastSeek(isForward: true)
	}

	/// Returns the trailer to normal, jumping forward instead when the button was only tapped.
	@objc private func forwardDidEnd() {
		self.endFastSeek(tapStep: 10.0)
	}

	/// Asks the delegate to run the trailer fast after a short hold.
	///
	/// - Parameter isForward: Whether the trailer runs forwards.
	private func beginFastSeek(isForward: Bool) {
		self.fastSeekTask?.cancel()

		self.fastSeekTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 300_000_000)
			guard !Task.isCancelled, let self = self else { return }

			self.isFastSeeking = true
			self.isFastSeekingForward = isForward
			self.updateFrameTicker()
			self.delegate?.trailerPlayerControlBar(self, didBeginFastSeekForward: isForward)

			let chevronView = isForward ? self.forwardChevronView : self.rewindChevronView
			self.conveyorTask?.cancel()
			self.conveyorTask = Task { @MainActor [weak chevronView] in
				while !Task.isCancelled {
					chevronView?.animateSkip()
					try? await Task.sleep(nanoseconds: 500_000_000)
				}
			}

			#if targetEnvironment(macCatalyst)
			let pressureMonitor = self.pressureMonitor ?? TrackpadPressureMonitor { [weak self] progression in
				guard let self = self, self.isFastSeeking else { return }
				self.delegate?.trailerPlayerControlBar(self, didChangeFastSeekProgression: progression)
			}
			self.pressureMonitor = pressureMonitor
			pressureMonitor.start()
			#endif
		}
	}

	/// Returns the trailer to normal, treating a short press as a single jump.
	///
	/// - Parameter tapStep: The seconds to jump by when the button was tapped.
	private func endFastSeek(tapStep: Double) {
		self.fastSeekTask?.cancel()
		self.fastSeekTask = nil
		self.conveyorTask?.cancel()
		self.conveyorTask = nil

		#if targetEnvironment(macCatalyst)
		self.pressureMonitor?.stop()
		#endif

		guard self.isFastSeeking else {
			(tapStep < 0.0 ? self.rewindChevronView : self.forwardChevronView).animateSkip()
			self.delegate?.trailerPlayerControlBar(self, didSeekTo: self.elapsedTime + tapStep)
			return
		}

		self.isFastSeeking = false
		self.updateFrameTicker()
		self.setFastSeekRate(nil)
		self.delegate?.trailerPlayerControlBarDidEndFastSeek(self)

		// The real play state is written back after the run.
		self.setPlaying(self.isPlaying)
	}

	/// Shows how fast a held seek button is running.
	///
	/// - Parameters:
	///    - rate: The multiple of normal speed.
	///    - isForward: Whether the trailer runs forwards.
	func setFastSeekRate(_ rate: Double?, isForward: Bool? = nil) {
		if let isForward = isForward {
			self.isFastSeekingForward = isForward
		}

		let label = self.isFastSeekingForward ? self.forwardRateLabel : self.rewindRateLabel
		let otherLabel = self.isFastSeekingForward ? self.rewindRateLabel : self.forwardRateLabel
		otherLabel.alpha = 0.0

		guard let rate = rate else {
			label.alpha = 0.0
			return
		}

		label.text = Self.speedText(forRate: rate)

		self.showPlayPauseSymbol(named: "pause.fill")

		guard label.alpha == 0.0 else { return }
		UIView.animate(withDuration: 0.15) {
			label.alpha = 1.0
		}
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

	/// Silences the trailer, or restores it.
	@objc private func toggleMute() {
		let isSilent = self.volumeSlider.value <= 0.0
		let volume = isSilent ? 1.0 : 0.0

		self.volumeSlider.value = Float(volume)
		self.setVolume(volume)
		self.delegate?.trailerPlayerControlBar(self, didChangeVolume: volume)
	}

	/// Tells the delegate the loudness changed.
	@objc private func volumeDidChange() {
		let volume = Double(self.volumeSlider.value)
		self.setVolume(volume)
		self.delegate?.trailerPlayerControlBar(self, didChangeVolume: volume)
	}

	/// Holds the bar open while the reader drags the scrubber.
	@objc private func scrubbingDidBegin() {
		self.isScrubbing = true
		self.updateFrameTicker()
		self.delegate?.trailerPlayerControlBarDidBeginScrubbing(self)
	}

	/// Follows the drag live.
	@objc private func scrubbingDidChange() {
		guard self.duration > 0.0 else { return }

		let seconds = Double(self.scrubber.value) * self.duration

		if self.showsFrames, let framesPerSecond = self.framesPerSecond {
			let frames = Int((seconds * framesPerSecond).rounded())
			self.elapsedCounterView.setText("\(frames) F", value: Double(frames), rolling: true)
		} else {
			self.elapsedCounterView.setText(Self.timeText(forSeconds: seconds), value: seconds, rolling: false)
		}

		self.delegate?.trailerPlayerControlBar(self, didSeekTo: seconds)
	}

	/// Plays on from the point the reader let go at.
	@objc private func scrubbingDidEnd() {
		self.isScrubbing = false
		self.updateFrameTicker()

		if self.duration > 0.0 {
			self.delegate?.trailerPlayerControlBar(self, didSeekTo: Double(self.scrubber.value) * self.duration)
		}

		self.delegate?.trailerPlayerControlBarDidEndScrubbing(self)
	}

	/// Builds a button shown in the bar.
	///
	/// - Parameters:
	///    - systemName: The name of the symbol to show.
	///    - pointSize: The point size of the symbol.
	///    - weight: The weight of the symbol.
	///
	/// - Returns: A configured button.
	private static func makeGlyphButton(systemName: String, pointSize: CGFloat, weight: UIImage.SymbolWeight = .regular) -> UIButton {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false

		// Left to itself the Mac renders the button natively — bordered, and dropping the glyph once
		// a menu is attached. `KButton` pins the same style for the same reason.
		button.preferredBehavioralStyle = .pad

		button.tintColor = UIColor(white: 0.82, alpha: 1.0)
		button.setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)), for: .normal)
		return button
	}

	/// Builds a slider shown in the bar.
	///
	/// - Returns: A configured slider.
	private static func makeSlider() -> UISlider {
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
	}

	/// Builds the label showing how fast a held seek button is running.
	///
	/// - Returns: A configured label.
	private static func makeRateLabel() -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .monospacedDigitSystemFont(ofSize: 12.0, weight: .bold)
		label.textColor = .white
		label.textAlignment = .center
		label.alpha = 0.0
		return label
	}

	/// Builds a label for a point in the trailer's timeline.
	///
	/// - Returns: A configured label.
	private static func makeTimeLabel() -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .monospacedDigitSystemFont(ofSize: 12.0, weight: .regular)
		label.textColor = UIColor(white: 0.86, alpha: 1.0)
		label.text = TrailerPlayerControlBar.timePlaceholder
		return label
	}

	/// Returns the given point in the timeline written for display.
	///
	/// - Parameter seconds: The point in the timeline.
	///
	/// - Returns: The point written with a leading zero, gaining an hours field when needed.
	private static func timeText(forSeconds seconds: Double) -> String {
		guard seconds.isFinite, seconds >= 0.0 else { return "00:00" }

		let totalSeconds = Int(seconds.rounded(.down))
		let hours = totalSeconds / 3600
		let minutes = (totalSeconds % 3600) / 60
		let remainingSeconds = totalSeconds % 60

		if hours > 0 {
			return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
		}

		return String(format: "%02d:%02d", minutes, remainingSeconds)
	}
}

// MARK: - UIGestureRecognizerDelegate
extension TrailerPlayerControlBar: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		// Dragging the bar must not take presses meant for the controls sitting on it, or a slider
		// started near its edge would move the whole bar instead of its own knob.
		var view = touch.view

		while let candidate = view, candidate !== self {
			if candidate is UIControl {
				return false
			}

			view = candidate.superview
		}

		return true
	}
}
