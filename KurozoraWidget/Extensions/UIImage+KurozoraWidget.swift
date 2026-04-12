//
//  UIImage+KurozoraWidget.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/10/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import ImageIO
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

	/// Creates a downsampled image directly from encoded data using ImageIO.
	///
	/// Unlike `resized(toWidth:)`, this never decodes the full-resolution image into
	/// memory — ImageIO produces the thumbnail at the target size during decode.
	/// Use this in memory-constrained environments such as widget extensions.
	///
	/// - Parameters:
	///   - data: The encoded image data (JPEG, PNG, etc.).
	///   - targetWidth: The maximum width in points for the resulting image.
	///   - scale: The display scale factor. Default is the device's main screen scale.
	///
	/// - Returns: A downsampled `UIImage`, or `nil` if the data cannot be decoded.
	static func downsample(data: Data, toWidth targetWidth: CGFloat, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
		let maxPixelSize = targetWidth * scale

		let sourceOptions: [CFString: Any] = [
			kCGImageSourceShouldCache: false
		]
		guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
			return nil
		}

		let downsampleOptions: [CFString: Any] = [
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceCreateThumbnailWithTransform: true,
			kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
			kCGImageSourceShouldCacheImmediately: true
		]
		guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions as CFDictionary) else {
			return nil
		}

		return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
	}
}
