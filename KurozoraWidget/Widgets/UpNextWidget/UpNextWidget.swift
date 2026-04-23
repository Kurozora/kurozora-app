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
	/// The server could not be reached and no cached entries are available to render.
	case unavailable
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
	let imageURL: URL?
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
			imageURL: nil,
			backgroundColor: nil,
			deeplinkURL: .home,
			isFiller: true
		)
	}

	/// Creates an array of placeholder items with unique IDs.
	static func placeholders(count: Int) -> [UpNextEpisodeItem] {
		return (0 ..< count).map { _ in .placeholder }
	}

	/// Image-less placeholder.
	static var emptyBannerPlaceholder: UpNextEpisodeItem {
		return UpNextEpisodeItem(
			id: UUID().uuidString,
			title: "",
			showTitle: "",
			seasonNumber: 0,
			episodeNumber: 0,
			episodeNumberTotal: 0,
			bannerImage: nil,
			imageURL: nil,
			backgroundColor: nil,
			deeplinkURL: .home,
			isFiller: true
		)
	}
}

// MARK: - Timeline Entry
struct UpNextEntry: TimelineEntry {
	let date: Date
	let episodes: [UpNextEpisodeItem]
	let state: UpNextWidgetState
	let isPlaceholder: Bool
}

// MARK: - Fetch Result
/// Wraps a widget entry with the interval after which the next reload should fire.
private struct UpNextFetchResult {
	let entry: UpNextEntry
	let nextReloadAfter: TimeInterval
}

// MARK: - Timeline Provider
struct UpNextProvider: TimelineProvider {
	// MARK: - Properties
	/// Overall deadline for the fan-out batch of episode detail + image calls.
	private static let fetchEpisodeDetailsDeadline: TimeInterval = 10

	// MARK: - TimelineProvider
	func placeholder(in context: Context) -> UpNextEntry {
		if let snapshots = UpNextWidgetCache.loadLastGoodSnapshot() {
			let episodes = snapshots.compactMap { $0.rehydrate() }
			if !episodes.isEmpty {
				return UpNextEntry(
					date: Date(),
					episodes: episodes,
					state: .authenticated,
					isPlaceholder: false
				)
			}
		}

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
			let result = await self.fetchEntry(for: context)
			completion(result.entry)
		}
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<UpNextEntry>) -> Void) {
		Task {
			let result = await self.fetchEntry(for: context)
			let nextUpdate = Date().addingTimeInterval(result.nextReloadAfter)
			completion(Timeline(entries: [result.entry], policy: .after(nextUpdate)))
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
	///
	/// - Parameter context: The widget context, used to determine how many episodes to fetch.
	///
	/// - Returns: An `UpNextFetchResult` containing the entry to display and the recommended reload interval.
	private func fetchEntry(for context: Context) async -> UpNextFetchResult {
		let limit = self.episodeLimit(for: context)

		guard self.restoreAuthentication() else {
			return await self.fetchUnauthenticatedResult(limit: limit)
		}

		do {
			let identityResponse = try await KService.upNextEpisodes().limit(limit).response()
			let identities = Array(identityResponse.data.prefix(limit))

			guard !identities.isEmpty else {
				UpNextWidgetCache.recordUpNextSuccess([])
				return UpNextFetchResult(
					entry: UpNextEntry(date: Date(), episodes: [], state: .empty, isPlaceholder: false),
					nextReloadAfter: 60 * 60
				)
			}

			let episodes = await self.fetchEpisodeDetails(for: identities, family: context.family, displaySize: context.displaySize)

			// Persist a snapshot so future failures can re-hydrate without network calls.
			UpNextWidgetCache.recordUpNextSuccess(episodes.map { $0.asSnapshot })

			return UpNextFetchResult(
				entry: UpNextEntry(date: Date(), episodes: episodes, state: .authenticated, isPlaceholder: false),
				nextReloadAfter: 60 * 60
			)
		} catch {
			let failures = UpNextWidgetCache.recordUpNextFailure()
			return UpNextFetchResult(
				entry: self.recoveryEntry(limit: limit),
				nextReloadAfter: UpNextWidgetCache.backoffInterval(forFailures: failures)
			)
		}
	}

	/// Parallel-fetches episode details + banner images, bounded by a hard deadline.
	///
	/// Children run concurrently in a task group so total wall time is the slowest single request, not the sum.
	/// ``Self/fetchEpisodeDetailsDeadline`` caps the group; on timeout, whatever finished in time is returned in original order.
	///
	/// - Parameters:
	///    - identities: The list of episode identities to fetch details for.
	///    - family: The widget family, used to determine appropriate image sizes.
	///    - displaySize: The widget display size, used to determine appropriate image sizes.
	///
	/// - Returns: A list of fully-populated episode items ready for display, in the same order as the input identities. Episodes that failed to fetch within the deadline are omitted.
	private func fetchEpisodeDetails(for identities: [EpisodeIdentity], family: WidgetFamily, displaySize: CGSize) async -> [UpNextEpisodeItem] {
		let indexed: [(Int, UpNextEpisodeItem)]

		do {
			indexed = try await withTimeout(seconds: Self.fetchEpisodeDetailsDeadline) { [self] in
				await withTaskGroup(of: (Int, UpNextEpisodeItem)?.self) { group in
					for (index, identity) in identities.enumerated() {
						group.addTask {
							await self.fetchSingleEpisode(identity: identity, index: index, family: family, displaySize: displaySize)
						}
					}

					var results: [(Int, UpNextEpisodeItem)] = []
					for await case let result? in group {
						results.append(result)
					}
					return results
				}
			}
		} catch {
			return []
		}

		return indexed.sorted { $0.0 < $1.0 }.map { $0.1 }
	}

	/// Fetches details + banner image for a single episode. Returns `nil` on any failure.
	private func fetchSingleEpisode(identity: EpisodeIdentity, index: Int, family: WidgetFamily, displaySize: CGSize) async -> (Int, UpNextEpisodeItem)? {
		guard let episode = try? await KService.detail(identity, including: [.shows]).response().data.first else {
			return nil
		}

		let attributes = episode.attributes
		let targetWidth = self.imageTargetWidth(forIndex: index, family: family, displaySize: displaySize)

		let imageURL = URL(string: attributes.banner?.url ?? attributes.poster?.url ?? "")
		let imageData = try? await ImageFetcher.shared.fetchImageData(from: imageURL)
		let downsampledImage = imageData.flatMap { UIImage.downsample(data: $0, toWidth: targetWidth) }

		let episodeIdentity = EpisodeIdentity(id: episode.id)

		let item = UpNextEpisodeItem(
			id: episode.id.description,
			title: attributes.title,
			showTitle: attributes.showTitle,
			seasonNumber: attributes.seasonNumber,
			episodeNumber: attributes.number,
			episodeNumberTotal: attributes.numberTotal,
			bannerImage: downsampledImage,
			imageURL: imageURL,
			backgroundColor: attributes.banner?.backgroundColor ?? attributes.poster?.backgroundColor,
			deeplinkURL: .episode(episodeIdentity)
		)
		return (index, item)
	}

	/// Builds a recovery entry from the last successfully persisted snapshot.
	///
	/// Image bytes are re-hydrated from ``ImageFetcher``'s on-disk cache (1-day TTL).
	///
	/// - Parameter limit: The number of episodes to include in the recovery entry, based on the widget family.
	///
	/// - Returns: An `UpNextEntry` built from the last good snapshot, or a fallback unavailable entry if no snapshots or no re-hydratable snapshots are available.
	private func recoveryEntry(limit: Int) -> UpNextEntry {
		if let snapshots = UpNextWidgetCache.loadLastGoodSnapshot() {
			let episodes = snapshots.compactMap { $0.rehydrate() }
			if !episodes.isEmpty {
				return UpNextEntry(date: Date(), episodes: episodes, state: .authenticated, isPlaceholder: false)
			}
		}

		return UpNextEntry(
			date: Date(),
			episodes: UpNextEpisodeItem.placeholders(count: limit),
			state: .unavailable,
			isPlaceholder: false
		)
	}

	/// Returns the appropriate image target width for a given episode position and widget family.
	///
	/// - Parameters:
	///    - index: The position of the episode in the list (0-based).
	///    - family: The widget family, which determines the overall layout and image prominence.
	///    - displaySize: The actual display size of the widget, used to calculate dynamic widths for certain families.
	///
	/// - Returns: The target width in points for the episode's banner image.
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
	///
	/// On failure, backs off using the same exponential schedule as the authenticated path.
	///
	/// - Parameter limit: The number of episodes to include in the fallback entry, based on the widget family.
	///
	/// - Returns: An `UpNextFetchResult` containing the fallback entry and the recommended reload interval.
	private func fetchUnauthenticatedResult(limit: Int) async -> UpNextFetchResult {
		guard let mediaResponse = try? await KService.randomImages(of: .shows, from: .banner).limit(limit).response() else {
			let failures = UpNextWidgetCache.recordUpNextFailure()
			return UpNextFetchResult(
				entry: UpNextEntry(date: Date(), episodes: [.placeholder], state: .unauthenticated, isPlaceholder: false),
				nextReloadAfter: UpNextWidgetCache.backoffInterval(forFailures: failures)
			)
		}

		var items: [UpNextEpisodeItem] = []
		for media in mediaResponse.data.prefix(limit) {
			let mediaURL = URL(string: media.url)
			let imageData = try? await ImageFetcher.shared.fetchImageData(from: mediaURL)
			let image = imageData.flatMap { UIImage.downsample(data: $0, toWidth: 200) }
			items.append(UpNextEpisodeItem(
				id: UUID().uuidString,
				title: "",
				showTitle: "",
				seasonNumber: 0,
				episodeNumber: 0,
				episodeNumberTotal: 0,
				bannerImage: image,
				imageURL: mediaURL,
				backgroundColor: media.backgroundColor,
				deeplinkURL: .home
			))
		}

		UpNextWidgetCache.recordUpNextSuccess([])

		return UpNextFetchResult(
			entry: UpNextEntry(
				date: Date(),
				episodes: items.isEmpty ? [.placeholder] : items,
				state: .unauthenticated,
				isPlaceholder: false
			),
			nextReloadAfter: 60 * 60
		)
	}
}

// MARK: - Snapshot Bridging
private extension UpNextEpisodeItem {
	/// Builds a persistable snapshot that preserves everything except the decoded image bytes.
	///
	/// The image URL is saved so the recovery path can re-hydrate from ``ImageFetcher``'s on-disk cache.
	var asSnapshot: UpNextEpisodeSnapshot {
		return UpNextEpisodeSnapshot(
			id: self.id,
			title: self.title,
			showTitle: self.showTitle,
			seasonNumber: self.seasonNumber,
			episodeNumber: self.episodeNumber,
			episodeNumberTotal: self.episodeNumberTotal,
			imageURL: self.imageURL,
			backgroundColor: self.backgroundColor,
			deeplinkURLString: self.deeplinkURL.absoluteString,
			isFiller: self.isFiller
		)
	}
}

private extension UpNextEpisodeSnapshot {
	/// Default re-hydration width. Widget may be any size; keep memory modest and re-downsample on next success.
	static let rehydrationWidth: CGFloat = 400

	/// Re-hydrates a snapshot back into a displayable item, loading the image from the on-disk cache if present.
	///
	/// Returns `nil` if the snapshot is invalid or the deeplink URL is malformed, otherwise returns an `UpNextEpisodeItem` object with the image reloaded from cache if possible.
	func rehydrate() -> UpNextEpisodeItem? {
		guard let deeplinkURL = URL(string: self.deeplinkURLString) else { return nil }

		let image: UIImage? = self.imageURL
			.flatMap { ImageFetcher.shared.cachedImage(for: $0) }
			.flatMap { UIImage.downsample(data: $0, toWidth: Self.rehydrationWidth) }

		return UpNextEpisodeItem(
			id: self.id,
			title: self.title,
			showTitle: self.showTitle,
			seasonNumber: self.seasonNumber,
			episodeNumber: self.episodeNumber,
			episodeNumberTotal: self.episodeNumberTotal,
			bannerImage: image,
			imageURL: self.imageURL,
			backgroundColor: self.backgroundColor,
			deeplinkURL: deeplinkURL,
			isFiller: self.isFiller
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
