//
//  SearchViewModel.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import Observation

// MARK: - SearchTypeBucket
/// Per-kind storage for catalog results: identities, hydrated models, rows, and pagination state.
struct SearchTypeBucket<Identity: Identifiable & Hashable, Model: Identifiable & Hashable> {
	var identities: [Identity] = []
	var models: [Identity.ID: Model] = [:]
	var items: [LibraryItem] = []
	var nextPageCursor: PageCursor?
	var isLoadingNextPage = false
}

// MARK: - SearchViewModel
/// Runs one query against the local library at once and the catalog over the network.
@MainActor @Observable
final class SearchViewModel {
	// MARK: - Properties
	/// The text the results screen was opened with.
	let query: String

	/// The local library entries matching the query, ranked within each kind.
	private(set) var libraryMatches: [LibraryItem] = []

	/// Whether the first catalog request is in flight.
	private(set) var isSearching = false

	/// Whether anything matched, in the library or the catalog.
	var hasResults: Bool {
		return !self.libraryMatches.isEmpty || LibraryKind.allCases.contains { !self.items(for: $0).isEmpty }
	}

	private static let pageLimit = 25

	private var showsBucket = SearchTypeBucket<ShowIdentity, Show>()
	private var literaturesBucket = SearchTypeBucket<LiteratureIdentity, Literature>()
	private var gamesBucket = SearchTypeBucket<GameIdentity, Game>()
	private var activeFilters: [LibraryKind: SearchFilter] = [:]
	private var userSlug: String?
	private var entryObserver: LocalLibraryEntryObserver?
	private var isRefreshScheduled = false

	// MARK: - Initializers
	init(query: String) {
		self.query = query
	}

	// MARK: - Functions
	/// Searches the library at once and the catalog over the network.
	func search() async {
		self.userSlug = User.current?.attributes.slug
		self.observeLibraryIfNeeded()
		self.refreshLibraryMatches()

		self.isSearching = true
		defer { self.isSearching = false }

		do {
			let response = try await KService
				.search(.kurozora, types: [.shows, .literatures, .games], query: self.query)
				.limit(Self.pageLimit)
				.response()

			self.showsBucket = Self.bucket(from: response.data.shows)
			self.literaturesBucket = Self.bucket(from: response.data.literatures)
			self.gamesBucket = Self.bucket(from: response.data.games)

			await self.hydrateAll()
		} catch {
			print("Search failed:", Self.describe(error))
		}
	}

	/// Returns the catalog rows for the given kind.
	///
	/// - Parameter kind: The library kind whose results to list.
	///
	/// - Returns: The hydrated results in the order the server ranked them.
	func items(for kind: LibraryKind) -> [LibraryItem] {
		switch kind {
		case .shows:
			return self.showsBucket.items
		case .literatures:
			return self.literaturesBucket.items
		case .games:
			return self.gamesBucket.items
		}
	}

	/// Returns the server fields for a catalog row, so its detail screen opens without a fetch.
	///
	/// - Parameter item: The row's snapshot.
	///
	/// - Returns: The fields taken from the hydrated model behind the row.
	func details(for item: LibraryItem) -> LibraryEntryDetails? {
		let itemID = KurozoraItemID(item.id)

		switch item.kind {
		case .shows:
			return self.showsBucket.models[itemID].map { LibraryEntryDetails(show: $0) }
		case .literatures:
			return self.literaturesBucket.models[itemID].map { LibraryEntryDetails(literature: $0) }
		case .games:
			return self.gamesBucket.models[itemID].map { LibraryEntryDetails(game: $0) }
		}
	}

	/// Whether the server has more catalog results of the given kind.
	func hasMorePages(for kind: LibraryKind) -> Bool {
		return self.nextPageCursor(for: kind) != nil
	}

	/// Whether the next page of the given kind is being fetched.
	func isLoadingNextPage(for kind: LibraryKind) -> Bool {
		switch kind {
		case .shows:
			return self.showsBucket.isLoadingNextPage
		case .literatures:
			return self.literaturesBucket.isLoadingNextPage
		case .games:
			return self.gamesBucket.isLoadingNextPage
		}
	}

	/// Fetches the next page of the kind's catalog results.
	///
	/// - Parameter kind: The library kind to page.
	func loadNextPage(for kind: LibraryKind) async {
		guard let cursor = self.nextPageCursor(for: kind), !self.isLoadingNextPage(for: kind) else { return }

		self.setLoadingNextPage(true, for: kind)
		defer { self.setLoadingNextPage(false, for: kind) }

		do {
			let response = try await KService
				.search(.kurozora, types: [kind.searchType], query: self.query)
				.cursor(cursor)
				.limit(100)
				.response()

			self.append(response.data, for: kind)
			await self.hydrate(kind)
		} catch {
			print("Search page fetch failed:", Self.describe(error))
		}
	}

	/// Replaces the kind's catalog results with the ones matching the filter.
	///
	/// - Parameters:
	///    - filter: The filter to apply, or `nil` to clear it.
	///    - kind: The library kind to filter.
	func applyFilter(_ filter: SearchFilter?, for kind: LibraryKind) async {
		self.activeFilters[kind] = filter

		do {
			let response = try await KService
				.search(.kurozora, types: [kind.searchType], query: self.query)
				.limit(Self.pageLimit)
				.filter(filter)
				.response()

			switch kind {
			case .shows:
				self.showsBucket = Self.bucket(from: response.data.shows)
			case .literatures:
				self.literaturesBucket = Self.bucket(from: response.data.literatures)
			case .games:
				self.gamesBucket = Self.bucket(from: response.data.games)
			}

			await self.hydrate(kind)
		} catch {
			print("Filtered search failed:", Self.describe(error))
		}
	}

	// MARK: - Private
	/// Returns the server's own message for an API failure, which the bridged description hides.
	private static func describe(_ error: Error) -> String {
		guard let apiError = error as? APIError else { return error.localizedDescription }

		return "\(apiError.response?.statusCode ?? 0) \(apiError.message)"
	}

	private static func bucket<Identity, Model>(from collection: ResourceCollection<Identity>?) -> SearchTypeBucket<Identity, Model> {
		var bucket = SearchTypeBucket<Identity, Model>()
		bucket.identities = collection?.data ?? []
		bucket.nextPageCursor = collection?.nextCursor
		return bucket
	}

	private func nextPageCursor(for kind: LibraryKind) -> PageCursor? {
		switch kind {
		case .shows:
			return self.showsBucket.nextPageCursor
		case .literatures:
			return self.literaturesBucket.nextPageCursor
		case .games:
			return self.gamesBucket.nextPageCursor
		}
	}

	private func setLoadingNextPage(_ isLoading: Bool, for kind: LibraryKind) {
		switch kind {
		case .shows:
			self.showsBucket.isLoadingNextPage = isLoading
		case .literatures:
			self.literaturesBucket.isLoadingNextPage = isLoading
		case .games:
			self.gamesBucket.isLoadingNextPage = isLoading
		}
	}

	private func append(_ search: Search, for kind: LibraryKind) {
		switch kind {
		case .shows:
			guard let shows = search.shows else { return }
			let known = Set(self.showsBucket.identities.map(\.id))
			self.showsBucket.identities.append(contentsOf: shows.data.filter { !known.contains($0.id) })
			self.showsBucket.nextPageCursor = shows.nextCursor
		case .literatures:
			guard let literatures = search.literatures else { return }
			let known = Set(self.literaturesBucket.identities.map(\.id))
			self.literaturesBucket.identities.append(contentsOf: literatures.data.filter { !known.contains($0.id) })
			self.literaturesBucket.nextPageCursor = literatures.nextCursor
		case .games:
			guard let games = search.games else { return }
			let known = Set(self.gamesBucket.identities.map(\.id))
			self.gamesBucket.identities.append(contentsOf: games.data.filter { !known.contains($0.id) })
			self.gamesBucket.nextPageCursor = games.nextCursor
		}
	}

	private func hydrateAll() async {
		await withTaskGroup(of: Void.self) { group in
			for kind in LibraryKind.allCases {
				group.addTask { await self.hydrate(kind) }
			}
		}
	}

	private func hydrate(_ kind: LibraryKind) async {
		switch kind {
		case .shows:
			let unhydrated = self.showsBucket.identities.filter { self.showsBucket.models[$0.id] == nil }
			if !unhydrated.isEmpty {
				do {
					for show in try await KService.details(unhydrated).response().data {
						self.showsBucket.models[show.id] = show
					}
				} catch {
					print("Show hydration failed:", error.localizedDescription)
				}
			}
		case .literatures:
			let unhydrated = self.literaturesBucket.identities.filter { self.literaturesBucket.models[$0.id] == nil }
			if !unhydrated.isEmpty {
				do {
					for literature in try await KService.details(unhydrated).response().data {
						self.literaturesBucket.models[literature.id] = literature
					}
				} catch {
					print("Literature hydration failed:", error.localizedDescription)
				}
			}
		case .games:
			let unhydrated = self.gamesBucket.identities.filter { self.gamesBucket.models[$0.id] == nil }
			if !unhydrated.isEmpty {
				do {
					for game in try await KService.details(unhydrated).response().data {
						self.gamesBucket.models[game.id] = game
					}
				} catch {
					print("Game hydration failed:", error.localizedDescription)
				}
			}
		}

		self.rebuildItems(for: kind)
	}

	/// Rebuilds the kind's rows from its hydrated models and the current library state.
	private func rebuildItems(for kind: LibraryKind) {
		switch kind {
		case .shows:
			self.showsBucket.items = self.showsBucket.identities.compactMap { identity in
				self.showsBucket.models[identity.id].map { show in
					LibraryItem(show: show, entry: self.entry(forTrackableID: show.id.rawValue, kind: .shows))
				}
			}
		case .literatures:
			self.literaturesBucket.items = self.literaturesBucket.identities.compactMap { identity in
				self.literaturesBucket.models[identity.id].map { literature in
					LibraryItem(literature: literature, entry: self.entry(forTrackableID: literature.id.rawValue, kind: .literatures))
				}
			}
		case .games:
			self.gamesBucket.items = self.gamesBucket.identities.compactMap { identity in
				self.gamesBucket.models[identity.id].map { game in
					LibraryItem(game: game, entry: self.entry(forTrackableID: game.id.rawValue, kind: .games))
				}
			}
		}
	}

	private func entry(forTrackableID trackableID: String, kind: LibraryKind) -> LocalLibraryEntry? {
		guard let slug = self.userSlug else { return nil }

		return LibraryStore.shared.entry(forTrackableID: trackableID, userSlug: slug, kind: kind)
	}

	private func refreshLibraryMatches() {
		guard let slug = self.userSlug else {
			self.libraryMatches = []
			return
		}

		self.libraryMatches = LibraryKind.allCases.flatMap { kind in
			LibraryStore.shared.search(forUserSlug: slug, kind: kind, query: self.query).map { LibraryItem(entry: $0) }
		}
	}

	private func observeLibraryIfNeeded() {
		guard self.entryObserver == nil, let slug = self.userSlug else { return }

		self.entryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] _ in
				self?.scheduleRefresh()
			},
			onRemove: { [weak self] _ in
				self?.scheduleRefresh()
			}
		)
	}

	/// Folds the burst of per-row callbacks a single save produces into one refresh of every row.
	private func scheduleRefresh() {
		guard !self.isRefreshScheduled else { return }
		self.isRefreshScheduled = true

		Task { @MainActor [weak self] in
			guard let self else { return }

			self.isRefreshScheduled = false
			self.refreshLibraryMatches()

			for kind in LibraryKind.allCases {
				self.rebuildItems(for: kind)
			}
		}
	}
}
