//
//  ReCapShareGlow.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import ImageIO
import UIKit

/// The glowing background of a Re:CAP share card.
nonisolated enum ReCapShareGlow {
	// MARK: - Types
	/// The glow of a share card layout.
	enum Layout: Sendable {
		case genres
		case comparison
		case summary

		/// The name of the layout's field in the asset catalog.
		var assetName: String {
			switch self {
			case .genres: return "recap/share.glow.genres"
			case .comparison: return "recap/share.glow.comparison"
			case .summary: return "recap/share.glow.summary"
			}
		}

		/// The rows where the field has a hard edge.
		var splits: [Int] {
			switch self {
			case .comparison: return [1096]
			case .genres, .summary: return []
			}
		}
	}

	/// A color as sRGB channels between 0 and 1.
	struct Channels: Sendable {
		let red: Double
		let green: Double
		let blue: Double

		/// Creates the channels of the given color.
		///
		/// - Parameter color: The color to convert.
		init(_ color: UIColor) {
			var red: CGFloat = 0.0
			var green: CGFloat = 0.0
			var blue: CGFloat = 0.0
			var alpha: CGFloat = 0.0
			color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
			self.red = Double(red)
			self.green = Double(green)
			self.blue = Double(blue)
		}

		init(red: Double, green: Double, blue: Double) {
			self.red = red
			self.green = green
			self.blue = blue
		}
	}

	/// A decoded glow field.
	private struct Field {
		let width: Int
		let height: Int
		let coverage: [Float]
		let mix: [Float]
		let chroma: [Float]
	}

	// MARK: - Properties
	/// The size of a share card.
	static let size = CGSize(width: 1080.0, height: 1920.0)

	/// The largest chroma scale a field stores.
	private static let maxChroma = 1.1

	/// The strength of the overlay grain.
	private static let grain = 0.09

	// MARK: - Functions
	/// Paints the glow of the given layout in the recap colors over the background.
	///
	/// - Parameters:
	///    - layout: The layout whose glow to paint.
	///    - fieldData: The PNG data of the layout's field.
	///    - first: The recap's first color.
	///    - second: The recap's second color.
	///    - background: The color behind the glow.
	///
	/// - Returns: The painted glow.
	@concurrent
	static func render(layout: Layout, fieldData: Data, first: Channels, second: Channels, background: Channels) async -> CGImage? {
		guard let field = self.decodeField(fieldData) else { return nil }

		let width = Int(self.size.width)
		let height = Int(self.size.height)
		let table = self.mixTable(from: first, to: second)
		let backgroundChannels = [background.red, background.green, background.blue]
		var pixels = [UInt8](repeating: 255, count: width * height * 4)
		var generator = SystemRandomNumberGenerator()
		let bounds = [0] + layout.splits + [height]
		let scale = Double(height) / Double(field.height)

		for region in 0 ..< bounds.count - 1 {
			let top = bounds[region]
			let bottom = bounds[region + 1]
			let gridTop = Int((Double(top) / scale).rounded())
			let gridBottom = Int((Double(bottom) / scale).rounded())
			let coverage = self.upsample(field.coverage, gridWidth: field.width, gridTop: gridTop, gridBottom: gridBottom, width: width, height: bottom - top)
			let mix = self.upsample(field.mix, gridWidth: field.width, gridTop: gridTop, gridBottom: gridBottom, width: width, height: bottom - top)
			let chroma = self.upsample(field.chroma, gridWidth: field.width, gridTop: gridTop, gridBottom: gridBottom, width: width, height: bottom - top)

			pixels.withUnsafeMutableBufferPointer { pixels in
				table.withUnsafeBufferPointer { table in
					for y in top ..< bottom {
						for x in 0 ..< width {
							let index = (y - top) * width + x
							let alpha = Double(min(max(coverage[index], 0.0), 1.0))
							let step = Int((min(max(mix[index], 0.0), 1.0) * 255.0).rounded())
							let level = Int((min(max(chroma[index], 0.0), 1.0) * 63.0).rounded())
							let color = (step * 64 + level) * 3
							let grain = Double.random(in: 0.0 ..< 1.0, using: &generator)
							let pixel = (y * width + x) * 4

							for channel in 0 ..< 3 {
								let value = backgroundChannels[channel] + (Double(table[color + channel]) - backgroundChannels[channel]) * alpha
								let overlay = value < 0.5 ? 2.0 * value * grain : 1.0 - 2.0 * (1.0 - value) * (1.0 - grain)
								let grained = value + (overlay - value) * self.grain
								pixels[pixel + channel] = UInt8((min(max(grained, 0.0), 1.0) * 255.0).rounded())
							}
						}
					}
				}
			}
		}

		guard
			let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
			let provider = CGDataProvider(data: Data(pixels) as CFData)
		else { return nil }

		return CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue), provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
	}

	/// Returns the channels of a glow field PNG.
	///
	/// - Parameter data: The PNG data.
	///
	/// - Returns: The decoded field.
	private static func decodeField(_ data: Data) -> Field? {
		guard
			let source = CGImageSourceCreateWithData(data as CFData, nil),
			let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
		else { return nil }

		let width = image.width
		let height = image.height
		var bytes = [UInt8](repeating: 0, count: width * height * 4)
		let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()

		// Drawing in the image's own color space keeps the stored values as they are.
		let isDrawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
			guard let context = CGContext(data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return false }
			context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
			return true
		}
		guard isDrawn else { return nil }

		let count = width * height
		var coverage = [Float](repeating: 0.0, count: count)
		var mix = [Float](repeating: 0.0, count: count)
		var chroma = [Float](repeating: 0.0, count: count)
		for index in 0 ..< count {
			coverage[index] = Float(bytes[index * 4]) / 255.0
			mix[index] = Float(bytes[index * 4 + 1]) / 255.0
			chroma[index] = Float(bytes[index * 4 + 2]) / 255.0
		}

		return Field(width: width, height: height, coverage: coverage, mix: mix, chroma: chroma)
	}

	/// Returns the Catmull-Rom weights at the given fraction.
	///
	/// - Parameter fraction: The position between two grid points.
	///
	/// - Returns: The weights of the four surrounding points.
	private static func cubicWeights(_ fraction: Float) -> (Float, Float, Float, Float) {
		let squared = fraction * fraction
		let cubed = squared * fraction

		return (
			-0.5 * cubed + squared - 0.5 * fraction,
			1.5 * cubed - 2.5 * squared + 1.0,
			-1.5 * cubed + 2.0 * squared + 0.5 * fraction,
			0.5 * cubed - 0.5 * squared
		)
	}

	/// Returns rows of a field channel upsampled to the given size.
	///
	/// - Parameters:
	///    - values: The channel's values.
	///    - gridWidth: The width of the field.
	///    - gridTop: The first row to upsample.
	///    - gridBottom: The row after the last to upsample.
	///    - width: The width to upsample to.
	///    - height: The height to upsample to.
	///
	/// - Returns: The upsampled values.
	private static func upsample(_ values: [Float], gridWidth: Int, gridTop: Int, gridBottom: Int, width: Int, height: Int) -> [Float] {
		let gridHeight = gridBottom - gridTop
		var horizontal = [Float](repeating: 0.0, count: width * gridHeight)
		var upsampled = [Float](repeating: 0.0, count: width * height)

		values.withUnsafeBufferPointer { values in
			horizontal.withUnsafeMutableBufferPointer { horizontal in
				for x in 0 ..< width {
					let source = (Float(x) + 0.5) * Float(gridWidth) / Float(width) - 0.5
					let base = Int(source.rounded(.down))
					let weights = self.cubicWeights(source - Float(base))
					let columns = (0 ..< 4).map { min(max(base - 1 + $0, 0), gridWidth - 1) }

					for row in 0 ..< gridHeight {
						let rowStart = (gridTop + row) * gridWidth
						horizontal[row * width + x] = values[rowStart + columns[0]] * weights.0 + values[rowStart + columns[1]] * weights.1
							+ values[rowStart + columns[2]] * weights.2 + values[rowStart + columns[3]] * weights.3
					}
				}
			}
		}

		horizontal.withUnsafeBufferPointer { horizontal in
			upsampled.withUnsafeMutableBufferPointer { upsampled in
				for y in 0 ..< height {
					let source = (Float(y) + 0.5) * Float(gridHeight) / Float(height) - 0.5
					let base = Int(source.rounded(.down))
					let weights = self.cubicWeights(source - Float(base))
					let rows = (0 ..< 4).map { min(max(base - 1 + $0, 0), gridHeight - 1) * width }

					for x in 0 ..< width {
						upsampled[y * width + x] = horizontal[rows[0] + x] * weights.0 + horizontal[rows[1] + x] * weights.1
							+ horizontal[rows[2] + x] * weights.2 + horizontal[rows[3] + x] * weights.3
					}
				}
			}
		}

		return upsampled
	}

	// MARK: - Color
	/// Returns the colors along the hue path between two colors by mix and chroma step.
	///
	/// - Parameters:
	///    - first: The color the path starts at.
	///    - second: The color the path ends at.
	///
	/// - Returns: The colors as consecutive sRGB channels.
	private static func mixTable(from first: Channels, to second: Channels) -> [Float] {
		let start = self.oklch(of: first)
		let end = self.oklch(of: second)
		var hueDelta = end.hue - start.hue
		if hueDelta > .pi { hueDelta -= 2.0 * .pi }
		if hueDelta < -.pi { hueDelta += 2.0 * .pi }

		var table = [Float](repeating: 0.0, count: 256 * 64 * 3)
		for step in 0 ..< 256 {
			let mix = Double(step) / 255.0
			for level in 0 ..< 64 {
				let color = self.srgb(
					lightness: start.lightness + (end.lightness - start.lightness) * mix,
					chroma: (start.chroma + (end.chroma - start.chroma) * mix) * (Double(level) / 63.0) * self.maxChroma,
					hue: start.hue + hueDelta * mix
				)
				let index = (step * 64 + level) * 3
				table[index] = Float(color.red)
				table[index + 1] = Float(color.green)
				table[index + 2] = Float(color.blue)
			}
		}

		return table
	}

	/// Returns the OKLCH form of an sRGB color.
	///
	/// - Parameter color: The color to convert.
	///
	/// - Returns: The lightness, chroma and hue of the color.
	private static func oklch(of color: Channels) -> (lightness: Double, chroma: Double, hue: Double) {
		let linear = [color.red, color.green, color.blue].map { $0 <= 0.04045 ? $0 / 12.92 : pow(($0 + 0.055) / 1.055, 2.4) }
		let long = cbrt(0.4122214708 * linear[0] + 0.5363325363 * linear[1] + 0.0514459929 * linear[2])
		let medium = cbrt(0.2119034982 * linear[0] + 0.6806995451 * linear[1] + 0.1073969566 * linear[2])
		let short = cbrt(0.0883024619 * linear[0] + 0.2817188376 * linear[1] + 0.6299787005 * linear[2])
		let a = 1.9779984951 * long - 2.428592205 * medium + 0.4505937099 * short
		let b = 0.0259040371 * long + 0.7827717662 * medium - 0.808675766 * short

		return (0.2104542553 * long + 0.793617785 * medium - 0.0040720468 * short, hypot(a, b), atan2(b, a))
	}

	/// Returns the sRGB form of an OKLCH color.
	///
	/// - Parameters:
	///    - lightness: The lightness of the color.
	///    - chroma: The chroma of the color.
	///    - hue: The hue of the color in radians.
	///
	/// - Returns: The sRGB channels of the color.
	private static func srgb(lightness: Double, chroma: Double, hue: Double) -> Channels {
		let a = chroma * cos(hue)
		let b = chroma * sin(hue)
		let long = pow(lightness + 0.3963377774 * a + 0.2158037573 * b, 3.0)
		let medium = pow(lightness - 0.1055613458 * a - 0.0638541728 * b, 3.0)
		let short = pow(lightness - 0.0894841775 * a - 1.291485548 * b, 3.0)
		let encode = { (linear: Double) -> Double in
			let clamped = min(max(linear, 0.0), 1.0)
			return clamped <= 0.0031308 ? clamped * 12.92 : 1.055 * pow(clamped, 1.0 / 2.4) - 0.055
		}

		return Channels(
			red: encode(4.0767416621 * long - 3.3077115913 * medium + 0.2309699292 * short),
			green: encode(-1.2684380046 * long + 2.6097574011 * medium - 0.3413193965 * short),
			blue: encode(-0.0041960863 * long - 0.7034186147 * medium + 1.707614701 * short)
		)
	}
}
