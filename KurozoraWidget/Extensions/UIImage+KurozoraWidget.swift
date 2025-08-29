//
//  UIImage+KurozoraWidget.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/10/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

extension UIImage {
	/// Resizes the image to the specified width while maintaining aspect ratio.
	///
	/// - Parameters:
	///   - targetWidth: The desired width of the resized image.
	///   - isOpaque: A Boolean value indicating whether the image is opaque. Default is `true`.
	///   - scale: The scale factor to apply to the image. Default is the device's main screen scale.
	///
	/// - Returns: A new `UIImage` object resized to the specified width, or `nil` if the operation fails.
	func resized(toWidth targetWidth: CGFloat, isOpaque: Bool = true, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
		guard self.size.width > 0, self.size.height > 0 else { return nil }

		// Compute target size while keeping aspect ratio
		let aspectRatio = self.size.height / self.size.width
		let targetSize = CGSize(width: targetWidth, height: ceil(targetWidth * aspectRatio))

		// Use renderer with correct scale + opacity
		let format = UIGraphicsImageRendererFormat()
		format.scale = scale // Ensures sharpness on Retina
		format.opaque = isOpaque // Smaller memory if opaque

		let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
		return renderer.image { _ in
			self.draw(in: CGRect(origin: .zero, size: targetSize))
		}
	}
}
