//
//  EpisodeDetailView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 06/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct EpisodeDetailView: View {
	// MARK: - Properties
	let episode: Episode

	/// Flips the watch status and reports back the status the server settled on.
	let onToggleWatched: () async -> Bool?

	@State private var isWatched: Bool
	@State private var isUpdating = false

	// MARK: - Initializers
	init(episode: Episode, isWatched: Bool, onToggleWatched: @escaping () async -> Bool?) {
		self.episode = episode
		self.onToggleWatched = onToggleWatched
		self._isWatched = State(initialValue: isWatched)
	}

	// MARK: - Body
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 8) {
				ArtworkView(
					media: self.episode.attributes.banner ?? self.episode.attributes.poster,
					shape: .banner,
					targetWidth: 200,
					cornerRadius: 6
				)
				.frame(maxWidth: .infinity)

				Text(self.episode.attributes.showTitle)
					.font(.caption2)
					.foregroundStyle(.secondary)

				Text(self.episode.attributes.title)
					.font(.headline)

				HStack(spacing: 6) {
					Text(self.episode.seasonEpisodeLabel)
					Text(self.episode.attributes.duration)
						.foregroundStyle(.secondary)
				}
				.font(.caption2)

				if self.episode.attributes.isFiller {
					Text("Filler")
						.font(.caption2)
						.foregroundStyle(.orange)
				}

				Button {
					self.toggleWatched()
				} label: {
					// Matches the iOS button, which prefixes a check character when watched
					// and shows no glyph otherwise.
					Text(self.isWatched ? "✓ Watched" : "Mark as Watched")
						.frame(maxWidth: .infinity)
				}
				.disabled(self.isUpdating)
				.padding(.vertical, 4)

				if let synopsis = self.episode.attributes.synopsis, !synopsis.isEmpty {
					Text(synopsis)
						.font(.caption2)
						.foregroundStyle(.secondary)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal)
		}
		.navigationTitle(self.episode.attributes.title)
	}

	// MARK: - Functions
	private func toggleWatched() {
		self.isUpdating = true

		Task {
			defer { self.isUpdating = false }

			guard let updated = await self.onToggleWatched() else { return }

			self.isWatched = updated
		}
	}

	// MARK: - Computed
	private var bannerURL: URL? {
		guard let urlString = episode.attributes.banner?.url else { return nil }
		return URL(string: urlString)
	}

}
