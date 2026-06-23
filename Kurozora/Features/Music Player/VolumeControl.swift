//
//  VolumeControl.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import MediaPlayer
import UIKit

#if targetEnvironment(macCatalyst)
import CoreAudio
#endif

final class VolumeControl: UIControl {
	// MARK: - Views
	private let sliderContainer: UIVisualEffectView = {
		let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
		view.translatesAutoresizingMaskIntoConstraints = false
		view.clipsToBounds = true
		view.alpha = 0
		view.isUserInteractionEnabled = false
		return view
	}()

	private let sliderTrackView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .label.withAlphaComponent(0.25)
		view.layer.cornerRadius = 4
		view.clipsToBounds = true
		return view
	}()

	private let sliderFillView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .label
		return view
	}()

	private let glyphImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .center
		return imageView
	}()

	private let highlightView = PressHighlightView()

	private let volumeView: MPVolumeView = {
		let view = MPVolumeView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.alpha = 0.001
		view.isUserInteractionEnabled = false
		return view
	}()

	// MARK: - Properties
	/// The distance the slider extends to the leading side of the glyph.
	var sliderExtent: CGFloat = 120 {
		didSet { self.sliderContainerLeadingConstraint.constant = -self.sliderExtent }
	}

	/// The drag distance, in points, that corresponds to the full volume range.
	private let dragRange: CGFloat = 150

	/// The current volume, in the range `0...1`.
	private var currentVolume: Float = 1.0

	/// The volume restored when unmuting.
	private var volumeBeforeMute: Float = 0.5

	/// The volume captured when a drag begins.
	private var volumeAtDragStart: Float = 0

	/// The horizontal location captured when a drag begins.
	private var locationAtDragStart: CGFloat = 0

	/// Whether the current press has moved far enough to count as a drag.
	private var didDrag = false

	/// Whether the slider was already revealed when the current press began.
	private var wasRevealedAtPressStart = false

	/// Whether the current press began on the speaker glyph rather than the extended slider area.
	private var pressedGlyph = false

	/// Whether the current press came from an indirect pointer rather than a direct touch.
	private var pointerPress = false

	/// Whether the inline slider is revealed.
	private var isRevealed = false

	/// Whether a pointer is currently hovering the unit.
	private var isHovering = false

	/// The observation of system volume changes.
	private var volumeObservation: NSObjectProtocol?

	#if targetEnvironment(macCatalyst)
	/// The Core Audio device whose volume is currently being observed.
	private var observedAudioDeviceID: AudioObjectID?

	/// The channels the volume listener is attached to on the observed device.
	private var observedVolumeChannels: [UInt32] = []

	/// The block invoked when the observed device's volume changes.
	private var volumeListenerBlock: AudioObjectPropertyListenerBlock?

	/// The block invoked when the default output device changes.
	private var defaultDeviceListenerBlock: AudioObjectPropertyListenerBlock?
	#endif

	private var sliderContainerLeadingConstraint: NSLayoutConstraint!
	private var sliderFillWidthConstraint: NSLayoutConstraint!

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		#if targetEnvironment(macCatalyst)
		self.stopObservingSystemVolume()
		#else
		if let volumeObservation = self.volumeObservation {
			NotificationCenter.default.removeObserver(volumeObservation)
		}
		#endif
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.sliderContainer.layer.cornerRadius = self.sliderContainer.bounds.height / 2
		self.updateSliderFill()
	}

	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		if self.isRevealed {
			return self.bounds.insetBy(dx: -self.sliderExtent, dy: 0).contains(point)
		}
		return super.point(inside: point, with: event)
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()
		guard self.window != nil, !self.isTracking else { return }
		self.syncVolumeFromSystem()
	}

	// MARK: - Functions
	private func sharedInit() {
		self.clipsToBounds = false

		self.highlightView.translatesAutoresizingMaskIntoConstraints = false

		self.sliderTrackView.addSubview(self.sliderFillView)
		self.sliderContainer.contentView.addSubview(self.sliderTrackView)
		self.addSubview(self.volumeView)
		self.addSubview(self.sliderContainer)
		self.addSubview(self.highlightView)
		self.addSubview(self.glyphImageView)

		self.sliderContainerLeadingConstraint = self.sliderContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -self.sliderExtent)
		self.sliderFillWidthConstraint = self.sliderFillView.widthAnchor.constraint(equalToConstant: 0)

		NSLayoutConstraint.activate([
			self.volumeView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.volumeView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.volumeView.widthAnchor.constraint(equalToConstant: 1),
			self.volumeView.heightAnchor.constraint(equalToConstant: 1),

			self.highlightView.centerXAnchor.constraint(equalTo: self.glyphImageView.centerXAnchor),
			self.highlightView.centerYAnchor.constraint(equalTo: self.glyphImageView.centerYAnchor),
			self.highlightView.widthAnchor.constraint(equalToConstant: 38),
			self.highlightView.heightAnchor.constraint(equalTo: self.highlightView.widthAnchor),

			self.glyphImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.glyphImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

			self.sliderContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.sliderContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 6),
			self.sliderContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6),
			self.sliderContainerLeadingConstraint,

			self.sliderTrackView.leadingAnchor.constraint(equalTo: self.sliderContainer.contentView.leadingAnchor, constant: 12),
			self.sliderTrackView.trailingAnchor.constraint(equalTo: self.glyphImageView.leadingAnchor, constant: -8),
			self.sliderTrackView.centerYAnchor.constraint(equalTo: self.sliderContainer.contentView.centerYAnchor),
			self.sliderTrackView.heightAnchor.constraint(equalToConstant: 8),

			self.sliderFillView.leadingAnchor.constraint(equalTo: self.sliderTrackView.leadingAnchor),
			self.sliderFillView.topAnchor.constraint(equalTo: self.sliderTrackView.topAnchor),
			self.sliderFillView.bottomAnchor.constraint(equalTo: self.sliderTrackView.bottomAnchor),
			self.sliderFillWidthConstraint,
		])

		let hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(self.handleHover(_:)))
		self.addGestureRecognizer(hoverGestureRecognizer)

		self.syncVolumeFromSystem()

		#if targetEnvironment(macCatalyst)
		self.startObservingSystemVolume()
		#else
		self.volumeObservation = NotificationCenter.default.addObserver(
			forName: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"),
			object: nil,
			queue: .main
		) { [weak self] notification in
			guard let self = self, !self.isTracking else { return }

			if let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
				self.currentVolume = volume
				self.updateSliderFill()
				self.updateGlyph()
			} else {
				self.syncVolumeFromSystem()
			}
		}
		#endif
	}

	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		self.pointerPress = touch.type == .indirectPointer
		self.wasRevealedAtPressStart = self.isRevealed
		self.pressedGlyph = self.bounds.contains(touch.location(in: self))
		self.locationAtDragStart = touch.location(in: self).x
		self.volumeAtDragStart = self.currentVolume
		self.didDrag = false

		if self.pointerPress {
			self.setRevealed(true)
		}

		if self.pressedGlyph {
			self.setPressed(true)
		} else {
			self.scrubAbsolute(to: touch)
		}
		return true
	}

	override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		if self.pressedGlyph {
			let delta = touch.location(in: self).x - self.locationAtDragStart
			if abs(delta) > 4, !self.didDrag {
				self.didDrag = true
				self.setPressed(false)

				if !self.pointerPress {
					self.setRevealed(true)
				}
			}

			let newVolume = min(1, max(0, self.volumeAtDragStart + Float(delta / self.dragRange)))
			self.apply(volume: newVolume)
		} else {
			self.didDrag = true
			self.scrubAbsolute(to: touch)
		}
		return true
	}

	/// Sets the volume to the touch's absolute position along the slider track.
	///
	/// - Parameter touch: The touch whose location maps onto the track.
	private func scrubAbsolute(to touch: UITouch) {
		let trackWidth = self.sliderTrackView.bounds.width
		guard trackWidth > 0 else { return }

		let fraction = min(1, max(0, touch.location(in: self.sliderTrackView).x / trackWidth))
		self.apply(volume: Float(fraction))
	}

	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		self.setPressed(false)

		if self.pointerPress {
			if self.pressedGlyph, !self.didDrag, self.wasRevealedAtPressStart {
				self.toggleMute()
			}
		} else {
			if self.pressedGlyph, !self.didDrag {
				self.toggleMute()
			}
			self.setRevealed(false)
		}
	}

	override func cancelTracking(with event: UIEvent?) {
		self.setPressed(false)

		if !self.pointerPress {
			self.setRevealed(false)
		}
	}

	@objc private func handleHover(_ gestureRecognizer: UIHoverGestureRecognizer) {
		switch gestureRecognizer.state {
		case .began, .changed:
			self.isHovering = true
		default:
			self.isHovering = false
			if !self.isTracking {
				self.setRevealed(false)
			}
		}
	}

	private func toggleMute() {
		if self.currentVolume > 0 {
			self.volumeBeforeMute = self.currentVolume
			self.apply(volume: 0)
		} else {
			self.apply(volume: self.volumeBeforeMute > 0 ? self.volumeBeforeMute : 0.5)
		}
	}

	private func apply(volume: Float) {
		self.currentVolume = volume
		self.updateSliderFill()
		self.updateGlyph()
		self.setSystemVolume(volume)
	}

	/// Reads the current system volume.
	private func syncVolumeFromSystem() {
		#if targetEnvironment(macCatalyst)
		if let systemVolume = self.currentSystemOutputVolume() {
			self.currentVolume = systemVolume
			self.updateSliderFill()
			self.updateGlyph()
			return
		}
		#endif

		let sliderValue = self.volumeView.subviews.compactMap { $0 as? UISlider }.first?.value
		self.currentVolume = sliderValue ?? AVAudioSession.sharedInstance().outputVolume
		self.updateSliderFill()
		self.updateGlyph()
	}

	#if targetEnvironment(macCatalyst)
	/// Reads the default output device's volume scalar through the Core Audio HAL.
	///
	/// - Returns: The output volume in the range `0...1`.
	private func currentSystemOutputVolume() -> Float? {
		guard let deviceID = self.defaultOutputDeviceID() else { return nil }

		let channelVolumes = self.volumeChannels(for: deviceID).compactMap { channel -> Float? in
			var address = AudioObjectPropertyAddress(
				mSelector: kAudioDevicePropertyVolumeScalar,
				mScope: kAudioDevicePropertyScopeOutput,
				mElement: channel
			)
			var volume = Float32(0)
			var volumeSize = UInt32(MemoryLayout<Float32>.size)
			guard AudioObjectGetPropertyData(deviceID, &address, 0, nil, &volumeSize, &volume) == noErr else { return nil }
			return volume
		}

		guard !channelVolumes.isEmpty else { return nil }
		return channelVolumes.reduce(0, +) / Float(channelVolumes.count)
	}

	/// Returns the identifier of the system's default audio output device.
	///
	/// - Returns: The default output device identifier.
	private func defaultOutputDeviceID() -> AudioObjectID? {
		var deviceID = AudioObjectID(0)
		var deviceIDSize = UInt32(MemoryLayout<AudioObjectID>.size)
		var address = AudioObjectPropertyAddress(
			mSelector: kAudioHardwarePropertyDefaultOutputDevice,
			mScope: kAudioObjectPropertyScopeGlobal,
			mElement: kAudioObjectPropertyElementMain
		)

		guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &deviceIDSize, &deviceID) == noErr else {
			return nil
		}
		return deviceID
	}

	/// Returns the volume channels to read for the given device, preferring the main channel.
	///
	/// - Parameter deviceID: The output device to inspect.
	///
	/// - Returns: The main channel when it exposes a volume, otherwise the left and right channels.
	private func volumeChannels(for deviceID: AudioObjectID) -> [UInt32] {
		var address = AudioObjectPropertyAddress(
			mSelector: kAudioDevicePropertyVolumeScalar,
			mScope: kAudioDevicePropertyScopeOutput,
			mElement: kAudioObjectPropertyElementMain
		)
		return AudioObjectHasProperty(deviceID, &address) ? [kAudioObjectPropertyElementMain] : [1, 2]
	}

	/// Starts observing system volume and default-output-device changes through the Core Audio HAL.
	private func startObservingSystemVolume() {
		self.volumeListenerBlock = { [weak self] _, _ in
			guard let self = self, !self.isTracking else { return }
			self.syncVolumeFromSystem()
		}
		self.attachVolumeListener()

		let defaultDeviceBlock: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
			guard let self = self else { return }
			self.detachVolumeListener()
			self.attachVolumeListener()
			if !self.isTracking {
				self.syncVolumeFromSystem()
			}
		}
		self.defaultDeviceListenerBlock = defaultDeviceBlock

		var address = AudioObjectPropertyAddress(
			mSelector: kAudioHardwarePropertyDefaultOutputDevice,
			mScope: kAudioObjectPropertyScopeGlobal,
			mElement: kAudioObjectPropertyElementMain
		)
		_ = AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &address, .main, defaultDeviceBlock)
	}

	/// Removes all Core Audio volume observers.
	private func stopObservingSystemVolume() {
		self.detachVolumeListener()

		if let defaultDeviceListenerBlock = self.defaultDeviceListenerBlock {
			var address = AudioObjectPropertyAddress(
				mSelector: kAudioHardwarePropertyDefaultOutputDevice,
				mScope: kAudioObjectPropertyScopeGlobal,
				mElement: kAudioObjectPropertyElementMain
			)
			_ = AudioObjectRemovePropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &address, .main, defaultDeviceListenerBlock)
			self.defaultDeviceListenerBlock = nil
		}

		self.volumeListenerBlock = nil
	}

	/// Attaches the volume listener to the current default output device.
	private func attachVolumeListener() {
		guard let volumeListenerBlock = self.volumeListenerBlock, let deviceID = self.defaultOutputDeviceID() else { return }
		let channels = self.volumeChannels(for: deviceID)
		self.observedAudioDeviceID = deviceID
		self.observedVolumeChannels = channels

		for channel in channels {
			var address = AudioObjectPropertyAddress(
				mSelector: kAudioDevicePropertyVolumeScalar,
				mScope: kAudioDevicePropertyScopeOutput,
				mElement: channel
			)
			_ = AudioObjectAddPropertyListenerBlock(deviceID, &address, .main, volumeListenerBlock)
		}
	}

	/// Detaches the volume listener from the device it was attached to.
	private func detachVolumeListener() {
		guard let volumeListenerBlock = self.volumeListenerBlock, let deviceID = self.observedAudioDeviceID else { return }

		for channel in self.observedVolumeChannels {
			var address = AudioObjectPropertyAddress(
				mSelector: kAudioDevicePropertyVolumeScalar,
				mScope: kAudioDevicePropertyScopeOutput,
				mElement: channel
			)
			_ = AudioObjectRemovePropertyListenerBlock(deviceID, &address, .main, volumeListenerBlock)
		}

		self.observedAudioDeviceID = nil
		self.observedVolumeChannels = []
	}
	#endif

	/// Sets the system media volume by driving the off-screen volume view's slider.
	///
	/// - Parameter volume: The volume to set, in the range `0...1`.
	private func setSystemVolume(_ volume: Float) {
		guard let slider = self.volumeView.subviews.compactMap({ $0 as? UISlider }).first else { return }
		slider.value = volume
		slider.sendActions(for: .valueChanged)
	}

	private func updateSliderFill() {
		self.sliderFillWidthConstraint.constant = self.sliderTrackView.bounds.width * CGFloat(self.currentVolume)
	}

	private func updateGlyph() {
		let symbolName: String
		switch self.currentVolume {
		case ..<0.001:
			symbolName = "speaker.slash.fill"
		case ..<0.34:
			symbolName = "speaker.wave.1.fill"
		case ..<0.67:
			symbolName = "speaker.wave.2.fill"
		default:
			symbolName = "speaker.wave.3.fill"
		}

		let configuration = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
		self.glyphImageView.image = UIImage(systemName: symbolName, withConfiguration: configuration)
	}

	/// Springs the glyph and highlight to match the pressed state, leaving the slider untouched.
	///
	/// - Parameter pressed: Whether the control is being pressed.
	private func setPressed(_ pressed: Bool) {
		self.highlightView.setPressed(pressed && self.pointerPress, animated: true)

		if pressed {
			UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .beginFromCurrentState]) {
				self.glyphImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
			}
		} else {
			UIView.animate(withDuration: 0.25, delay: 0.07, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .beginFromCurrentState]) {
				self.glyphImageView.transform = .identity
			}
		}
	}

	private func setRevealed(_ revealed: Bool) {
		guard revealed != self.isRevealed else { return }
		self.isRevealed = revealed

		let animations = { [weak self] in
			guard let self = self else { return }
			self.sliderContainer.alpha = revealed ? 1 : 0
		}

		if UIAccessibility.isReduceMotionEnabled {
			animations()
		} else {
			UIView.animate(withDuration: 0.2, animations: animations)
		}
	}
}
