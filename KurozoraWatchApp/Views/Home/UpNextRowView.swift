//
//  UpNextRowView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 06/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct UpNextRowView: View {
	// MARK: - Properties
	let episode: Episode

	// MARK: - Body
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			ArtworkView(
				media: self.artwork,
				shape: .banner,
				targetWidth: 180,
				cornerRadius: 8
			)

			Text(self.episode.attributes.title)
				.font(.headline)
				.lineLimit(1)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	// MARK: - Computed
	/// The banner, falling back to the poster the way the iOS app does.
	private var artwork: Media? {
		return self.episode.attributes.banner ?? self.episode.attributes.poster
	}
}

// MARK: - UpNextWatchedButton
/// The control that marks an Up Next episode as watched.
struct UpNextWatchedButton: View {
	// MARK: - Properties
	let isPending: Bool
	let onMarkWatched: () -> Void

	@Environment(WatchTheme.self) private var theme

	// MARK: - Body
	var body: some View {
		Button(action: self.onMarkWatched) {
			// Both states share one fixed box, otherwise swapping in the spinner resizes the
			// row and collapses the banner above it.
			ZStack {
				Image(systemName: "checkmark.circle")
					.imageScale(.large)
					.foregroundStyle(self.theme.tint)
					.opacity(self.isPending ? 0 : 1)

				ProgressView()
					.controlSize(.mini)
					.opacity(self.isPending ? 1 : 0)
			}
			.frame(width: 28, height: 28)
		}
		.buttonStyle(.plain)
		.disabled(self.isPending)
	}
}
