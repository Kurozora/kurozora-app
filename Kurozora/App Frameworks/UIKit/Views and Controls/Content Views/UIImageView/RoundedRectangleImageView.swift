//
//  RoundedRectangleImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

/// `RoundedRectangleImageView` is a specially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `RoundedRectangleImageView` adjusts some options to achieve its design, this includes:
/// - Rounding the image's corners.
class RoundedRectangleImageView: UIImageView {
	/// The corner radius applied to the image view.
	private(set) var appliedCornerRadius: CGFloat = 10.0

	/// The vector mask that clips the imageView to a rounded-rectangle shape.
	private let cornerMaskLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.fillColor = UIColor.black.cgColor
		return layer
	}()

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.refreshCornerMask()
	}

	override var mask: UIView? {
		get {
			return super.mask
		}
		set {
			super.mask = newValue
			if newValue == nil {
				self.refreshCornerMask()
			}
		}
	}

	// MARK: - Functions
	/// Applies the given corner radius to the image view.
	///
	/// - Parameter cornerRadius: The corner radius to apply.
	func applyCornerRadius(_ cornerRadius: CGFloat) {
		self.appliedCornerRadius = cornerRadius
		self.refreshCornerMask()

		self.setNeedsLayout()
	}

	/// Updates the mask's path.
	private func refreshCornerMask() {
		guard self.bounds.width > 0, self.bounds.height > 0 else {
			return
		}

		let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.appliedCornerRadius)
		self.cornerMaskLayer.path = path.cgPath
		self.cornerMaskLayer.frame = self.bounds

		if self.layer.mask !== self.cornerMaskLayer && super.mask == nil {
			self.layer.mask = self.cornerMaskLayer
		}
	}
}
