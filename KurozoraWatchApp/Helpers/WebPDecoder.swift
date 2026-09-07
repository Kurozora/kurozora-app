//
//  WebPDecoder.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 07/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreGraphics
import Foundation
import libwebp

/// Decodes WebP image data on watchOS.
enum WebPDecoder {
	// MARK: - Functions
	// watchOS ImageIO omits WebP from CGImageSourceCopyTypeIdentifiers(), so libwebp does
	// the decoding that UIImage(data:) cannot.

	/// Returns whether the data carries a WebP container.
	///
	/// - Parameter data: The encoded image data.
	///
	/// - Returns: `true` when the bytes begin with a RIFF/WEBP header.
	static func isWebP(_ data: Data) -> Bool {
		guard data.count >= 12 else { return false }

		return data[0] == 0x52 && data[1] == 0x49 && data[2] == 0x46 && data[3] == 0x46
			&& data[8] == 0x57 && data[9] == 0x45 && data[10] == 0x42 && data[11] == 0x50
	}

	/// Decodes WebP data into an image, scaling it down to the requested width.
	///
	/// - Parameters:
	///   - data: The encoded WebP data.
	///   - maxPixelWidth: The widest the result should be, in pixels.
	///
	/// - Returns: The decoded image.
	static func decode(_ data: Data, maxPixelWidth: CGFloat) -> CGImage? {
		var width: Int32 = 0
		var height: Int32 = 0

		let hasInfo = data.withUnsafeBytes { buffer -> Bool in
			guard let base = buffer.bindMemory(to: UInt8.self).baseAddress else { return false }
			return WebPGetInfo(base, buffer.count, &width, &height) != 0
		}

		guard hasInfo, width > 0, height > 0 else { return nil }

		let scaled = self.scaledSize(width: Int(width), height: Int(height), maxPixelWidth: maxPixelWidth)

		guard let image = self.decodeRGBA(data, width: &width, height: &height) else { return nil }

		guard scaled.width < Int(width) else { return image }

		return self.resized(image, to: scaled)
	}

	// MARK: - Private
	private static func decodeRGBA(_ data: Data, width: inout Int32, height: inout Int32) -> CGImage? {
		var localWidth = width
		var localHeight = height

		let pixels: Data? = data.withUnsafeBytes { buffer -> Data? in
			guard let base = buffer.bindMemory(to: UInt8.self).baseAddress,
				  let rgba = WebPDecodeRGBA(base, buffer.count, &localWidth, &localHeight)
			else { return nil }

			defer { WebPFree(rgba) }

			let byteCount = Int(localWidth) * Int(localHeight) * 4
			return Data(bytes: rgba, count: byteCount)
		}

		guard let pixels, let provider = CGDataProvider(data: pixels as CFData) else { return nil }

		width = localWidth
		height = localHeight

		return CGImage(
			width: Int(localWidth),
			height: Int(localHeight),
			bitsPerComponent: 8,
			bitsPerPixel: 32,
			bytesPerRow: Int(localWidth) * 4,
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
			provider: provider,
			decode: nil,
			shouldInterpolate: true,
			intent: .defaultIntent
		)
	}

	private static func scaledSize(width: Int, height: Int, maxPixelWidth: CGFloat) -> (width: Int, height: Int) {
		guard maxPixelWidth > 0, CGFloat(width) > maxPixelWidth else {
			return (width, height)
		}

		let ratio = maxPixelWidth / CGFloat(width)
		return (Int(maxPixelWidth.rounded()), max(1, Int((CGFloat(height) * ratio).rounded())))
	}

	private static func resized(_ image: CGImage, to size: (width: Int, height: Int)) -> CGImage? {
		guard let context = CGContext(
			data: nil,
			width: size.width,
			height: size.height,
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
		) else { return image }

		context.interpolationQuality = .high
		context.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

		return context.makeImage() ?? image
	}
}
