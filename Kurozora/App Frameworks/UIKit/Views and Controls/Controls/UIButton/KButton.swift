//
//  UIKit+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

/// A control that executes your custom code in response to user interactions.
///
/// When you tap a button, or select a button that has focus, the button performs any actions attached to it.
/// You communicate the purpose of a button using a text label, an image, or both.
/// The appearance of buttons is configurable, so you can tint buttons or format titles to match the design of your app.
/// You can add buttons to your interface programmatically or using Interface Builder.
///
/// `KButton` provides selection feedback using [UISelectionFeedbackGenerator](apple-reference-documentation://hsnDczB7p0).
class KButton: UIButton {
	// MARK: - IBInspectables
	/// Inidicates whether highlighting the button is enabled.
	@IBInspectable var highlightBackgroundColorEnabled: Bool = false
	/// The background color of the button in a highlighted state.
	@IBInspectable var highlightBackgroundColor: UIColor?

	// MARK: - Properties
	/// The object that animates changes to views and allows the dynamic modification of those animations.
	private lazy var animator = UIViewPropertyAnimator()

	/// The object that creates haptics to indicate a change in selection
	private lazy var selectionFeedbackGenerator = UISelectionFeedbackGenerator()

	/// The background color of the button in a normal state.
	var normalBackgroundColor: UIColor?

	/// Storage to the background color of the button in a highlighted state.
	var _highlightBackgroundColor: UIColor?

	/// Indicates whether the bounce effect is enabled.
	var springEnabled: Bool = false

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the button.
	func sharedInit() {
		// Configure properties
		self.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		self.theme_tintColor = KThemePicker.tintColor.rawValue
		self.titleLabel?.font = .systemFont(ofSize: self.titleLabel?.font.pointSize ?? 18, weight: .semibold)

		self.setTitleColor(.systemGray3, for: .disabled)
		self.setBackgroundColor(color: .systemGray5, forState: .disabled)

		// Add targets
		self.addTarget(self, action: #selector(self.touchDown), for: [.touchDown, .touchDragEnter])
		self.addTarget(self, action: #selector(self.touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
	}

	/// The actions performed when the user touches the button.
	@objc private func touchDown() {
		self._highlightBackgroundColor = (self.backgroundColor != .white) ? self.backgroundColor?.lighten(by: 0.1) : self.backgroundColor?.darken(by: 0.15)
		if self.highlightBackgroundColorEnabled || self.highlightBackgroundColor != nil {
			self.normalBackgroundColor = backgroundColor
			UIViewPropertyAnimator().stopAnimation(true)
			self.animator.stopAnimation(true)
			self.backgroundColor = self.highlightBackgroundColor ?? self._highlightBackgroundColor
		}

		if self.springEnabled {
			UIView.animate(
				withDuration: 0.4,
				delay: 0,
				usingSpringWithDamping: 0.8,
				initialSpringVelocity: 1.75,
				options: [.curveEaseIn, .beginFromCurrentState, .allowUserInteraction],
				animations: { [weak self] in
					guard let self = self else { return }
					self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

					if UserSettings.hapticsAllowed {
						self.selectionFeedbackGenerator.selectionChanged()
					}
				}, completion: nil)
		} else {
			if UserSettings.hapticsAllowed {
				self.selectionFeedbackGenerator.selectionChanged()
			}
		}
	}

	/// The actions performed when the user lets go of the button.
	@objc private func touchUp() {
		if self.highlightBackgroundColorEnabled || self.highlightBackgroundColor != nil {
			self.animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: { [weak self] in
				guard let self = self else { return }
				self.backgroundColor = self.normalBackgroundColor
			})
		}

		self.animator.startAnimation()

		if self.springEnabled {
			UIView.animate(
				withDuration: 0.4,
				delay: 0,
				usingSpringWithDamping: 0.8,
				initialSpringVelocity: 1.75,
				options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
				animations: { [weak self] in
					guard let self = self else { return }
					self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

					if UserSettings.hapticsAllowed {
						self.selectionFeedbackGenerator.selectionChanged()
					}
				}, completion: nil)
		} else {
			if UserSettings.hapticsAllowed {
				self.selectionFeedbackGenerator.selectionChanged()
			}
		}
	}
}
