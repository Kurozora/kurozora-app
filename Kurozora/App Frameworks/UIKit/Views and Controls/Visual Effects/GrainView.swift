//
//  GrainView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A view that overlays a tiled monochrome noise pattern, breaking up the banding large gradients show on eight bit displays.
class GrainView: UIView {
	// MARK: - Properties
	/// The tiled noise pattern, generated once and shared by every instance.
	private static let noisePattern: UIColor? = GrainView.makeNoisePattern(side: 96)

	/// The strength of the grain.
	var intensity: CGFloat = 0.05 {
		didSet {
			self.alpha = self.intensity
		}
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.isUserInteractionEnabled = false
		self.backgroundColor = Self.noisePattern
		self.alpha = self.intensity
	}

	/// Builds a tiling pattern color from a square of random grayscale pixels, fixed at three pixels per point because visionOS exposes no display scale.
	///
	/// - Parameter side: The width and height of the tile, in pixels.
	///
	/// - Returns: The pattern color.
	private static func makeNoisePattern(side: Int) -> UIColor? {
		var pixels = [UInt8]()
		pixels.reserveCapacity(side * side)

		for _ in 0..<(side * side) {
			pixels.append(UInt8.random(in: 96...160))
		}

		guard let provider = CGDataProvider(data: Data(pixels) as CFData) else { return nil }
		guard let cgImage = CGImage(width: side, height: side, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: side, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: 0), provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else { return nil }

		return UIColor(patternImage: UIImage(cgImage: cgImage, scale: 3.0, orientation: .up))
	}
}
