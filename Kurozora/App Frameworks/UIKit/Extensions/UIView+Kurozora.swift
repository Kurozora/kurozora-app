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
	/// - Parameters:
	///    - duration: animation duration in seconds (default is 0.80 second).
	///    - completion: optional completion handler to run with animation finishes (default is nil)
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
	///    - duration: animation duration in seconds (default is 0.25 second).
	///    - completion: optional completion handler to run with animation finishes (default is nil)
	func animateFadeOut(duration: TimeInterval = 0.25, completion: ((Bool) -> Void)? = nil) {
		UIView.animate(withDuration: duration, animations: { [weak self] in
			guard let self = self else { return }
			self.alpha = 0.0
		}, completion: completion)
	}

	/// Bounces the view with the given growth value.
	///
	/// - Parameter growth: The given float value used to bounce the view (default is `1.25`).
	func animateBounce(growth: CGFloat = 1.25) {
		transform = .identity
		UIView.animate(withDuration: 0.2, animations: { [weak self] in
			guard let self = self else { return }
			self.transform = self.transform.scaledBy(x: growth, y: growth)
		}) { completion in
			UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: [.curveEaseIn, .allowUserInteraction], animations: { [weak self] in
				guard let self = self else { return }
				self.transform = .identity
			}, completion: nil)
		}
	}

	/// Give the view a nice shadow.
	///
	/// - Parameters:
	///    - withView: The view used to set the bounds of the shadow (default is `self`).
	///    - shadowColor: The color of the shadow (default is `.black`).
	///    - shadowOpacity: The opacity of the shadow (default is `0.2`).
	///    - shadowRadius: The radius of the shadow (default is `8`).
	///    - shadowOffset: The offset of the shadow (default is `.zero`).
	///    - shadowPathSize: The path size of the shadow (default is `nil`).
	///    - shouldRasterize: Whether the shadow should be rasterized for better performance (default is `true`).
	///    - cornerRadius: The corner radius of the path size (default is `10`).
	func applyShadow(withView view: UIView? = nil, shadowColor: UIColor = .black, shadowOpacity: Float = 0.5, shadowRadius: CGFloat = 8, shadowOffset: CGSize = .zero, shadowPathSize: CGSize? = nil, shouldRasterize: Bool = true, cornerRadius: CGFloat = 10) {
//		let roundedRect = (view ?? self).bounds.offsetBy(dx: 0, dy: 10)
//		let shadowPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)

		self.layer.shadowColor = shadowColor.cgColor
		self.layer.shadowOpacity = shadowOpacity
		self.layer.shadowRadius = shadowRadius
		self.layer.shadowOffset = shadowOffset
		self.layer.masksToBounds = false
//		self.layer.shadowPath = shadowPath.cgPath

		if shouldRasterize {
			self.layer.shouldRasterize = true
			self.layer.rasterizationScale = UIScreen.main.scale
		}
	}
}
