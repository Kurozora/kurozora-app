//
//  UIView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIView {
	/// Add rounded corners for each specified corner.
	func roundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
		if #available(iOS 11.0, *) {
			clipsToBounds = true
			layer.cornerRadius = radius
			layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
		} else {
			let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
			let mask = CAShapeLayer()
			mask.path = path.cgPath
			layer.mask = mask
		}
	}
	
	/// Give the view a nice shadow
	func applyShadow(shadowColor: UIColor = .black, shadowOpacity: Float = 0.2, shadowRadius: CGFloat = 8, shadowOffset: CGSize = .zero, shadowPathSize: CGSize? = nil, shouldRasterize: Bool = false, cornerRadius: CGFloat? = nil) {

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

	/// Adds parallax effect to view. Default amount is 50.
	func addParallax(with amount: Int = 50) {
		let amount = amount

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

	/// Create a snapshot of current view.
	func createSnapshot() -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
		drawHierarchy(in: frame, afterScreenUpdates: true)

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}

	//	func asImage() -> UIImage {
	//		if #available(iOS 10.0, *) {
	//			let renderer = UIGraphicsImageRenderer(bounds: bounds)
	//			return renderer.image { rendererContext in
	//				layer.render(in: rendererContext.cgContext)
	//			}
	//		} else {
	//			UIGraphicsBeginImageContext(self.frame.size)
	//			self.layer.render(in: UIGraphicsGetCurrentContext()!)
	//			let image = UIGraphicsGetImageFromCurrentImageContext()
	//			UIGraphicsEndImageContext()
	//			return UIImage(cgImage: image!.cgImage!)
	//		}
	//	}
}
