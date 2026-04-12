//
//  UpNextBannerRowView.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 12/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

struct UpNextBannerRowView: View {
	let episode: UpNextEpisodeItem
	let containerWidth: CGFloat
	var bannerWidth: CGFloat = 110.0

	var body: some View {
		HStack(spacing: 10) {
			Color.clear
				.aspectRatio(16.0 / 9.0, contentMode: .fit)
				.frame(width: self.bannerWidth)
				.overlay {
					self.bannerImage
				}
				.clipped()
				.clipShape(RoundedRectangle(cornerRadius: 6.0, style: .continuous))

			VStack(alignment: .leading, spacing: 2.0) {
				Text(self.episode.showTitle)
					.font(.caption2)
					.fontWeight(.medium)
					.foregroundStyle(.secondary)
					.lineLimit(1)

				Text(self.episode.title)
					.font(.footnote)
					.fontWeight(.bold)
					.foregroundStyle(.primary)
					.lineLimit(2)

				Text(self.episode.seasonEpisodeLabel)
					.font(.caption2)
					.foregroundStyle(.tertiary)
					.lineLimit(1)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.trailing, 8.0)

			if #available(iOS 17.0, macOS 14.0, *) {
				UpNextCheckmarkButton(episodeID: self.episode.id)
			}
		}
	}

	private var bannerImage: some View {
		UpNextBannerImage(image: self.episode.bannerImage, backgroundColorHex: self.episode.backgroundColor)
	}
}
