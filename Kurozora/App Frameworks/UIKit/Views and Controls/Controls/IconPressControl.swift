//
//  IconPressControl.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

/// A control that shrinks its symbol beneath a growing highlight while pressed.
@available(iOS 17.0, *)
class IconPressControl: UIControl {
	// MARK: - Views
	private let highlightView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.alpha = 0
		view.clipsToBounds = true
		view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		return view
	}()

	/// The image view rendering the control's symbol.
	let symbolView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .center
		imageView.isUserInteractionEnabled = false
		return imageView
	}()

	// MARK: - Properties
	/// The theme color of the symbol in the control's resting state.
	var restingThemeColor: KThemePicker = .textColor {
		didSet { self.updateColors() }
	}

	/// The symbol shown by the control.
	var symbolImage: UIImage? {
		get { self.symbolView.image }
		set { self.symbolView.image = newValue }
	}

	/// A fixed highlight diameter that overrides the default width-derived size.
	var fixedHighlightDiameter: CGFloat? {
		didSet { self.setNeedsLayout() }
	}

	/// A fixed highlight size for oval highlights, taking precedence over ``fixedHighlightDiameter``.
	var fixedHighlightSize: CGSize? {
		didSet { self.setNeedsLayout() }
	}

	/// Whether the highlight stays visible regardless of the press or focus state.
	var maintainsHighlight: Bool { false }

	/// The theme color applied to the symbol.
	var symbolThemeColor: KThemePicker { self.restingThemeColor }

	/// The background color of the press highlight.
	var highlightBackgroundColor: UIColor { .black.withAlphaComponent(0.5) }

	private var isPressed = false
	private var isPointerPress = false
	private var highlightWidthConstraint: NSLayoutConstraint!
	private var highlightHeightConstraint: NSLayoutConstraint!

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
	override func layoutSubviews() {
		super.layoutSubviews()

		let highlightSize: CGSize
		if let fixedHighlightSize = self.fixedHighlightSize {
			highlightSize = fixedHighlightSize
		} else {
			let diameter = self.fixedHighlightDiameter ?? (self.bounds.width + 8)
			highlightSize = CGSize(width: diameter, height: diameter)
		}

		if abs(self.highlightWidthConstraint.constant - highlightSize.width) > 0.5 {
			self.highlightWidthConstraint.constant = highlightSize.width
		}
		if abs(self.highlightHeightConstraint.constant - highlightSize.height) > 0.5 {
			self.highlightHeightConstraint.constant = highlightSize.height
		}
		self.highlightView.layer.cornerRadius = highlightSize.height / 2
	}

	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		self.isPointerPress = touch.type == .indirectPointer
		self.setPressed(true)
		return super.beginTracking(touch, with: event)
	}

	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		super.didUpdateFocus(in: context, with: coordinator)
		self.updateHighlight(animated: true)
	}

	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)
		self.setPressed(false)
	}

	override func cancelTracking(with event: UIEvent?) {
		super.cancelTracking(with: event)
		self.setPressed(false)
	}

	// MARK: - Functions
	/// Sets the symbol, optionally morphing from the previous one.
	///
	/// - Parameters:
	///    - image: The symbol to show.
	///    - replace: Whether to animate the change with a replace transition.
	func setSymbolImage(_ image: UIImage, replace: Bool) {
		if replace {
			self.symbolView.setSymbolImage(image, contentTransition: .replace, options: .speed(1.8))
		} else {
			self.symbolView.image = image
		}
	}

	/// Re-applies the symbol and highlight colors for the current state.
	func updateColors() {
		self.symbolView.theme_tintColor = self.symbolThemeColor.rawValue
		self.highlightView.backgroundColor = self.highlightBackgroundColor
	}

	/// Grows or fades the circular highlight for the current pressed, focused, or maintained state.
	///
	/// - Parameter animated: Whether to spring to the new state.
	func updateHighlight(animated: Bool) {
		let showsHighlight = (self.isPressed && self.isPointerPress) || self.isFocused || self.maintainsHighlight

		let animation = { [weak self] in
			guard let self = self else { return }
			self.highlightView.alpha = showsHighlight ? 1 : 0
			self.highlightView.transform = showsHighlight ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
		}

		if animated {
			UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .beginFromCurrentState], animations: animation)
		} else {
			animation()
		}
	}

	private func sharedInit() {
		self.clipsToBounds = false
		self.addSubview(self.highlightView)
		self.addSubview(self.symbolView)

		self.highlightWidthConstraint = self.highlightView.widthAnchor.constraint(equalToConstant: 38)
		self.highlightHeightConstraint = self.highlightView.heightAnchor.constraint(equalToConstant: 38)
		NSLayoutConstraint.activate([
			self.highlightView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.highlightView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.highlightWidthConstraint,
			self.highlightHeightConstraint,

			self.symbolView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.symbolView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
		])

		self.updateColors()
	}

	private func setPressed(_ pressed: Bool) {
		guard self.isPressed != pressed else { return }
		self.isPressed = pressed

		if pressed {
			UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .beginFromCurrentState]) {
				self.symbolView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
			}
		} else {
			UIView.animate(withDuration: 0.25, delay: 0.07, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .beginFromCurrentState]) {
				self.symbolView.transform = .identity
			}
		}
		self.updateHighlight(animated: true)
	}
}
