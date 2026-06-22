//
//  TransportButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

/// A transport control button whose symbol gently shrinks while a circular highlight grows on press.
/// On release the content transition (replace/push) plays from the shrunk state, then the symbol
/// settles back to full size. Controls that toggle on and off can stay active, keeping a tinted
/// highlight and symbol.
@available(iOS 26.0, *)
final class TransportButton: UIButton {
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

	private let symbolView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .center
		imageView.isUserInteractionEnabled = false
		return imageView
	}()

	// MARK: - Properties
	/// The skip-conveyor glyph, when this button is a skip control.
	private var skipChevron: SkipChevronView?

	/// The theme color of the symbol while the control is inactive.
	var restingThemeColor: KThemePicker = .textColor {
		didSet { self.updateColors() }
	}

	/// Whether the control is in its active (enabled) state, persisting a tinted highlight and symbol.
	var isActive: Bool = false {
		didSet {
			guard oldValue != self.isActive else { return }
			self.updateColors()
			self.updateHighlight(animated: true)
		}
	}

	/// The symbol shown by the button.
	var symbolImage: UIImage? {
		get { self.symbolView.image }
		set { self.symbolView.image = newValue }
	}

	/// A fixed highlight diameter that overrides the default width-derived size.
	var fixedHighlightDiameter: CGFloat? {
		didSet { self.setNeedsLayout() }
	}

	private var isPressed = false
	private var isPointerPress = false
	private var highlightSizeConstraint: NSLayoutConstraint!

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
		let diameter = self.fixedHighlightDiameter ?? (self.bounds.width + 8)
		if abs(self.highlightSizeConstraint.constant - diameter) > 0.5 {
			self.highlightSizeConstraint.constant = diameter
		}
		self.highlightView.layer.cornerRadius = diameter / 2
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
	private func sharedInit() {
		self.clipsToBounds = false
		self.addSubview(self.highlightView)
		self.addSubview(self.symbolView)

		self.highlightSizeConstraint = self.highlightView.widthAnchor.constraint(equalToConstant: 38)
		NSLayoutConstraint.activate([
			self.highlightView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.highlightView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.highlightSizeConstraint,
			self.highlightView.heightAnchor.constraint(equalTo: self.highlightView.widthAnchor),

			self.symbolView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.symbolView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
		])

		self.updateColors()

		self.addAction(UIAction { [weak self] _ in
			self?.skipChevron?.animateSkip()
		}, for: .touchUpInside)
	}

	/// Configures this button as a skip control, replacing the symbol with an animatable chevron.
	///
	/// - Parameter direction: The skip direction.
	func configureSkip(direction: SkipChevronView.Direction) {
		let chevron = SkipChevronView(direction: direction)
		chevron.translatesAutoresizingMaskIntoConstraints = false
		self.symbolView.addSubview(chevron)
		NSLayoutConstraint.activate([
			chevron.leadingAnchor.constraint(equalTo: self.symbolView.leadingAnchor),
			chevron.trailingAnchor.constraint(equalTo: self.symbolView.trailingAnchor),
			chevron.topAnchor.constraint(equalTo: self.symbolView.topAnchor),
			chevron.bottomAnchor.constraint(equalTo: self.symbolView.bottomAnchor),
		])
		self.skipChevron = chevron
	}

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

	/// Grows or fades the circular highlight for the current pressed/active state.
	///
	/// - Parameter animated: Whether to spring to the new state.
	private func updateHighlight(animated: Bool) {
		let showsHighlight = self.isPressed || self.isActive

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

	/// Applies the symbol and highlight colors for the current active state.
	private func updateColors() {
		self.symbolView.theme_tintColor = (self.isActive ? KThemePicker.tintColor : self.restingThemeColor).rawValue
		self.highlightView.backgroundColor = self.isActive
			? KThemePicker.tintColor.colorValue.withAlphaComponent(0.5)
			: .black.withAlphaComponent(0.5)
	}
}
