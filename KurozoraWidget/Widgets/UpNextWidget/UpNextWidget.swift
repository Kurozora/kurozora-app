//
//  UpNextWidget.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 11/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AppIntents
import KurozoraKit
import SwiftUI
import WidgetKit

// MARK: - Models
/// The available list of Up Next widget states.
enum UpNextWidgetState {
	/// The user is authenticated, and has up-next episodes.
	case authenticated
	/// The user is not authenticated, so show trending fallback.
	case unauthenticated
	/// The user is authenticated, but has no pending episodes.
	case empty
}

/// A root object that stores information about an episode, such as title, show, and episode number.
struct UpNextEpisodeItem: Identifiable {
	let id: String
	let title: String
	let showTitle: String
	let seasonNumber: Int
	let episodeNumber: Int
	let episodeNumberTotal: Int
	let bannerImage: UIImage?
	let backgroundColor: String?
	let deeplinkURL: URL
	var isFiller: Bool = false

	var seasonEpisodeLabel: String {
		var label = "S\(self.seasonNumber) · E\(self.episodeNumber)"
		if self.episodeNumberTotal != self.episodeNumber {
			label += " (E\(self.episodeNumberTotal))"
		}
		return label
	}

	static var placeholder: UpNextEpisodeItem {
		let targetSize = CGSize(width: 320, height: 180)
		let scaledImage = UIImage(named: "starry_sky").flatMap { image -> UIImage? in
			let renderer = UIGraphicsImageRenderer(size: targetSize)
			return renderer.image { _ in
				image.draw(in: CGRect(origin: .zero, size: targetSize))
			}
		}
		return UpNextEpisodeItem(
			id: UUID().uuidString,
			title: "Episode Title",
			showTitle: "Show Title",
			seasonNumber: 1,
			episodeNumber: 1,
			episodeNumberTotal: 1,
			bannerImage: scaledImage,
			backgroundColor: nil,
			deeplinkURL: .home,
			isFiller: true
		)
	}

	/// Creates an array of placeholder items with unique IDs.
	static func placeholders(count: Int) -> [UpNextEpisodeItem] {
		return (0 ..< count).map { _ in .placeholder }
	}
}

// MARK: - Timeline Entry
struct UpNextEntry: TimelineEntry {
	let date: Date
	let episodes: [UpNextEpisodeItem]
	let state: UpNextWidgetState
	let isPlaceholder: Bool
}

// MARK: - Timeline Provider
struct UpNextProvider: TimelineProvider {
	func placeholder(in context: Context) -> UpNextEntry {
		return UpNextEntry(
			date: Date(),
			episodes: UpNextEpisodeItem.placeholders(count: self.episodeLimit(for: context)),
			state: .authenticated,
			isPlaceholder: true
		)
	}

	func getSnapshot(in context: Context, completion: @escaping (UpNextEntry) -> Void) {
		if context.isPreview {
			completion(self.placeholder(in: context))
			return
		}
		Task {
			let entry = await self.fetchEntry(for: context)
			completion(entry)
		}
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<UpNextEntry>) -> Void) {
		Task {
			let entry = await self.fetchEntry(for: context)
			let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
			completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
		}
	}

	// MARK: - Helpers
	/// Returns the number of episodes to fetch based on the widget size.
	private func episodeLimit(for context: Context) -> Int {
		switch context.family {
		case .systemSmall:
			return 1
		case .systemMedium:
			return 2
		case .systemLarge:
			return 3
		case .systemExtraLarge:
			return 7
		default:
			return 2
		}
	}

	/// Restores authentication from the shared keychain using the selected account.
	///
	/// - Returns: `true` if auth was restored, `false` otherwise.
	private func restoreAuthentication() -> Bool {
		#if DEBUG
			if let savedEndpoint = UserSettings.apiEndpoint {
				KService.apiEndpoint(savedEndpoint)
			}
		#endif

		let slug = UserSettings.selectedAccount
		guard !slug.isEmpty,
		      let account = AccountManager.shared.account(forSlug: slug)
		else {
			return false
		}

		KService.authenticationKey = account.authenticationToken
		return true
	}

	/// Fetches the widget entry with episode data.
	private func fetchEntry(for context: Context) async -> UpNextEntry {
		let limit = self.episodeLimit(for: context)

		guard self.restoreAuthentication() else {
			return await self.fetchUnauthenticatedEntry(limit: limit)
		}

		do {
			let identityResponse = try await KService.getUpNextEpisodes(limit: limit).value
			let identities = Array(identityResponse.data.prefix(limit))

			guard !identities.isEmpty else {
				return UpNextEntry(
					date: Date(),
					episodes: [],
					state: .empty,
					isPlaceholder: false
				)
			}

			let episodes = await self.fetchEpisodeDetails(for: identities, family: context.family, displaySize: context.displaySize)

			return UpNextEntry(
				date: Date(),
				episodes: episodes,
				state: .authenticated,
				isPlaceholder: false
			)
		} catch {
			return await self.fetchUnauthenticatedEntry(limit: limit)
		}
	}

	/// Batch-fetches full episode details and banner images sequentially to stay within memory limits.
	private func fetchEpisodeDetails(for identities: [EpisodeIdentity], family: WidgetFamily, displaySize: CGSize) async -> [UpNextEpisodeItem] {
		var items: [UpNextEpisodeItem] = []

		for (index, identity) in identities.enumerated() {
			guard let episode = try? await KService.getDetails(forEpisode: identity, including: ["shows"]).value.data.first else {
				continue
			}

			let attributes = episode.attributes
			let targetWidth = self.imageTargetWidth(forIndex: index, family: family, displaySize: displaySize)

			let imageURL = URL(string: attributes.banner?.url ?? attributes.poster?.url ?? "")
			let imageData = try? await ImageFetcher.shared.fetchImageData(from: imageURL)
			let downsampledImage = imageData.flatMap { UIImage.downsample(data: $0, toWidth: targetWidth) }

			let episodeIdentity = EpisodeIdentity(id: episode.id)

			items.append(UpNextEpisodeItem(
				id: episode.id.description,
				title: attributes.title,
				showTitle: attributes.showTitle,
				seasonNumber: attributes.seasonNumber,
				episodeNumber: attributes.number,
				episodeNumberTotal: attributes.numberTotal,
				bannerImage: downsampledImage,
				backgroundColor: attributes.banner?.backgroundColor ?? attributes.poster?.backgroundColor,
				deeplinkURL: .episode(episodeIdentity)
			))
		}

		return items
	}

	/// Returns the appropriate image target width for a given episode position and widget family.
	private func imageTargetWidth(forIndex index: Int, family: WidgetFamily, displaySize: CGSize) -> CGFloat {
		let displayWidth = displaySize.width

		switch family {
		case .systemSmall:
			return displayWidth
		case .systemMedium:
			// Two cards side-by-side
			return (displayWidth - 40) / 2 // 32pt outer padding + 8pt spacing
		case .systemLarge:
			// Hero fills full width
			if index == 0 { return displayWidth }
			let heroHeight = displayWidth * 9.0 / 16.0
			let slotHeight = (displaySize.height - heroHeight - 32 - 8) / 2 // 32 = inset * 2, 8 = rowSpacing
			return slotHeight * 16.0 / 9.0
		case .systemExtraLarge:
			// Hero is around half the widget
			return index == 0 ? displayWidth / 2 : (displayWidth - 64) / 6
		default:
			return (displayWidth - 40) / 2
		}
	}

	/// Fetches a fallback entry with trending images for unauthenticated users.
	private func fetchUnauthenticatedEntry(limit: Int) async -> UpNextEntry {
		guard let mediaResponse = try? await KService.getRandomImages(of: .shows, from: .banner, limit: limit).value else {
			return UpNextEntry(
				date: Date(),
				episodes: [.placeholder],
				state: .unauthenticated,
				isPlaceholder: false
			)
		}

		var items: [UpNextEpisodeItem] = []
		for media in mediaResponse.data.prefix(limit) {
			let imageData = try? await ImageFetcher.shared.fetchImageData(from: URL(string: media.url))
			let image = imageData.flatMap { UIImage.downsample(data: $0, toWidth: 200) }
			items.append(UpNextEpisodeItem(
				id: UUID().uuidString,
				title: "",
				showTitle: "",
				seasonNumber: 0,
				episodeNumber: 0,
				episodeNumberTotal: 0,
				bannerImage: image,
				backgroundColor: media.backgroundColor,
				deeplinkURL: .home
			))
		}

		return UpNextEntry(
			date: Date(),
			episodes: items.isEmpty ? [.placeholder] : items,
			state: .unauthenticated,
			isPlaceholder: false
		)
	}
}

// MARK: - Widget Definition
struct UpNextWidget: Widget {
	static let kind: String = "app.kurozora.tracker.upNextWidget"

	var body: some WidgetConfiguration {
		StaticConfiguration(
			kind: Self.kind,
			provider: UpNextProvider()
		) { entry in
			if #available(iOS 17.0, tvOS 17.0, macOS 14.0, watchOS 10.0, *) {
				UpNextWidgetEntryView(entry: entry)
					.containerBackground(.fill.tertiary, for: .widget)
			} else {
				UpNextWidgetEntryView(entry: entry)
					.background()
			}
		}
		.configurationDisplayName("Up Next")
		.description("Keep up with your upcoming episodes.")
		.supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
		.contentMarginsDisabled()
	}
}
