//
//  UIView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIView {

	/**
		Adds parallax effect to the view.

		- Parameter amount: The amount by which the view moves around. Default amount is `50`.
	*/
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

	/**
		Bounces the view with the given growth value.

		- Parameter growth: The given float value used to bounce the view (default is `1.25`).
	*/
	func animateBounce(growth: CGFloat = 1.25) {
		transform = .identity
		UIView.animate(withDuration: 0.2, animations: { () -> Void in
			self.transform = self.transform.scaledBy(x: growth, y: growth)
		}) { completion in
			UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: [.curveEaseIn, .allowUserInteraction], animations: { () -> Void in
				self.transform = .identity
			}, completion: nil)
		}
	}

	/**
		Give the view a nice shadow.

		- Parameter withView: The view used to set the bounds of the shadow (default is `self`).
		- Parameter shadowColor: The color of the shadow (default is `.black`).
		- Parameter shadowOpacity: The opacity of the shadow (default is `0.2`).
		- Parameter shadowRadius: The radius of the shadow (default is `8`).
		- Parameter shadowOffset: The offset of the shadow (default is `.zero`).
		- Parameter shadowPathSize: The path size of the shadow (default is `nil`).
		- Parameter shouldRasterize: Whether the shadow should be rasterized for better performance (default is `true`).
		- Parameter cornerRadius: The corner radius of the path size (default is `10`).
	*/
	func applyShadow(withView view: UIView? = nil, shadowColor: UIColor = .black, shadowOpacity: Float = 0.5, shadowRadius: CGFloat = 8, shadowOffset: CGSize = .zero, shadowPathSize: CGSize? = nil, shouldRasterize: Bool = true, cornerRadius: CGFloat = 10) {
		let roundedRect = (view ?? self).bounds.offsetBy(dx: 0, dy: 10)
		let shadowPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)

		self.layer.shadowColor = shadowColor.cgColor
		self.layer.shadowOpacity = shadowOpacity
		self.layer.shadowRadius = shadowRadius
		self.layer.shadowOffset = shadowOffset
		self.layer.masksToBounds = false
		self.layer.shadowPath = shadowPath.cgPath

		if shouldRasterize {
			self.layer.shouldRasterize = true
			self.layer.rasterizationScale = UIScreen.main.scale
		}
	}

	/**
		Create a snapshot of current view.

		- Returns: an image of the created snapshot of the view.
	*/
	func createSnapshot() -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
		drawHierarchy(in: frame, afterScreenUpdates: true)

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}

	/**
		Add rounded corners for each specified corner.

		- Parameter corners: The corner which should be rounded.
		- Parameter radius: The amount by which the corner should be rounded.
	*/
	func roundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
		clipsToBounds = true
		layer.cornerRadius = radius
		layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
	}

}
