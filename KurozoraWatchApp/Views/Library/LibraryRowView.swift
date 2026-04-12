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
			CachedAsyncImage(url: self.posterURL) {
				RoundedRectangle(cornerRadius: 4)
					.fill(Color.gray.opacity(0.3))
			}
			.frame(width: 36, height: 52)
			.clipShape(RoundedRectangle(cornerRadius: 4))

			VStack(alignment: .leading, spacing: 2) {
				Text(self.show.attributes.title)
					.font(.caption)
					.lineLimit(2)

				HStack(spacing: 4) {
					if self.show.attributes.episodeCount > 0 {
						Text("\(self.show.attributes.episodeCount) ep")
							.font(.caption2)
							.foregroundStyle(.secondary)
					}

					Text(self.show.attributes.status.name)
						.font(.caption2)
						.foregroundStyle(self.airingStatusColor)
				}
			}
		}
	}

	// MARK: - Computed
	private var posterURL: URL? {
		guard let urlString = show.attributes.poster?.url else { return nil }
		return URL(string: urlString)
	}

	private var airingStatusColor: Color {
		switch self.show.attributes.status.color.lowercased() {
		case let hex where hex.contains("green"):
			return .green
		case let hex where hex.contains("blue"):
			return .blue
		default:
			return .secondary
		}
	}
}
