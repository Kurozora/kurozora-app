//
//  LibraryRowView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

struct LibraryRowView: View {
	// MARK: - Properties
	let show: Show

	// MARK: - Body
	var body: some View {
		HStack(spacing: 8) {
			ArtworkView(
				media: self.show.attributes.poster,
				shape: .poster,
				targetWidth: 44
			)
			.frame(width: 44)

			VStack(alignment: .leading, spacing: 1) {
				Text(self.show.attributes.title)
					.font(.headline)
					.lineLimit(1)

				Text(self.kindAndRating)
					.lineLimit(1)

				if let lengths = self.lengths {
					Text(lengths)
						.lineLimit(1)
				}

				Text(self.show.attributes.status.name)
					.lineLimit(1)

				if let broadcastDate = self.countdownDate {
					Text(broadcastDate, style: .relative)
						.lineLimit(1)
				}
			}
			.font(.caption2)
			.foregroundStyle(.secondary)

			Spacer(minLength: 0)
		}
		.padding(.vertical, 4)
	}

	// MARK: - Computed
	private var kindAndRating: String {
		return "\(self.show.attributes.type.name) · \(self.show.attributes.tvRating.name)"
	}

	private var lengths: String? {
		let duration = self.abbreviatedDuration
		let episodeCount = self.show.attributes.episodeCount

		guard episodeCount > 0 else { return duration }
		guard let duration else { return L10n.episodeCount(episodeCount) }

		return "\(episodeCount) ep · \(duration)"
	}

	private var abbreviatedDuration: String? {
		// durationCount is seconds, so 1440 is a 24 minute episode.
		let minutes = self.show.attributes.durationCount / 60

		guard minutes > 0 else { return nil }
		guard minutes >= 60 else { return "\(minutes)m" }

		let hours = minutes / 60
		let remainder = minutes % 60

		return remainder == 0 ? "\(hours)h" : "\(hours)h \(remainder)m"
	}

	/// The next broadcast date, shown on the same terms as the iOS list cell.
	private var countdownDate: Date? {
		guard self.show.attributes.status.name == "Currently Airing",
			  self.show.attributes.durationCount > 0
		else { return nil }

		return self.show.attributes.nextBroadcastAt
	}
}
