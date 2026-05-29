//
//  CircularImageView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// `CircularImageView` is a specially crafted object that displays a single image or a sequence of animated images in your interface.
///
/// `CircularImageView` adjusts some options to achieve its design, this includes:
/// - Rounding the image's corners.
class CircularImageView: KImageView {
	// MARK: - Properties
	/// The normalized focal point in image coordinates.
	///
	/// Setting this offsets the displayed crop so the focal point sits as close to the circle's center as possible without exposing transparent gutters at the image's edges. `nil` falls back to the default centered crop.
	var focalPoint: CGPoint? {
		didSet {
			self.applyFocalPointCrop()
		}
	}

	/// The vector mask that clips the imageView to a circle.
	private let cornerMaskLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.fillColor = UIColor.black.cgColor
		return layer
	}()

	override var image: UIImage? {
		get {
			return super.image
		}
		set {
			super.image = newValue
			self.applyFocalPointCrop()
		}
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.refreshCornerMask()
		self.applyFocalPointCrop()
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
	/// Recomputes `layer.contentsRect` so the crop window is centered on `focalPoint`, clamped so it never extends past the image's edges.
	private func applyFocalPointCrop() {
		guard
			let focalPoint = self.focalPoint,
			let image = self.image,
			image.size.width > 0,
			image.size.height > 0,
			self.bounds.width > 0,
			self.bounds.height > 0
		else {
			self.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
			return
		}

		let imageAspect = image.size.width / image.size.height
		let viewAspect = self.bounds.width / self.bounds.height

		if imageAspect < viewAspect {
			let normalizedHeight = imageAspect / viewAspect
			let halfHeight = normalizedHeight / 2
			let centerY = max(halfHeight, min(1 - halfHeight, focalPoint.y))

			self.layer.contentsRect = CGRect(
				x: 0,
				y: centerY - halfHeight,
				width: 1,
				height: normalizedHeight
			)
		} else {
			let normalizedWidth = viewAspect / imageAspect
			let halfWidth = normalizedWidth / 2
			let centerX = max(halfWidth, min(1 - halfWidth, focalPoint.x))

			self.layer.contentsRect = CGRect(
				x: centerX - halfWidth,
				y: 0,
				width: normalizedWidth,
				height: 1
			)
		}
	}

	/// Updates the vector mask's path and re-attaches it if an external mask was cleared.
	private func refreshCornerMask() {
		guard self.bounds.width > 0, self.bounds.height > 0 else {
			return
		}

		let radius = self.bounds.height / 2
		let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
		self.cornerMaskLayer.path = path.cgPath
		self.cornerMaskLayer.frame = self.bounds

		if self.layer.mask !== self.cornerMaskLayer && super.mask == nil {
			self.layer.mask = self.cornerMaskLayer
		}
	}
}
