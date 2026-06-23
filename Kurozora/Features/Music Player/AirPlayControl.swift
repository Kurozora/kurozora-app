//
//  AirPlayControl.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVKit
import UIKit

final class AirPlayControl: UIView {
	// MARK: - Views
	private let highlightView = PressHighlightView()

	private let routePickerView: AVRoutePickerView = {
		let view = AVRoutePickerView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.tintColor = .label
		view.prioritizesVideoDevices = false
		return view
	}()

	// MARK: - Properties
	/// Observations that keep the route picker's button opaque despite its built-in touch dimming.
	private var dimmingObservations: [NSKeyValueObservation] = []

	/// Whether the current press came from an indirect pointer rather than a direct touch.
	private var pointerPress = false

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func didMoveToWindow() {
		super.didMoveToWindow()
		guard self.window != nil, self.dimmingObservations.isEmpty else { return }
		self.preventGlyphDimming(in: self.routePickerView)
	}

	// MARK: - Functions
	private func sharedInit() {
		self.highlightView.translatesAutoresizingMaskIntoConstraints = false

		self.addSubview(self.highlightView)
		self.addSubview(self.routePickerView)

		NSLayoutConstraint.activate([
			self.highlightView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.highlightView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.highlightView.widthAnchor.constraint(equalToConstant: 38),
			self.highlightView.heightAnchor.constraint(equalTo: self.highlightView.widthAnchor),

			self.routePickerView.topAnchor.constraint(equalTo: self.topAnchor),
			self.routePickerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.routePickerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.routePickerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
		])

		let pressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handlePress(_:)))
		pressGestureRecognizer.minimumPressDuration = 0
		pressGestureRecognizer.cancelsTouchesInView = false
		pressGestureRecognizer.delaysTouchesBegan = false
		pressGestureRecognizer.delegate = self
		self.addGestureRecognizer(pressGestureRecognizer)
	}

	/// Pins the route picker's button opacity to full, neutralizing its built-in dimming on touch.
	///
	/// The internal button drops its own `alpha` while highlighted; this control supplies its own
	/// press feedback instead, so the glyph is kept fully opaque.
	///
	/// - Parameter view: The view whose button descendants should stay opaque.
	private func preventGlyphDimming(in view: UIView) {
		for subview in view.subviews {
			if subview is UIButton {
				let observation = subview.observe(\.alpha, options: [.new]) { button, change in
					if let alpha = change.newValue, alpha < 1 {
						button.alpha = 1
					}
				}
				self.dimmingObservations.append(observation)
			}
			self.preventGlyphDimming(in: subview)
		}
	}

	/// Reflects the pressed state with a growing highlight and a shrinking glyph.
	///
	/// - Parameter gestureRecognizer: The press gesture recognizer reporting the touch state.
	@objc private func handlePress(_ gestureRecognizer: UILongPressGestureRecognizer) {
		switch gestureRecognizer.state {
		case .began:
			self.setPressed(true)
		case .ended, .cancelled, .failed:
			self.setPressed(false)
		default:
			break
		}
	}

	/// Springs the glyph and highlight to match the pressed state.
	///
	/// - Parameter pressed: Whether the control is being pressed.
	private func setPressed(_ pressed: Bool) {
		self.highlightView.setPressed(pressed && self.pointerPress, animated: true)

		if pressed {
			UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .beginFromCurrentState]) {
				self.routePickerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
			}
		} else {
			UIView.animate(withDuration: 0.25, delay: 0.07, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .beginFromCurrentState]) {
				self.routePickerView.transform = .identity
			}
		}
	}
}

// MARK: - UIGestureRecognizerDelegate
extension AirPlayControl: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		self.pointerPress = touch.type == .indirectPointer
		return true
	}
}
