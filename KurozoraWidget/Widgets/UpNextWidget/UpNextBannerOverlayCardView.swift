//
//  UpNextBannerOverlayCardView.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 12/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

struct UpNextBannerOverlayCardView: View {
	let episode: UpNextEpisodeItem
	let isCompact: Bool
	var usesFadeMask: Bool = false
	var hidesContent: Bool = false

	var body: some View {
		Color.clear
			.overlay {
				if self.usesFadeMask {
					self.backgroundImage
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
					self.backgroundImage
				}
			}
			.overlay {
				if !self.usesFadeMask {
					LinearGradient(
						colors: [.clear, .black.opacity(0.7)],
						startPoint: .center,
						endPoint: .bottom
					)
				}
			}
			.overlay(alignment: .bottomLeading) {
				if !self.hidesContent {
					HStack(alignment: .bottom) {
						VStack(alignment: .leading, spacing: 2) {
							Text(self.episode.showTitle)
								.font(.caption2)
								.fontWeight(.medium)
								.foregroundStyle(.white.opacity(0.8))
								.lineLimit(1)

							Text(self.episode.title)
								.font(self.isCompact ? .footnote : .subheadline)
								.fontWeight(.bold)
								.foregroundStyle(.white)
								.lineLimit(1)

							Text(self.episode.seasonEpisodeLabel)
								.font(.caption2)
								.fontWeight(.semibold)
								.foregroundStyle(.white.opacity(0.7))
								.padding(.horizontal, 6)
								.padding(.vertical, 2)
								.modifier(AdaptiveCapsuleBackground())
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.trailing, 8)

						if #available(iOS 17.0, macOS 14.0, *) {
							UpNextCheckmarkButton(episodeID: self.episode.id, font: self.isCompact ? .body : .title3)
						}
					}
					.padding(.horizontal, 16)
					.padding(.vertical, 12)
				}
			}
			.clipped()
	}

	private var backgroundImage: some View {
		UpNextBannerImage(image: self.episode.bannerImage, backgroundColorHex: self.episode.backgroundColor)
	}
}
