//
//  ShowDetailView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct ShowDetailView: View {
	// MARK: - Properties
	@State private var viewModel: ShowDetailViewModel

	// MARK: - Initializers
	/// Opens the detail screen for a library entry.
	///
	/// - Parameter item: The entry's snapshot.
	init(item: LibraryItem) {
		self._viewModel = State(initialValue: ShowDetailViewModel(item: item))
	}

	// MARK: - Body
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {
				ArtworkView(
					url: self.viewModel.item.posterURL,
					backgroundColor: self.viewModel.item.posterBackgroundColor,
					shape: .poster,
					targetWidth: 80,
					cornerRadius: 8
				)
				.frame(width: 80)
				.frame(maxWidth: .infinity)

				Text(self.viewModel.item.title)
					.font(.headline)

				HStack(spacing: 6) {
					if let show = self.viewModel.show {
						Label(L10n.episodeCount(show.attributes.episodeCount), systemImage: "film")
					}

					Spacer()

					if let statusName = self.viewModel.show?.attributes.status.name ?? self.viewModel.item.statusName {
						Text(statusName)
							.foregroundStyle(.secondary)
					}
				}
				.font(.caption2)

				LibraryStatusButton(
					status: self.viewModel.libraryStatus,
					onSelect: { status in
						Task { await self.viewModel.setStatus(status) }
					},
					onRemove: {
						Task { await self.viewModel.removeFromLibrary() }
					}
				)

				Divider()

				if let genres = self.viewModel.show?.attributes.genres, !genres.isEmpty {
					Text(genres.joined(separator: " \u{2022} "))
						.font(.caption2)
						.foregroundStyle(.secondary)
				}

				if let synopsis = self.viewModel.show?.attributes.synopsis, !synopsis.isEmpty {
					Text(synopsis)
						.font(.caption2)
						.foregroundStyle(.secondary)
				}
			}
			.padding(.horizontal)
		}
		.navigationTitle(self.viewModel.item.title)
		.task {
			await self.viewModel.start()
		}
	}
}
