//
//  UpNextWidgetEntryView.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 11/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI
import WidgetKit

struct UpNextWidgetEntryView: View {
	@Environment(\.widgetFamily) var widgetFamily

	let entry: UpNextEntry

	var body: some View {
		switch self.entry.state {
		case .authenticated:
			self.authenticatedView
		case .unauthenticated:
			self.unauthenticatedView
		case .empty:
			self.emptyView
		}
	}

	// MARK: - Authenticated Views
	@ViewBuilder
	private var authenticatedView: some View {
		switch self.widgetFamily {
		case .systemSmall:
			self.smallView
		case .systemMedium:
			self.mediumView
		case .systemLarge:
			self.largeView
		case .systemExtraLarge:
			self.extraLargeView
		default:
			self.mediumView
		}
	}

	// MARK: - Helpers
	/// Pads the entry's episodes to the expected count with filler placeholders.
	///
	/// - Parameters count: The number of episodes to pad to.
	///
	/// - Returns: An array of episodes with real episodes first, followed by filler placeholders if needed.
	private func paddedEpisodes(count: Int) -> [UpNextEpisodeItem] {
		var episodes = Array(self.entry.episodes.prefix(count))
		while episodes.count < count {
			episodes.append(.placeholder)
		}
		return episodes
	}

	// MARK: Small
	@ViewBuilder
	private var smallView: some View {
		if let episode = self.entry.episodes.first {
			UpNextBannerCardView(episode: episode, usesFadeMask: true)
				.widgetURL(episode.deeplinkURL)
		}
	}

	// MARK: Medium
	@ViewBuilder
	private var mediumView: some View {
		let episodes = self.paddedEpisodes(count: 2)

		GeometryReader { geometry in
			let cardWidth = (geometry.size.width - 32 - 12) / 2
			let bannerHeight = cardWidth * 9.0 / 16.0

			HStack(spacing: 12) {
				ForEach(episodes) { episode in
					Link(destination: episode.deeplinkURL) {
						UpNextBannerCardView(
							episode: episode,
							bannerCornerRadius: 8,
							bannerHeight: bannerHeight
						)
					}
					.frame(width: cardWidth)
					.disabled(episode.isFiller)
					.redacted(reason: episode.isFiller ? .placeholder : [])
				}
			}
			.padding(16)
		}
	}

	// MARK: Large
	@ViewBuilder
	private var largeView: some View {
		let episodes = self.paddedEpisodes(count: 3)
		let hero = episodes[0]
		let rows = Array(episodes.dropFirst())

		GeometryReader { geometry in
			let inset: CGFloat = 16
			let rowSpacing: CGFloat = 8
			let heroHeight = geometry.size.width * 9.0 / 16.0
			let rowContainerWidth = geometry.size.width - inset * 2
			let slotHeight = (geometry.size.height - heroHeight - inset * 2 - rowSpacing) / 2
			let bannerWidth = slotHeight * 16.0 / 9.0

			VStack(spacing: 0) {
				Link(destination: hero.deeplinkURL) {
					UpNextBannerOverlayCardView(episode: hero, isCompact: false, usesFadeMask: true)
				}
				.frame(height: heroHeight)
				.clipped()
				.disabled(hero.isFiller)
				.redacted(reason: hero.isFiller ? .placeholder : [])

				VStack(spacing: rowSpacing) {
					ForEach(Array(rows.enumerated()), id: \.element.id) { index, episode in
						Link(destination: episode.deeplinkURL) {
							UpNextBannerRowView(episode: episode, containerWidth: rowContainerWidth, bannerWidth: bannerWidth)
						}
						.frame(height: slotHeight, alignment: .top)
						.overlay(alignment: .bottom) {
							if index < rows.count - 1 {
								Divider()
									.padding(.leading, bannerWidth + 10)
									.offset(y: rowSpacing / 2)
							}
						}
						.disabled(episode.isFiller)
						.redacted(reason: episode.isFiller ? .placeholder : [])
					}
				}
				.padding(inset)
			}
		}
	}

	// MARK: Extra Large
	@ViewBuilder
	private var extraLargeView: some View {
		let episodes = self.paddedEpisodes(count: 7)
		let hero = episodes[0]
		let leftRows = Array(episodes[1...2])
		let rightRows = Array(episodes[3...6])

		GeometryReader { geometry in
			let inset: CGFloat = 16
			let spacing: CGFloat = 14
			let contentWidth = geometry.size.width - inset * 2
			let contentHeight = geometry.size.height - inset * 2
			let halfWidth = (contentWidth - spacing) / 2
			let cardHeight = (contentHeight - spacing * 3) / 4
			let heroHeight = cardHeight * 2 + spacing

			HStack(alignment: .top, spacing: spacing) {
				VStack(spacing: spacing) {
					Link(destination: hero.deeplinkURL) {
						UpNextBannerOverlayCardView(episode: hero, isCompact: false, usesFadeMask: true)
							.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
					}
					.frame(height: heroHeight)
					.clipped()
					.disabled(hero.isFiller)
					.redacted(reason: hero.isFiller ? .placeholder : [])

					ForEach(leftRows) { episode in
						self.rowCard(episode: episode, width: halfWidth, height: cardHeight)
					}
				}
				.frame(width: halfWidth)

				VStack(spacing: spacing) {
					ForEach(rightRows) { episode in
						self.rowCard(episode: episode, width: halfWidth, height: cardHeight)
					}
				}
				.frame(width: halfWidth)
			}
			.padding(inset)
		}
	}

	@ViewBuilder
	private func rowCard(episode: UpNextEpisodeItem, width: CGFloat, height: CGFloat) -> some View {
		let bannerWidth = height * 16.0 / 9.0

		Link(destination: episode.deeplinkURL) {
			UpNextBannerRowView(episode: episode, containerWidth: width, bannerWidth: bannerWidth)
		}
		.frame(width: width, height: height, alignment: .leading)
		.disabled(episode.isFiller)
		.redacted(reason: episode.isFiller ? .placeholder : [])
	}

	// MARK: - Shared Row List
	@ViewBuilder
	private func rowList(_ episodes: [UpNextEpisodeItem], containerWidth: CGFloat) -> some View {
		VStack(spacing: 0) {
			ForEach(Array(episodes.enumerated()), id: \.element.id) { index, episode in
				if index > 0 {
					Divider()
				}

				Link(destination: episode.deeplinkURL) {
					UpNextBannerRowView(episode: episode, containerWidth: containerWidth)
				}
				.disabled(episode.isFiller)
				.redacted(reason: episode.isFiller ? .placeholder : [])
			}
		}
	}

	// MARK: - Unauthenticated View
	private var unauthenticatedView: some View {
		ZStack {
			let uiImage = self.entry.episodes.first?.bannerImage ?? UIImage(named: "starry_sky")

			if let uiImage = uiImage {
				Image(uiImage: uiImage)
					.resizable()
					.scaledToFill()
					.clipped()
					.overlay {
						Color.black.opacity(0.5)
					}
			}

			VStack(spacing: 8) {
				Image(systemName: "play.rectangle.on.rectangle")
					.font(.largeTitle)
					.foregroundStyle(.white)

				Text("Sign in to see your Up Next episodes")
					.font(.caption)
					.foregroundStyle(.white.opacity(0.9))
					.multilineTextAlignment(.center)
					.padding(.horizontal)
			}
		}
		.widgetURL(.home)
	}

	// MARK: - Empty View
	private var emptyView: some View {
		VStack(spacing: 8) {
			Image(systemName: "checkmark.seal.fill")
				.font(.largeTitle)
				.foregroundStyle(.secondary)

			Text("You're all caught up!")
				.font(.headline)
				.foregroundStyle(.primary)

			Text("Mark more episodes in your library")
				.font(.caption2)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.widgetURL(.library)
	}
}

// MARK: - Previews
#if DEBUG
@available(iOS 17.0, macOS 14.0, *)
#Preview("System Small", as: .systemSmall) {
	UpNextWidget()
} timeline: {
	UpNextEntry(
		date: Date(),
		episodes: [.placeholder],
		state: .authenticated,
		isPlaceholder: false
	)
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("System Medium", as: .systemMedium) {
	UpNextWidget()
} timeline: {
	UpNextEntry(
		date: Date(),
		episodes: UpNextEpisodeItem.placeholders(count: 2),
		state: .authenticated,
		isPlaceholder: false
	)
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("System Large", as: .systemLarge) {
	UpNextWidget()
} timeline: {
	UpNextEntry(
		date: Date(),
		episodes: UpNextEpisodeItem.placeholders(count: 3),
		state: .authenticated,
		isPlaceholder: false
	)
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("System Extra Large", as: .systemExtraLarge) {
	UpNextWidget()
} timeline: {
	UpNextEntry(
		date: Date(),
		episodes: UpNextEpisodeItem.placeholders(count: 7),
		state: .authenticated,
		isPlaceholder: false
	)
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Empty State", as: .systemMedium) {
	UpNextWidget()
} timeline: {
	UpNextEntry(
		date: Date(),
		episodes: [],
		state: .empty,
		isPlaceholder: false
	)
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Unauthenticated", as: .systemMedium) {
	UpNextWidget()
} timeline: {
	UpNextEntry(
		date: Date(),
		episodes: [.placeholder],
		state: .unauthenticated,
		isPlaceholder: false
	)
}
#endif
