//
//  UpNextBannerCardView.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 12/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

struct UpNextBannerCardView: View {
	@Environment(\.widgetFamily) var widgetFamily

	let episode: UpNextEpisodeItem
	var bannerCornerRadius: CGFloat = 0
	var bannerHeight: CGFloat?
	var usesFadeMask: Bool = false
	var hidesContent: Bool = false

	var contentPadding: CGFloat {
		switch self.widgetFamily {
		case .systemSmall:
			return 12
		default: return 0
		}
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Group {
				if let bannerHeight = self.bannerHeight {
					Color.clear
						.frame(height: bannerHeight)
				} else {
					Color.clear
						.aspectRatio(16.0 / 9.0, contentMode: .fit)
				}
			}
			.overlay {
				if self.usesFadeMask {
					self.bannerImage
						.mask(
							LinearGradient(
								stops: [
									.init(color: .white, location: 0.0),
									.init(color: .white, location: 0.4),
									.init(color: .clear, location: 0.95)
								],
								startPoint: .top,
								endPoint: .bottom
							)
						)
				} else {
					self.bannerImage
				}
			}
			.overlay(alignment: .bottomLeading) {
				if self.widgetFamily == .systemMedium && !self.hidesContent {
					Text(self.episode.seasonEpisodeLabel)
						.font(.caption2)
						.fontWeight(.medium)
						.foregroundStyle(.white.opacity(0.7))
						.padding(.horizontal, 6)
						.padding(.vertical, 2)
						.modifier(AdaptiveCapsuleBackground())
						.padding(.horizontal, 4)
						.padding(.bottom, 4)
				}
			}
			.clipped()
			.clipShape(RoundedRectangle(cornerRadius: self.bannerCornerRadius, style: .continuous))
			.layoutPriority(1)

			if !self.hidesContent {
				HStack(alignment: .center) {
					VStack(alignment: .leading, spacing: 2) {
						Text(self.episode.showTitle)
							.font(.caption2)
							.fontWeight(.medium)
							.foregroundStyle(.secondary)
							.lineLimit(1)

						Text(self.episode.title)
							.font(.footnote)
							.fontWeight(.bold)
							.foregroundStyle(.primary)
							.lineLimit(1)

						if self.widgetFamily == .systemSmall {
							Text(self.episode.seasonEpisodeLabel)
								.font(.caption2)
								.foregroundStyle(.tertiary)
								.lineLimit(1)
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.trailing, 8)

					if #available(iOS 17.0, macOS 14.0, *) {
						UpNextCheckmarkButton(episodeID: self.episode.id)
					}
				}
				.padding(.horizontal, self.contentPadding)
				.padding(.top, 6)
				.padding(.bottom, 12)
			}
		}
	}

	private var bannerImage: some View {
		UpNextBannerImage(image: self.episode.bannerImage, backgroundColorHex: self.episode.backgroundColor)
	}
}
