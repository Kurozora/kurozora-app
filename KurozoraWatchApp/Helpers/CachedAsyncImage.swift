//
//  CachedAsyncImage.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Kingfisher
import SwiftUI

/// Displays a remote image, falling back to a placeholder until it loads.
struct CachedAsyncImage<Placeholder: View>: View {
	// MARK: - Properties
	let url: URL?

	/// The width the image renders at, used to size the decode.
	var targetWidth: CGFloat = 100

	let placeholder: () -> Placeholder

	@Environment(\.displayScale) private var displayScale

	// MARK: - Body
	var body: some View {
		KFImage(self.url)
			.setProcessor(WebPImageProcessor(maxPixelWidth: self.targetWidth * self.displayScale, scale: self.displayScale))
			.cacheOriginalImage()
			.placeholder { self.placeholder() }
			.fade(duration: 0.15)
			.resizable()
			.aspectRatio(contentMode: .fill)
	}
}

// MARK: - Convenience Initializers
extension CachedAsyncImage where Placeholder == Color {
	init(url: URL?, targetWidth: CGFloat = 100) {
		self.url = url
		self.targetWidth = targetWidth
		self.placeholder = { Color.gray.opacity(0.3) }
	}
}

extension CachedAsyncImage where Placeholder == AnyView {
	init(url: String?, targetWidth: CGFloat = 100, placeholder: @escaping () -> some View) {
		if let urlString = url, let parsed = URL(string: urlString) {
			self.url = parsed
		} else {
			self.url = nil
		}

		self.targetWidth = targetWidth
		self.placeholder = { AnyView(placeholder()) }
	}
}
