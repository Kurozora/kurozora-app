//
//  GaussianBlur.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreImage
import Obfuscation
import QuartzCore
import UIKit

/// A factory for blur layer filters and blurred images.
struct GaussianBlur {
	// MARK: - Properties
	/// The context shared by every image blur.
	private static let renderingContext = CIContext(options: [.useSoftwareRenderer: false])

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Returns a blurred copy of the given image, letting the blur fade into the image's transparent margin.
	///
	/// - Parameters:
	///    - image: The image to blur.
	///    - radius: The blur radius in points.
	///
	/// - Returns: The blurred image.
	static func blurred(_ image: UIImage, radius: CGFloat) -> UIImage? {
		guard radius > 0, let cgImage = image.cgImage else { return image }

		let inputImage = CIImage(cgImage: cgImage)
		guard let filter = CIFilter(name: "CIGaussianBlur", parameters: [
			kCIInputImageKey: inputImage,
			kCIInputRadiusKey: radius * image.scale
		]) else { return nil }
		guard let outputImage = filter.outputImage else { return nil }
		guard let blurredImage = Self.renderingContext.createCGImage(outputImage, from: inputImage.extent) else { return nil }

		return UIImage(cgImage: blurredImage, scale: image.scale, orientation: image.imageOrientation)
	}

	/// Creates a `gaussianBlur` filter with the given radius.
	///
	/// - Parameters:
	///    - radius: The blur radius in points.
	///    - normalizesEdges: Whether the kernel clamps at the layer's bounds.
	///
	/// - Returns: The configured filter.
	static func filter(radius: CGFloat, normalizesEdges: Bool = false) -> NSObject? {
		guard let filterClass = NSClassFromString("CAFilter") else { return nil }

		let selector = NSSelectorFromString("filterWithName:")
		guard let unmanaged = (filterClass as AnyObject).perform(selector, with: "gaussianBlur") else { return nil }
		guard let filter = unmanaged.takeUnretainedValue() as? NSObject else { return nil }

		filter.setValue(radius, forKey: "inputRadius")

		if normalizesEdges {
			filter.setValue(true, forKey: #obfuscated("inputNormalizeEdges"))
		}

		return filter
	}
}
