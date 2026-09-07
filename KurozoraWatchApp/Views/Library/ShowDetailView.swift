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
	let show: Show

	/// The library status known by the presenting screen, if any.
	var initialLibraryStatus: LibraryStatus?

	@State private var libraryStatus: LibraryStatus?
	@State private var isUpdatingStatus = false


	// MARK: - Body
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {
				ArtworkView(
					media: self.show.attributes.poster,
					shape: .poster,
					targetWidth: 80,
					cornerRadius: 8
				)
				.frame(width: 80)
				.frame(maxWidth: .infinity)

				// Title
				Text(self.show.attributes.title)
					.font(.headline)

				// Metadata
				HStack(spacing: 6) {
					Label(L10n.episodeCount(self.show.attributes.episodeCount), systemImage: "film")
					Spacer()
					Text(self.show.attributes.status.name)
						.foregroundStyle(.secondary)
				}
				.font(.caption2)

				LibraryStatusButton(
					status: self.libraryStatus,
					isUpdating: self.isUpdatingStatus,
					onSelect: { newStatus in
						Task { await self.updateLibraryStatus(to: newStatus) }
					},
					onRemove: {
						Task { await self.removeFromLibrary() }
					}
				)

				Divider()

				if let genres = show.attributes.genres, !genres.isEmpty {
					Text(genres.joined(separator: " \u{2022} "))
						.font(.caption2)
						.foregroundStyle(.secondary)
				}

				if let synopsis = show.attributes.synopsis, !synopsis.isEmpty {
					Text(synopsis)
						.font(.caption2)
						.foregroundStyle(.secondary)
				}
			}
			.padding(.horizontal)
		}
		.navigationTitle(self.show.attributes.title)
		.onAppear {
			self.libraryStatus = self.initialLibraryStatus
		}
	}

	// MARK: - Computed
	private var posterURL: URL? {
		guard let urlString = show.attributes.poster?.url else { return nil }
		return URL(string: urlString)
	}

	// MARK: - Functions
	private func updateLibraryStatus(to status: LibraryStatus) async {
		self.isUpdatingStatus = true
		defer { isUpdatingStatus = false }

		do {
			let response = try await KService.addToLibrary(.shows, status: status, itemIDs: [self.show.id]).response()
			self.libraryStatus = response.data.attributes.status
		} catch {
			NSLog("Library status update failed: %@", error.localizedDescription)
			// Revert on failure
			self.libraryStatus = self.initialLibraryStatus
		}
	}

	private func removeFromLibrary() async {
		self.isUpdatingStatus = true
		defer { isUpdatingStatus = false }

		do {
			_ = try await KService.removeFromLibrary(.shows, itemIDs: [self.show.id]).response()
			self.libraryStatus = LibraryStatus.none
		} catch {
			NSLog("Library removal failed: %@", error.localizedDescription)
		}
	}
}
