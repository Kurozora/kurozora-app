//
//  WebPImageProcessor.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 07/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Kingfisher
import UIKit

/// A Kingfisher processor that decodes WebP data, which watchOS ImageIO cannot.
struct WebPImageProcessor: ImageProcessor {
	// MARK: - Properties
	let identifier: String

	private let maxPixelWidth: CGFloat
	private let scale: CGFloat

	// MARK: - Initializers
	/// Creates a processor that decodes and downsamples to the given width.
	///
	/// - Parameters:
	///   - maxPixelWidth: The widest the decoded image should be, in pixels.
	///   - scale: The display scale the image renders at.
	init(maxPixelWidth: CGFloat, scale: CGFloat) {
		self.maxPixelWidth = maxPixelWidth
		self.scale = scale

		// The width belongs in the identifier so Kingfisher caches each size separately.
		self.identifier = "app.kurozora.watch.webp(\(Int(maxPixelWidth)))"
	}

	// MARK: - Functions
	func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
		switch item {
		case .image(let image):
			return image
		case .data(let data):
			guard WebPDecoder.isWebP(data) else {
				return DefaultImageProcessor.default.process(item: item, options: options)
			}

			guard let cgImage = WebPDecoder.decode(data, maxPixelWidth: self.maxPixelWidth) else {
				return nil
			}

			return KFCrossPlatformImage(cgImage: cgImage, scale: self.scale, orientation: .up)
		}
	}
}
