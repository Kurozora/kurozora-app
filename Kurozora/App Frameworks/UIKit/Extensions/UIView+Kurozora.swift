//
//  UIView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIView {
	// MARK: - Properties
	#if targetEnvironment(macCatalyst)
	@objc(_focusRingType)
	var focusRingType: UInt {
		return 1 // NSFocusRingTypeNone
	}
	#endif

	/// Corner radius of view; also inspectable from Storyboard.
	var layerCornerRadius: CGFloat {
		get {
			return self.layer.cornerRadius
		}
		set {
			self.layer.masksToBounds = true
			self.layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
		}
	}

	// MARK: - Functions
	/// Adds parallax effect to the view.
	///
	/// - Parameter amount: The amount by which the view moves around. Default amount is `50`.
	func addParallax(with amount: Int = 50) {
		let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
		horizontal.minimumRelativeValue = -amount
		horizontal.maximumRelativeValue = amount

		let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
		vertical.minimumRelativeValue = -amount
		vertical.maximumRelativeValue = amount

		let group = UIMotionEffectGroup()
		group.motionEffects = [horizontal, vertical]
		self.addMotionEffect(group)
	}

	/// Fade in view.
	///
	/// - Parameters:
	///    - duration: Animation duration in seconds (default is 0.80 second).
	///    - completion: Optional completion handler to run with animation finishes (default is `nil`).
	func animateFadeIn(duration: TimeInterval = 0.80, completion: ((Bool) -> Void)? = nil) {
		if self.alpha != 0.0 {
			self.alpha = 0.0
		}
		UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: [.allowUserInteraction, .curveEaseOut], animations: { [weak self] in
			guard let self = self else { return }
			self.alpha = 1.0
		}, completion: completion)
	}

	/// Fade out view.
	///
	///	- Parameters:
	///    - duration: Animation duration in seconds (default is 0.25 second).
	///    - completion: Optional completion handler to run with animation finishes (default is `nil`).
	func animateFadeOut(duration: TimeInterval = 0.25, completion: ((Bool) -> Void)? = nil) {
		UIView.animate(withDuration: duration, animations: { [weak self] in
			guard let self = self else { return }
			self.alpha = 0.0
		}, completion: completion)
	}

	/// Bounces the view with the given growth value.
	///
	/// - Parameters:
	///    - growth: The given float value used to bounce the view (default is `1.25`).
	///   - completion: The completion block that gets called after the animation finishes (default is `nil`).
	func animateBounce(growth: CGFloat = 1.25, completion: ((Bool) -> Void)? = nil) {
		transform = .identity
		UIView.animate(withDuration: 0.2, animations: { [weak self] in
			guard let self = self else { return }
			self.transform = self.transform.scaledBy(x: growth, y: growth)
		}) { _ in
			UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: [.curveEaseIn, .allowUserInteraction], animations: { [weak self] in
				guard let self = self else { return }
				self.transform = .identity
			}, completion: completion)
		}
	}

	/// Give the view a nice shadow.
	///
	/// - Parameters:
	///    - withView: The view used to set the bounds of the shadow (default is `self`).
	///    - color: The color of the shadow (default is `.black`).
	///    - opacity: The opacity of the shadow (default is `0.2`).
	///    - radius: The radius of the shadow (default is `8`).
	///    - offset: The offset of the shadow (default is `.zero`).
	///    - pathSize: The path size of the shadow (default is `nil`).
	///    - shouldRasterize: Whether the shadow should be rasterized for better performance (default is `true`).
	///    - cornerRadius: The corner radius of the path size (default is `10`).
	func applyShadow(withView view: UIView? = nil, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 8, offset: CGSize = .zero, pathSize: CGSize? = nil, shouldRasterize: Bool = true, cornerRadius: CGFloat = 10) {
//		let roundedRect = (view ?? self).bounds.offsetBy(dx: 0, dy: 10)
//		let shadowPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)

		self.layer.shadowColor = color.cgColor
		self.layer.shadowOpacity = opacity
		self.layer.shadowRadius = radius
		self.layer.shadowOffset = offset
		self.layer.masksToBounds = false
//		self.layer.shadowPath = shadowPath.cgPath

		self.layer.shouldRasterize = shouldRasterize
		self.layer.rasterizationScale = shouldRasterize ? UIScreen.main.scale : 1.0
	}
}

// MARK: - Constraints
extension UIView {
	/// Search constraints until we find one for the given view
	/// and attribute. This will enumerate ancestors since constraints are
	/// always added to the common ancestor.
	///
	/// - Parameter attribute: the attribute to find.
	/// - Parameter at: the view to find.
	///
	/// - Returns: matching constraint.
	func findConstraint(attribute: NSLayoutConstraint.Attribute, for view: UIView) -> NSLayoutConstraint? {
		let constraint = self.constraints.first {
			($0.firstAttribute == attribute && $0.firstItem as? UIView == view) ||
				($0.secondAttribute == attribute && $0.secondItem as? UIView == view)
		}
		return constraint ?? self.superview?.findConstraint(attribute: attribute, for: view)
	}

	/// First top constraint for this view.
	var topConstraint: NSLayoutConstraint? {
		self.findConstraint(attribute: .top, for: self)
	}

	/// First bottom constraint for this view.
	var bottomConstraint: NSLayoutConstraint? {
		self.findConstraint(attribute: .bottom, for: self)
	}

	/// Anchor all sides of the view into it's superview.
	///
	/// - Note: This will set `translatesAutoresizingMaskIntoConstraints` to `false`.
	func fillToSuperview() {
		self.translatesAutoresizingMaskIntoConstraints = false

		if let superview = self.superview {
			let leading = self.leadingAnchor.constraint(equalTo: superview.leadingAnchor)
			let trailing = self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
			let top = self.topAnchor.constraint(equalTo: superview.topAnchor)
			let bottom = self.bottomAnchor.constraint(equalTo: superview.bottomAnchor)

			NSLayoutConstraint.activate([leading, trailing, top, bottom])
		}
	}
}
