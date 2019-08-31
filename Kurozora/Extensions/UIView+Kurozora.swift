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
		Add rounded corners for each specified corner.

		- Parameter corners: The corner which should be rounded.
		- Parameter radius: The amount by which the corner should be rounded.
	*/
	func roundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
		clipsToBounds = true
		layer.cornerRadius = radius
		layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
	}
	
	/**
		Give the view a nice shadow.

		- Parameter shadowColor: The color of the shadow. Default is `.black`.
		- Parameter shadowOpacity: The opacity of the shadow. Default is `0.2`.
		- Parameter shadowRadius: The radius of the shadow. Default is `8`.
		- Parameter shadowOffset: The offset of the shadow. Default is `.zero`.
		- Parameter shadowPathSize: The path size of the shadow. Default is `nil`.
		- Parameter shouldRasterize: Whether the shadow should be rasterized for better performance. Default is `true`.
		- Parameter cornerRadius: The corner radius of the path size. Default is `nil`.
	*/
	func applyShadow(shadowColor: UIColor = .black, shadowOpacity: Float = 0.2, shadowRadius: CGFloat = 8, shadowOffset: CGSize = .zero, shadowPathSize: CGSize? = nil, shouldRasterize: Bool = true, cornerRadius: CGFloat? = nil) {

		let shadowWidth = self.width * 0.77
		let shadowHeight = self.height * 0.5

		let xTranslate = (self.width - shadowWidth) / 2
		let yTranslate = (self.height - shadowHeight) + 4

		let shadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: xTranslate, y: yTranslate), size: shadowPathSize ?? CGSize(width: shadowWidth, height: shadowHeight)), cornerRadius: cornerRadius ?? self.layer.cornerRadius)

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
		Adds parallax effect to the view.

		- Parameter amount: The amount by which the view moves around. Default amount is 50.
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
}
