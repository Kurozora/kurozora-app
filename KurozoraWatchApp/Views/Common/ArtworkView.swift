//
//  ArtworkView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 07/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

// MARK: - ArtworkShape
/// The aspect ratios artwork is rendered at, matching the iOS app's constraints.
enum ArtworkShape {
	/// The ratio used for show and literature posters.
	case poster

	/// The ratio used for episode banners.
	case banner

	/// The ratio used for game posters.
	case square

	/// The artwork's width relative to its height.
	var widthToHeight: CGFloat {
		switch self {
		case .poster:
			return 2.0 / 3.0
		case .banner:
			return 16.0 / 9.0
		case .square:
			return 1.0
		}
	}
}

// MARK: - ArtworkView
/// Displays artwork at a fixed shape, cropping to fill.
struct ArtworkView: View {
	// MARK: - Properties
	let url: String?

	/// The hex color shown until the artwork loads, matching what the iOS app sets on the image view.
	let backgroundColorHex: String?

	let shape: ArtworkShape

	/// The width the artwork renders at, used to size the image request.
	let targetWidth: CGFloat

	let cornerRadius: CGFloat

	// MARK: - Initializers
	/// Creates the view for a media resource.
	///
	/// - Parameters:
	///    - media: The media resource to display.
	///    - shape: The aspect ratio to render at.
	///    - targetWidth: The width the artwork renders at.
	///    - cornerRadius: The radius of the clipping corners.
	init(media: Media?, shape: ArtworkShape = .poster, targetWidth: CGFloat = 100, cornerRadius: CGFloat = 4) {
		self.init(url: media?.url, backgroundColor: media?.backgroundColor, shape: shape, targetWidth: targetWidth, cornerRadius: cornerRadius)
	}

	/// Creates the view for artwork stored as a URL and a placeholder color.
	///
	/// - Parameters:
	///    - url: The artwork URL.
	///    - backgroundColor: The hex color shown until the artwork loads.
	///    - shape: The aspect ratio to render at.
	///    - targetWidth: The width the artwork renders at.
	///    - cornerRadius: The radius of the clipping corners.
	init(url: String?, backgroundColor: String?, shape: ArtworkShape = .poster, targetWidth: CGFloat = 100, cornerRadius: CGFloat = 4) {
		self.url = url
		self.backgroundColorHex = backgroundColor
		self.shape = shape
		self.targetWidth = targetWidth
		self.cornerRadius = cornerRadius
	}

	// MARK: - Body
	var body: some View {
		Color.clear
			.aspectRatio(self.shape.widthToHeight, contentMode: .fit)
			.overlay {
				CachedAsyncImage(url: self.url, targetWidth: self.targetWidth) {
					self.backgroundColor
				}
			}
			.clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
	}

	// MARK: - Computed
	private var backgroundColor: Color {
		guard let hex = self.backgroundColorHex, let color = Color(hex: hex) else {
			return Color.gray.opacity(0.3)
		}

		return color
	}
}
