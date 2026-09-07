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
/// Displays a media resource's artwork at a fixed shape, cropping to fill.
struct ArtworkView: View {
	// MARK: - Properties
	let media: Media?

	var shape: ArtworkShape = .poster

	/// The width the artwork renders at, used to size the image request.
	var targetWidth: CGFloat = 100

	var cornerRadius: CGFloat = 4

	// MARK: - Body
	var body: some View {
		Color.clear
			.aspectRatio(self.shape.widthToHeight, contentMode: .fit)
			.overlay {
				CachedAsyncImage(url: self.media?.url, targetWidth: self.targetWidth) {
					self.backgroundColor
				}
			}
			.clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
	}

	// MARK: - Computed
	/// The media's own background color, matching what the iOS app sets on the image view.
	private var backgroundColor: Color {
		guard let hex = media?.backgroundColor, let color = Color(hex: hex) else {
			return Color.gray.opacity(0.3)
		}

		return color
	}
}
