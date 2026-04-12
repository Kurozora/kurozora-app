//
//  ExploreSectionView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct ExploreSectionView: View {
	// MARK: - Properties
	let category: ExploreCategory

	/// `nil` = skeleton state, empty array = loaded but empty, populated = real data.
	let shows: [Show]?

	private var isBanner: Bool {
		self.category.attributes.exploreCategorySize == .banner
	}

	// MARK: - Body
	var body: some View {
		if let shows = self.shows, shows.isEmpty {
			// Loaded but empty — hide the section entirely
			EmptyView()
		} else {
			Section {
				if let shows = self.shows {
					ForEach(shows, id: \.id) { show in
						NavigationLink(destination: ShowDetailView(show: show)) {
							self.showRow(title: show.attributes.title, posterURL: self.posterURL(for: show))
						}
					}
				} else {
					// Skeleton rows — use identity count to show the right number of placeholders
					let skeletonCount = max(1, min(self.category.relationships.shows?.data.count ?? 3, 10))
					ForEach(0..<skeletonCount, id: \.self) { _ in
						self.showRow(title: "Placeholder Title", posterURL: nil)
							.redacted(reason: .placeholder)
					}
				}
			} header: {
				if !self.isBanner {
					Text(self.category.attributes.title)
						.font(.caption.bold())
						.textCase(nil)
				}
			}
		}
	}

	// MARK: - Functions
	private func showRow(title: String, posterURL: URL?) -> some View {
		HStack(spacing: 8) {
			CachedAsyncImage(url: posterURL) {
				RoundedRectangle(cornerRadius: 4)
					.fill(Color.gray.opacity(0.3))
			}
			.frame(width: 32, height: 46)
			.clipShape(RoundedRectangle(cornerRadius: 4))

			Text(title)
				.font(.caption)
				.lineLimit(2)
		}
	}

	private func posterURL(for show: Show) -> URL? {
		guard let urlString = show.attributes.poster?.url else { return nil }
		return URL(string: urlString)
	}
}
