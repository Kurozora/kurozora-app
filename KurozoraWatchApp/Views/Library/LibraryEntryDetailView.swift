//
//  LibraryEntryDetailView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// Shows one library entry with its status control, filled in from the local store and the server.
struct LibraryEntryDetailView: View {
	// MARK: - Properties
	@State private var viewModel: LibraryEntryDetailViewModel

	// MARK: - Initializers
	/// Opens the detail screen for a library entry or catalog item.
	///
	/// - Parameters:
	///    - item: The item's snapshot.
	///    - details: The server fields, when the caller already fetched the item.
	init(item: LibraryItem, details: LibraryEntryDetails? = nil) {
		self._viewModel = State(initialValue: LibraryEntryDetailViewModel(item: item, details: details))
	}

	// MARK: - Body
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {
				ArtworkView(
					url: self.viewModel.item.posterURL,
					backgroundColor: self.viewModel.item.posterBackgroundColor,
					shape: self.viewModel.item.kind.artworkShape,
					targetWidth: 80,
					cornerRadius: 8
				)
				.frame(width: 80)
				.frame(maxWidth: .infinity)

				Text(self.viewModel.item.title)
					.font(.headline)

				HStack(spacing: 6) {
					if let details = self.viewModel.details, let countLine = details.countLine {
						Label(countLine, systemImage: details.countSymbolName)
					}

					Spacer()

					if let statusName = self.viewModel.details?.statusName ?? self.viewModel.item.statusName {
						Text(statusName)
							.foregroundStyle(.secondary)
					}
				}
				.font(.caption2)

				LibraryStatusButton(
					kind: self.viewModel.item.kind,
					status: self.viewModel.libraryStatus,
					onSelect: { status in
						Task { await self.viewModel.setStatus(status) }
					},
					onRemove: {
						Task { await self.viewModel.removeFromLibrary() }
					}
				)
				.frame(maxWidth: .infinity)

				Divider()

				if let genres = self.viewModel.details?.genres, !genres.isEmpty {
					Text(genres.joined(separator: " \u{2022} "))
						.font(.caption2)
						.foregroundStyle(.secondary)
				}

				if let synopsis = self.viewModel.details?.synopsis, !synopsis.isEmpty {
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
