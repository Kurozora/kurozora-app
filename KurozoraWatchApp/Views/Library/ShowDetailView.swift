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

	private let statuses = LibraryStatus.all

	// MARK: - Body
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {
				// Poster
				CachedAsyncImage(url: self.posterURL) {
					RoundedRectangle(cornerRadius: 8)
						.fill(Color.gray.opacity(0.3))
				}
				.frame(height: 120)
				.frame(maxWidth: .infinity)
				.clipShape(RoundedRectangle(cornerRadius: 8))

				// Title
				Text(self.show.attributes.title)
					.font(.headline)

				// Metadata
				HStack(spacing: 6) {
					Label("\(self.show.attributes.episodeCount) ep", systemImage: "film")
					Spacer()
					Text(self.show.attributes.status.name)
						.foregroundStyle(.secondary)
				}
				.font(.caption2)

				// Genre tags
				if let genres = show.attributes.genres, !genres.isEmpty {
					Text(genres.joined(separator: " \u{2022} "))
						.font(.caption2)
						.foregroundStyle(.secondary)
				}

				// Synopsis
				if let synopsis = show.attributes.synopsis, !synopsis.isEmpty {
					Text(synopsis)
						.font(.caption2)
						.foregroundStyle(.secondary)
				}

				Divider()

				// Library status picker
				VStack(alignment: .leading, spacing: 4) {
					Text("Library Status")
						.font(.caption.bold())

					Picker("Status", selection: self.$libraryStatus) {
						Text("None").tag(LibraryStatus?.none)
						ForEach(self.statuses, id: \.rawValue) { status in
							Text(status.stringValue).tag(Optional(status))
						}
					}
					.disabled(self.isUpdatingStatus)
					.onChange(of: self.libraryStatus) { _, newValue in
						guard let newStatus = newValue else { return }
						Task { await self.updateLibraryStatus(to: newStatus) }
					}
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
}
