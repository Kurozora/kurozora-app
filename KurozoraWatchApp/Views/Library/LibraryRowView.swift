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
	let item: LibraryItem

	@Environment(WatchTheme.self) private var theme

	// MARK: - Body
	var body: some View {
		HStack(spacing: 8) {
			ArtworkView(
				url: self.item.posterURL,
				backgroundColor: self.item.posterBackgroundColor,
				shape: self.item.kind.artworkShape,
				targetWidth: 44
			)
			.frame(width: 44)

			VStack(alignment: .leading, spacing: 1) {
				Text(self.item.title)
					.font(.headline)
					.lineLimit(1)

				if let information = self.information {
					Text(information)
						.lineLimit(1)
				}

				if let duration = self.abbreviatedDuration {
					Text(duration)
						.lineLimit(1)
				}

				if let statusName = self.item.statusName {
					Text(statusName)
						.lineLimit(1)
				}

				if let broadcastDate = self.countdownDate {
					Text(broadcastDate, style: .relative)
						.lineLimit(1)
				}

				if self.item.isFavorited || self.item.isReminded {
					HStack(spacing: 6) {
						if self.item.isFavorited {
							Image(systemName: "heart.fill")
								.accessibilityLabel(L10n.favorite)
						}

						if self.item.isReminded {
							Image(systemName: "bell.fill")
								.accessibilityLabel(L10n.reminder)
						}
					}
					.foregroundStyle(self.theme.tint)
				}
			}
			.font(.caption2)
			.foregroundStyle(.secondary)

			Spacer(minLength: 0)
		}
		.padding(.vertical, 4)
	}

	// MARK: - Computed
	/// The media type and the user's score, on the same terms as the iOS cells' short information line.
	private var information: String? {
		var parts: [String] = []

		if let mediaTypeName = self.item.mediaTypeName, !mediaTypeName.isEmpty {
			parts.append(mediaTypeName)
		}

		if let score = self.item.userScore, score > 0 {
			parts.append("☆ \(score)")
		}

		return parts.isEmpty ? nil : parts.joined(separator: " · ")
	}

	private var abbreviatedDuration: String? {
		// durationCount is seconds, so 1440 is a 24 minute episode.
		let minutes = self.item.durationCount / 60

		guard minutes > 0 else { return nil }
		guard minutes >= 60 else { return "\(minutes)m" }

		let hours = minutes / 60
		let remainder = minutes % 60

		return remainder == 0 ? "\(hours)h" : "\(hours)h \(remainder)m"
	}

	/// The next broadcast or publication date, shown on the same terms as the iOS list cell.
	private var countdownDate: Date? {
		guard self.item.kind.countdownStatusNames.contains(self.item.statusName ?? ""), self.item.durationCount > 0 else { return nil }

		return self.item.airingDate
	}
}
