//
//  FloatingLyricsPreviewView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// An image view that renders floating lyrics frames for the settings preview.
final class FloatingLyricsPreviewView: UIImageView {
	// MARK: - Properties
	private var cachedRenderer: UIGraphicsImageRenderer?
	private var cachedRendererSize: CGSize = .zero

	/// The corner radius as a fraction of the preview's height.
	private static let cornerRadiusRatio: CGFloat = 0.22

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.contentMode = .scaleToFill
		self.layer.cornerCurve = .continuous
		self.clipsToBounds = true
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.cornerRadius = self.bounds.height * Self.cornerRadiusRatio
	}

	// MARK: - Functions
	/// Renders the given frame into the view.
	///
	/// - Parameter lyricsFrame: The frame to render.
	func render(_ lyricsFrame: FloatingLyricsFrame) {
		let canvasSize = FloatingLyricsRenderer.canvasSize(for: lyricsFrame.rows)

		var upsample: CGFloat = 1
		if self.bounds.width > 0 {
			let displayPixelWidth = self.bounds.width * max(1, self.traitCollection.displayScale)
			upsample = min(3, max(1, displayPixelWidth / canvasSize.width))
		}

		let imageSize = CGSize(width: canvasSize.width * upsample, height: canvasSize.height * upsample)

		if self.cachedRenderer == nil || self.cachedRendererSize != imageSize {
			let format = UIGraphicsImageRendererFormat()
			format.scale = 1
			format.opaque = true
			self.cachedRenderer = UIGraphicsImageRenderer(size: imageSize, format: format)
			self.cachedRendererSize = imageSize
		}

		self.image = self.cachedRenderer?.image { rendererContext in
			rendererContext.cgContext.scaleBy(x: upsample, y: upsample)
			FloatingLyricsRenderer.draw(lyricsFrame, in: rendererContext.cgContext, size: canvasSize)
		}
	}
}
