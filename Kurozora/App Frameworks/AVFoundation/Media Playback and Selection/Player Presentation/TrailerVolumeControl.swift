//
//  TrailerVolumeControl.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import MediaPlayer
import UIKit

/// A round volume button that expands into the system volume slider.
final class TrailerVolumeControl: UIView {
	// MARK: - Views
	/// The glass behind the control.
	private let backgroundEffectView: UIVisualEffectView = {
		let effectView = UIVisualEffectView()
		effectView.translatesAutoresizingMaskIntoConstraints = false
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
	}()

	/// The speaker button.
	private let glyphButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tintColor = .white
		return button
	}()

	/// The system volume slider.
	private let volumeView: MPVolumeView = {
		let volumeView = MPVolumeView(frame: .zero)
		volumeView.translatesAutoresizingMaskIntoConstraints = false
		volumeView.tintColor = .white
		volumeView.alpha = 0.001
		return volumeView
	}()

	// MARK: - Properties
	/// A Boolean value indicating whether the trailer's sound is off.
	var isMuted = false {
		didSet {
			self.updateGlyph()
		}
	}

	/// Called when the speaker is tapped while the slider is out.
	var onToggleMute: (() -> Void)?

	/// Called when the reader changes the volume.
	var onVolumeAdjust: (() -> Void)?

	/// Called when the device's volume changes from outside the control.
	var onSystemVolumeChange: (() -> Void)?

	/// Called inside the expansion animation as the slider comes out or folds away.
	var onExpansionChange: ((Bool) -> Void)?

	/// Called whenever the reader works the control.
	var onInteraction: (() -> Void)?

	/// A Boolean value indicating whether the slider is out.
	private(set) var isExpanded = false

	/// A Boolean value indicating whether the slider was out when the current press began.
	private var wasExpandedAtPressStart = false

	/// A Boolean value indicating whether a slide on the speaker is changing the volume.
	private var isSliding = false

	/// The diameter of the collapsed control.
	private let diameter: CGFloat

	/// The width the control grows to when the slider is out.
	private let expandedWidth: CGFloat = 186.0

	/// The slide distance covering the whole volume range.
	private let slideRange: CGFloat = 150.0

	/// The system volume, from `0` to `1`.
	private var volume: Float = 1.0

	/// The volume when the current slide began.
	private var volumeAtSlideStart: Float = 0.0

	/// A Boolean value indicating whether the system slider has taken the control's styling.
	private var hasStyledSystemSlider = false

	/// The constraint setting the control's width.
	private var widthConstraint: NSLayoutConstraint?

	/// The constraint centering the system volume view.
	private var volumeCenterYConstraint: NSLayoutConstraint?

	/// The task folding the slider away after a pause.
	private var collapseTask: Task<Void, Never>?

	/// The clock reading the system slider for changes made outside the control.
	private var volumePoll: Timer?

	/// The slider the system volume view draws.
	private var systemSlider: UISlider? {
		return self.volumeView.subviews.compactMap { $0 as? UISlider }.first
	}

	/// A Boolean value indicating whether a finger is on the control.
	private var isBeingTouched: Bool {
		return self.glyphButton.isTracking || self.isSliding || self.systemSlider?.isTracking == true
	}

	// MARK: - Initializers
	/// Creates a volume control of the given diameter.
	///
	/// - Parameter diameter: The diameter of the collapsed control.
	init(diameter: CGFloat) {
		self.diameter = diameter
		super.init(frame: .zero)
		self.sharedInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	isolated deinit {
		self.volumePoll?.invalidate()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.styleSystemSlider()
		self.centerSystemSlider()

		if #unavailable(iOS 26.0) {
			self.backgroundEffectView.layer.cornerRadius = self.bounds.height / 2.0
		}
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()

		guard self.window != nil else {
			self.volumePoll?.invalidate()
			self.volumePoll = nil
			return
		}

		self.styleSystemSlider()
		self.readSystemVolume()
		self.startVolumePoll()
	}

	// MARK: - Functions
	/// Builds the control's contents.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.overrideUserInterfaceStyle = .dark
		self.addSubview(self.backgroundEffectView)
		self.backgroundEffectView.contentView.addSubview(self.volumeView)
		self.backgroundEffectView.contentView.addSubview(self.glyphButton)

		self.glyphButton.accessibilityLabel = L10n.volume
		self.glyphButton.addTarget(self, action: #selector(self.glyphPressBegan), for: .touchDown)
		self.glyphButton.addTarget(self, action: #selector(self.glyphTapped), for: .touchUpInside)
		self.glyphButton.addTarget(self, action: #selector(self.glyphPressEnded), for: [.touchUpOutside, .touchCancel])

		let slideGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleSlide(_:)))
		self.glyphButton.addGestureRecognizer(slideGesture)

		let widthConstraint = self.widthAnchor.constraint(equalToConstant: self.diameter)
		self.widthConstraint = widthConstraint

		let volumeCenterYConstraint = self.volumeView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
		self.volumeCenterYConstraint = volumeCenterYConstraint

		let volumeLeadingConstraint = self.volumeView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0)
		volumeLeadingConstraint.priority = .defaultHigh

		NSLayoutConstraint.activate([
			widthConstraint,
			self.heightAnchor.constraint(equalToConstant: self.diameter),

			self.backgroundEffectView.topAnchor.constraint(equalTo: self.topAnchor),
			self.backgroundEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.backgroundEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.backgroundEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			self.glyphButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.glyphButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.glyphButton.widthAnchor.constraint(equalToConstant: self.diameter),
			self.glyphButton.heightAnchor.constraint(equalToConstant: self.diameter),

			volumeLeadingConstraint,
			volumeCenterYConstraint,
			self.volumeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 1.0),
			self.volumeView.trailingAnchor.constraint(equalTo: self.glyphButton.leadingAnchor, constant: -8.0),
			self.volumeView.heightAnchor.constraint(equalToConstant: self.diameter)
		])

		self.readSystemVolume()
	}

	/// Opens the slider as the speaker is pressed.
	@objc private func glyphPressBegan() {
		self.wasExpandedAtPressStart = self.isExpanded
		self.collapseTask?.cancel()
		self.onInteraction?()
		self.setExpanded(true)
	}

	/// Toggles the sound when the speaker is tapped with the slider already out.
	@objc private func glyphTapped() {
		if self.wasExpandedAtPressStart {
			self.onToggleMute?()
		}

		self.scheduleCollapse()
	}

	/// Lets the slider fold away once the speaker is let go.
	@objc private func glyphPressEnded() {
		self.scheduleCollapse()
	}

	/// Changes the volume as a finger slides across the speaker.
	///
	/// - Parameter gesture: The slide being followed.
	@objc private func handleSlide(_ gesture: UIPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			self.isSliding = true
			self.volumeAtSlideStart = self.volume
			self.collapseTask?.cancel()
		case .changed:
			let translation = gesture.translation(in: self).x
			self.applyVolume(min(1.0, max(0.0, self.volumeAtSlideStart + Float(translation / self.slideRange))))
		default:
			self.isSliding = false
			self.scheduleCollapse()
		}
	}

	/// Starts reading the system slider for changes made outside the control.
	private func startVolumePoll() {
		guard self.volumePoll == nil else { return }

		let volumePoll = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
			MainActor.assumeIsolated {
				self?.readPolledVolume()
			}
		}
		volumePoll.tolerance = 0.05
		RunLoop.main.add(volumePoll, forMode: .common)
		self.volumePoll = volumePoll
	}

	/// Follows a change the device made to the volume.
	private func readPolledVolume() {
		guard let systemSlider = self.systemSlider, abs(systemSlider.value - self.volume) > 0.001 else { return }

		self.volume = systemSlider.value
		self.updateGlyph()

		guard !self.isBeingTouched else { return }

		self.onSystemVolumeChange?()
		self.setExpanded(true)
		self.scheduleCollapse()
	}

	/// Slides the volume slider out, or folds it away.
	///
	/// - Parameter isExpanded: Whether the slider is out.
	func setExpanded(_ isExpanded: Bool) {
		guard isExpanded != self.isExpanded else { return }

		self.isExpanded = isExpanded
		self.collapseTask?.cancel()
		self.widthConstraint?.constant = isExpanded ? self.expandedWidth : self.diameter
		self.onInteraction?()

		UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.0, options: [.beginFromCurrentState, .allowUserInteraction]) {
			self.volumeView.alpha = isExpanded ? 1.0 : 0.001
			self.onExpansionChange?(isExpanded)
			self.superview?.layoutIfNeeded()
		}
	}

	/// Folds the slider away after a pause.
	private func scheduleCollapse() {
		self.collapseTask?.cancel()
		self.collapseTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 2_000_000_000)
			guard !Task.isCancelled, let self = self, !self.isBeingTouched else { return }

			self.setExpanded(false)
		}
	}

	/// Dresses the system slider in the control's colors and follows its touches.
	private func styleSystemSlider() {
		guard !self.hasStyledSystemSlider, let systemSlider = self.systemSlider else { return }
		self.hasStyledSystemSlider = true

		systemSlider.minimumTrackTintColor = .white
		systemSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)

		if #available(iOS 26.0, *) {
			systemSlider.sliderStyle = .thumbless
		}

		systemSlider.addTarget(self, action: #selector(self.systemSliderDidChange), for: .valueChanged)
		systemSlider.addTarget(self, action: #selector(self.systemSliderDidEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])
	}

	/// Shifts the system volume view until its slider sits on the control's center line.
	private func centerSystemSlider() {
		guard let volumeCenterYConstraint = self.volumeCenterYConstraint else { return }

		self.volumeView.layoutIfNeeded()

		guard let systemSlider = self.systemSlider, systemSlider.bounds.height > 0.0 else { return }

		let offset = systemSlider.frame.midY - self.volumeView.bounds.midY
		guard abs(volumeCenterYConstraint.constant + offset) > 0.5 else { return }

		volumeCenterYConstraint.constant = -offset
	}

	/// Follows the system slider as it is dragged.
	@objc private func systemSliderDidChange() {
		self.collapseTask?.cancel()
		self.onInteraction?()
		self.onVolumeAdjust?()
	}

	/// Lets the slider fold away once it is let go.
	@objc private func systemSliderDidEnd() {
		self.scheduleCollapse()
	}

	/// Sets the system volume and shows it.
	///
	/// - Parameter volume: The volume, from `0` to `1`.
	private func applyVolume(_ volume: Float) {
		self.volume = volume
		self.updateGlyph()
		self.onVolumeAdjust?()

		guard let systemSlider = self.systemSlider else { return }
		systemSlider.value = volume
		systemSlider.sendActions(for: .valueChanged)
	}

	/// Reads the system volume.
	private func readSystemVolume() {
		self.volume = self.systemSlider?.value ?? AVAudioSession.sharedInstance().outputVolume
		self.updateGlyph()
	}

	/// Shows the mute state and the volume on the speaker.
	private func updateGlyph() {
		let configuration = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .semibold)
		let image: UIImage?

		if self.isMuted {
			image = UIImage(systemName: "speaker.slash.fill", withConfiguration: configuration)
		} else if #available(iOS 16.0, *) {
			image = UIImage(systemName: "speaker.wave.3.fill", variableValue: Double(self.volume), configuration: configuration)
		} else {
			let symbolName: String
			switch self.volume {
			case ..<0.34: symbolName = "speaker.wave.1.fill"
			case ..<0.67: symbolName = "speaker.wave.2.fill"
			default: symbolName = "speaker.wave.3.fill"
			}

			image = UIImage(systemName: symbolName, withConfiguration: configuration)
		}

		self.glyphButton.setImage(image, for: .normal)
	}
}
