//
//  MediaTransitionProxy.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// An image view that stands in for the media during the viewer's transitions.
final class MediaTransitionProxy: UIImageView {
	// MARK: - Properties
	/// The thumbnail width that separates small thumbnails from large ones.
	static let smallThumbnailWidth: CGFloat = 200.0

	// MARK: - Initializers
	/// Creates a proxy that displays the given image.
	///
	/// - Parameters:
	///    - image: The image to display.
	///    - cornerRadius: The corner radius to start from.
	init(image: UIImage?, cornerRadius: CGFloat) {
		super.init(image: image)

		self.contentMode = .scaleAspectFill
		self.clipsToBounds = true
		self.accessibilityIgnoresInvertColors = true
		self.layer.cornerCurve = .continuous
		self.layer.cornerRadius = cornerRadius
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	/// Animates the proxy's corner radius and crop to the given values.
	///
	/// - Parameters:
	///    - cornerRadius: The corner radius to animate to.
	///    - contentsRect: The unit rect of the image to animate to.
	///    - duration: The duration of the animation.
	func animateMaskAndCrop(to cornerRadius: CGFloat, contentsRect: CGRect, duration: TimeInterval) {
		let radiusAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
		radiusAnimation.fromValue = self.layer.cornerRadius
		radiusAnimation.toValue = cornerRadius

		let cropAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.contentsRect))
		cropAnimation.fromValue = self.layer.contentsRect
		cropAnimation.toValue = contentsRect

		for animation in [radiusAnimation, cropAnimation] {
			animation.duration = duration
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			self.layer.add(animation, forKey: animation.keyPath)
		}

		self.layer.cornerRadius = cornerRadius
		self.layer.contentsRect = contentsRect
	}

	/// Returns the rect that fits the given size inside the bounding rect while preserving its aspect ratio.
	///
	/// - Parameters:
	///    - size: The size to fit.
	///    - boundingRect: The rect to fit into.
	/// - Returns: The centered rect that preserves `size`'s aspect ratio.
	static func aspectFitRect(for size: CGSize, in boundingRect: CGRect) -> CGRect {
		guard size.width > 0, size.height > 0 else {
			return boundingRect
		}

		let scale = min(boundingRect.width / size.width, boundingRect.height / size.height)
		let fittedSize = CGSize(width: size.width * scale, height: size.height * scale)

		return CGRect(
			x: boundingRect.midX - fittedSize.width / 2.0,
			y: boundingRect.midY - fittedSize.height / 2.0,
			width: fittedSize.width,
			height: fittedSize.height
		)
	}

	/// Returns the corner radius the given image view renders with.
	///
	/// - Parameter imageView: The image view to measure.
	/// - Returns: The rendered corner radius.
	static func cornerRadius(of imageView: UIImageView) -> CGFloat {
		switch imageView {
		case is CircularImageView:
			return imageView.bounds.height / 2.0
		case let roundedImageView as RoundedRectangleImageView:
			return roundedImageView.appliedCornerRadius
		default:
			return imageView.layer.cornerRadius
		}
	}
}
