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
/// Per-type storage for search results including identities, hydrated models, and pagination state.
struct SearchTypeBucket<Identity: Identifiable & Hashable, Model: Identifiable & Hashable> {
	var identities: [Identity] = []
	var models: [Identity.ID: Model] = [:]
	var nextPageCursor: PageCursor?
	var loadState: LoadState = .idle
	var isLoadingNextPage = false
}

// MARK: - SearchViewModel
@MainActor @Observable
final class SearchViewModel {
	// MARK: - Properties
	/// The live text in the search field.
	var searchText: String = ""

	/// The search scope (catalog vs library).
	var scope: SearchScope = .kurozora

	/// The committed query that was last submitted.
	var activeSearchText: String = ""

	/// Whether a search has been submitted and results are expected.
	var hasSearched = false

	// MARK: Suggestions / Browse
	var suggestions: [String] = []
	var suggestionsLoadState: LoadState = .idle

	/// Hardcoded browse categories for the pre-search state.
	let browseCategories: [(label: String, systemImage: String)] = [
		("Anime", "tv"),
		("Manga", "book"),
		("Games", "gamecontroller"),
		("Songs", "music.note"),
		("Episodes", "play.rectangle"),
		("Characters", "person.text.rectangle"),
		("People", "person"),
		("Studios", "building.2")
	]

	// MARK: Typed Buckets
	var showsBucket = SearchTypeBucket<ShowIdentity, Show>()
	var literaturesBucket = SearchTypeBucket<LiteratureIdentity, Literature>()
	var gamesBucket = SearchTypeBucket<GameIdentity, Game>()
	var episodesBucket = SearchTypeBucket<EpisodeIdentity, Episode>()
	var charactersBucket = SearchTypeBucket<CharacterIdentity, Character>()
	var peopleBucket = SearchTypeBucket<PersonIdentity, Person>()
	var songsBucket = SearchTypeBucket<SongIdentity, Song>()
	var studiosBucket = SearchTypeBucket<StudioIdentity, Studio>()
	var usersBucket = SearchTypeBucket<UserIdentity, User>()

	// MARK: Tab Selection
	var selectedTab: SearchType = .shows
	var availableTabs: [SearchType] = []

	// MARK: Filters
	var activeFilters: [SearchType: SearchFilter] = [:]

	// MARK: Private
	private var searchTask: Task<Void, Never>?

	/// Canonical display order for search result tabs.
	private let tabOrder: [SearchType] = [
		.shows, .literatures, .games, .episodes, .characters, .people, .songs, .studios, .users
	]

	// MARK: - Functions
	/// Fetches search suggestions using a random letter.
	func fetchSuggestions() async {
		self.suggestionsLoadState = .loading

		let randomLetter = String(UnicodeScalar(Int.random(in: 97...122)) ?? UnicodeScalar(97))
		let types: [SearchType] = self.scope == .library
			? [.shows, .literatures, .games]
			: [.shows, .literatures, .games, .episodes, .characters, .people, .songs, .studios, .users]

		do {
			let response = try await KService.searchSuggestions(self.scope, types: types, query: randomLetter).response()
			self.suggestions = response.data
			self.suggestionsLoadState = .loaded
		} catch {
			print("Search suggestions fetch error: \(error.localizedDescription)")
			self.suggestionsLoadState = .error("Failed to load suggestions.")
		}
	}

	/// Submits the current search text for execution.
	func submitSearch() async {
		let query = self.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !query.isEmpty else { return }

		// Cancel any in-flight search
		self.searchTask?.cancel()
		self.activeSearchText = query
		self.hasSearched = true

		// Reset all buckets
		self.resetAllBuckets()

		let task = Task {
			await self.executeSearch(query: query)
		}
		self.searchTask = task
	}

	/// Loads the next page of results for the given content type.
	func loadNextPage(for type: SearchType) async {
		switch type {
		case .shows:
			guard !self.showsBucket.isLoadingNextPage, self.showsBucket.nextPageCursor != nil else { return }
			self.showsBucket.isLoadingNextPage = true
			await self.fetchNextPage(for: type)
			self.showsBucket.isLoadingNextPage = false
		case .literatures:
			guard !self.literaturesBucket.isLoadingNextPage, self.literaturesBucket.nextPageCursor != nil else { return }
			self.literaturesBucket.isLoadingNextPage = true
			await self.fetchNextPage(for: type)
			self.literaturesBucket.isLoadingNextPage = false
		case .games:
			guard !self.gamesBucket.isLoadingNextPage, self.gamesBucket.nextPageCursor != nil else { return }
			self.gamesBucket.isLoadingNextPage = true
			await self.fetchNextPage(for: type)
			self.gamesBucket.isLoadingNextPage = false
		case .episodes:
			guard !self.episodesBucket.isLoadingNextPage, self.episodesBucket.nextPageCursor != nil else { return }
			self.episodesBucket.isLoadingNextPage = true
			await self.fetchNextPage(for: type)
			self.episodesBucket.isLoadingNextPage = false
		case .characters:
			guard !self.charactersBucket.isLoadingNextPage, self.charactersBucket.nextPageCursor != nil else { return }
			self.charactersBucket.isLoadingNextPage = true
			await self.fetchNextPage(for: type)
			self.charactersBucket.isLoadingNextPage = false
		case .people:
			guard !self.peopleBucket.isLoadingNextPage, self.peopleBucket.nextPageCursor != nil else { return }
			self.peopleBucket.isLoadingNextPage = true
			await self.fetchNextPage(for: type)
			self.peopleBucket.isLoadingNextPage = false
		case .songs:
			guard !self.songsBucket.isLoadingNextPage, self.songsBucket.nextPageCursor != nil else { return }
			self.songsBucket.isLoadingNextPage = true
			await self.fetchNextPage(for: type)
			self.songsBucket.isLoadingNextPage = false
		case .studios:
			guard !self.studiosBucket.isLoadingNextPage, self.studiosBucket.nextPageCursor != nil else { return }
			self.studiosBucket.isLoadingNextPage = true
			await self.fetchNextPage(for: type)
			self.studiosBucket.isLoadingNextPage = false
		case .users:
			guard !self.usersBucket.isLoadingNextPage, self.usersBucket.nextPageCursor != nil else { return }
			self.usersBucket.isLoadingNextPage = true
			await self.fetchNextPage(for: type)
			self.usersBucket.isLoadingNextPage = false
		}
	}

	/// Resets all search state.
	func resetSearch() {
		self.searchTask?.cancel()
		self.activeSearchText = ""
		self.hasSearched = false
		self.resetAllBuckets()
	}

	/// Returns the model for a given identity ID in the specified type's bucket, if hydrated.
	func show(for identity: ShowIdentity) -> Show? { self.showsBucket.models[identity.id] }
	func literature(for identity: LiteratureIdentity) -> Literature? { self.literaturesBucket.models[identity.id] }
	func game(for identity: GameIdentity) -> Game? { self.gamesBucket.models[identity.id] }
	func episode(for identity: EpisodeIdentity) -> Episode? { self.episodesBucket.models[identity.id] }
	func character(for identity: CharacterIdentity) -> Character? { self.charactersBucket.models[identity.id] }
	func person(for identity: PersonIdentity) -> Person? { self.peopleBucket.models[identity.id] }
	func song(for identity: SongIdentity) -> Song? { self.songsBucket.models[identity.id] }
	func studio(for identity: StudioIdentity) -> Studio? { self.studiosBucket.models[identity.id] }
	func user(for identity: UserIdentity) -> User? { self.usersBucket.models[identity.id] }

	// MARK: - Private
	private func resetAllBuckets() {
		self.showsBucket = SearchTypeBucket()
		self.literaturesBucket = SearchTypeBucket()
		self.gamesBucket = SearchTypeBucket()
		self.episodesBucket = SearchTypeBucket()
		self.charactersBucket = SearchTypeBucket()
		self.peopleBucket = SearchTypeBucket()
		self.songsBucket = SearchTypeBucket()
		self.studiosBucket = SearchTypeBucket()
		self.usersBucket = SearchTypeBucket()
		self.availableTabs = []
	}

	private func executeSearch(query: String) async {
		let types: [SearchType] = self.scope == .library
			? [.shows, .literatures, .games]
			: self.tabOrder

		let filter = self.activeFilters.count == 1 ? self.activeFilters.values.first : nil

		do {
			let response = try await KService
				.search(self.scope, types: types, query: query)
				.limit(25)
				.filter(filter)
				.response()

			guard !Task.isCancelled else { return }

			// Populate buckets from response
			self.populateBuckets(from: response.data)

			// Determine which tabs have results
			self.availableTabs = self.tabOrder.filter { type in
				self.identityCount(for: type) > 0
			}

			if let firstTab = self.availableTabs.first {
				self.selectedTab = firstTab
			}

			// Hydrate all populated buckets concurrently
			await withTaskGroup(of: Void.self) { group in
				for type in self.availableTabs {
					group.addTask {
						await self.hydrateAll(for: type)
					}
				}
			}
		} catch {
			guard !Task.isCancelled else { return }
			print("Search error: \(error.localizedDescription)")
		}
	}

	private func populateBuckets(from search: Search) {
		if let shows = search.shows {
			self.showsBucket.identities = shows.data
			self.showsBucket.nextPageCursor = shows.nextCursor
			self.showsBucket.loadState = .loading
		}
		if let literatures = search.literatures {
			self.literaturesBucket.identities = literatures.data
			self.literaturesBucket.nextPageCursor = literatures.nextCursor
			self.literaturesBucket.loadState = .loading
		}
		if let games = search.games {
			self.gamesBucket.identities = games.data
			self.gamesBucket.nextPageCursor = games.nextCursor
			self.gamesBucket.loadState = .loading
		}
		if let episodes = search.episodes {
			self.episodesBucket.identities = episodes.data
			self.episodesBucket.nextPageCursor = episodes.nextCursor
			self.episodesBucket.loadState = .loading
		}
		if let characters = search.characters {
			self.charactersBucket.identities = characters.data
			self.charactersBucket.nextPageCursor = characters.nextCursor
			self.charactersBucket.loadState = .loading
		}
		if let people = search.people {
			self.peopleBucket.identities = people.data
			self.peopleBucket.nextPageCursor = people.nextCursor
			self.peopleBucket.loadState = .loading
		}
		if let songs = search.songs {
			self.songsBucket.identities = songs.data
			self.songsBucket.nextPageCursor = songs.nextCursor
			self.songsBucket.loadState = .loading
		}
		if let studios = search.studios {
			self.studiosBucket.identities = studios.data
			self.studiosBucket.nextPageCursor = studios.nextCursor
			self.studiosBucket.loadState = .loading
		}
		if let users = search.users {
			self.usersBucket.identities = users.data
			self.usersBucket.nextPageCursor = users.nextCursor
			self.usersBucket.loadState = .loading
		}
	}

	private func identityCount(for type: SearchType) -> Int {
		switch type {
		case .shows: return self.showsBucket.identities.count
		case .literatures: return self.literaturesBucket.identities.count
		case .games: return self.gamesBucket.identities.count
		case .episodes: return self.episodesBucket.identities.count
		case .characters: return self.charactersBucket.identities.count
		case .people: return self.peopleBucket.identities.count
		case .songs: return self.songsBucket.identities.count
		case .studios: return self.studiosBucket.identities.count
		case .users: return self.usersBucket.identities.count
		}
	}

	private func hydrateAll(for type: SearchType) async {
		switch type {
		case .shows: await self.hydrateShows()
		case .literatures: await self.hydrateLiteratures()
		case .games: await self.hydrateGames()
		case .episodes: await self.hydrateEpisodes()
		case .characters: await self.hydrateCharacters()
		case .people: await self.hydratePeople()
		case .songs: await self.hydrateSongs()
		case .studios: await self.hydrateStudios()
		case .users: await self.hydrateUsers()
		}
	}

	// MARK: Hydration
	private func hydrateShows() async {
		let unhydrated = self.showsBucket.identities.filter { self.showsBucket.models[$0.id] == nil }
		guard !unhydrated.isEmpty else {
			self.showsBucket.loadState = .loaded
			return
		}

		do {
			let response = try await KService.details(unhydrated).response()
			for show in response.data {
				self.showsBucket.models[show.id] = show
			}
			self.showsBucket.loadState = .loaded
		} catch {
			self.showsBucket.loadState = .error("Failed to load shows.")
			print("Show hydration error: \(error.localizedDescription)")
		}
	}

	private func hydrateLiteratures() async {
		let unhydrated = self.literaturesBucket.identities.filter { self.literaturesBucket.models[$0.id] == nil }
		guard !unhydrated.isEmpty else {
			self.literaturesBucket.loadState = .loaded
			return
		}

		do {
			let response = try await KService.details(unhydrated).response()
			for literature in response.data {
				self.literaturesBucket.models[literature.id] = literature
			}
			self.literaturesBucket.loadState = .loaded
		} catch {
			self.literaturesBucket.loadState = .error("Failed to load manga.")
			print("Literature hydration error: \(error.localizedDescription)")
		}
	}

	private func hydrateGames() async {
		let unhydrated = self.gamesBucket.identities.filter { self.gamesBucket.models[$0.id] == nil }
		guard !unhydrated.isEmpty else {
			self.gamesBucket.loadState = .loaded
			return
		}

		do {
			let response = try await KService.details(unhydrated).response()
			for game in response.data {
				self.gamesBucket.models[game.id] = game
			}
			self.gamesBucket.loadState = .loaded
		} catch {
			self.gamesBucket.loadState = .error("Failed to load games.")
			print("Game hydration error: \(error.localizedDescription)")
		}
	}

	private func hydrateEpisodes() async {
		let unhydrated = self.episodesBucket.identities.filter { self.episodesBucket.models[$0.id] == nil }
		guard !unhydrated.isEmpty else {
			self.episodesBucket.loadState = .loaded
			return
		}

		do {
			let response = try await KService.details(unhydrated).response()
			for episode in response.data {
				self.episodesBucket.models[episode.id] = episode
			}
			self.episodesBucket.loadState = .loaded
		} catch {
			self.episodesBucket.loadState = .error("Failed to load episodes.")
			print("Episode hydration error: \(error.localizedDescription)")
		}
	}

	private func hydrateCharacters() async {
		let unhydrated = self.charactersBucket.identities.filter { self.charactersBucket.models[$0.id] == nil }
		guard !unhydrated.isEmpty else {
			self.charactersBucket.loadState = .loaded
			return
		}

		do {
			let response = try await KService.details(unhydrated).response()
			for character in response.data {
				self.charactersBucket.models[character.id] = character
			}
			self.charactersBucket.loadState = .loaded
		} catch {
			self.charactersBucket.loadState = .error("Failed to load characters.")
			print("Character hydration error: \(error.localizedDescription)")
		}
	}

	private func hydratePeople() async {
		let unhydrated = self.peopleBucket.identities.filter { self.peopleBucket.models[$0.id] == nil }
		guard !unhydrated.isEmpty else {
			self.peopleBucket.loadState = .loaded
			return
		}

		do {
			let response = try await KService.details(unhydrated).response()
			for person in response.data {
				self.peopleBucket.models[person.id] = person
			}
			self.peopleBucket.loadState = .loaded
		} catch {
			self.peopleBucket.loadState = .error("Failed to load people.")
			print("Person hydration error: \(error.localizedDescription)")
		}
	}

	private func hydrateSongs() async {
		let unhydrated = self.songsBucket.identities.filter { self.songsBucket.models[$0.id] == nil }
		guard !unhydrated.isEmpty else {
			self.songsBucket.loadState = .loaded
			return
		}

		do {
			let response = try await KService.details(unhydrated).response()
			for song in response.data {
				self.songsBucket.models[song.id] = song
			}
			self.songsBucket.loadState = .loaded
		} catch {
			self.songsBucket.loadState = .error("Failed to load songs.")
			print("Song hydration error: \(error.localizedDescription)")
		}
	}

	private func hydrateStudios() async {
		let unhydrated = self.studiosBucket.identities.filter { self.studiosBucket.models[$0.id] == nil }
		guard !unhydrated.isEmpty else {
			self.studiosBucket.loadState = .loaded
			return
		}

		do {
			let response = try await KService.details(unhydrated).response()
			for studio in response.data {
				self.studiosBucket.models[studio.id] = studio
			}
			self.studiosBucket.loadState = .loaded
		} catch {
			self.studiosBucket.loadState = .error("Failed to load studios.")
			print("Studio hydration error: \(error.localizedDescription)")
		}
	}

	private func hydrateUsers() async {
		let unhydrated = self.usersBucket.identities.filter { self.usersBucket.models[$0.id] == nil }
		guard !unhydrated.isEmpty else {
			self.usersBucket.loadState = .loaded
			return
		}

		do {
			let response = try await KService.details(unhydrated).response()
			for user in response.data {
				self.usersBucket.models[user.id] = user
			}
			self.usersBucket.loadState = .loaded
		} catch {
			self.usersBucket.loadState = .error("Failed to load users.")
			print("User hydration error: \(error.localizedDescription)")
		}
	}

	// MARK: Pagination
	private func fetchNextPage(for type: SearchType) async {
		let cursor: PageCursor?
		switch type {
		case .shows: cursor = self.showsBucket.nextPageCursor
		case .literatures: cursor = self.literaturesBucket.nextPageCursor
		case .games: cursor = self.gamesBucket.nextPageCursor
		case .episodes: cursor = self.episodesBucket.nextPageCursor
		case .characters: cursor = self.charactersBucket.nextPageCursor
		case .people: cursor = self.peopleBucket.nextPageCursor
		case .songs: cursor = self.songsBucket.nextPageCursor
		case .studios: cursor = self.studiosBucket.nextPageCursor
		case .users: cursor = self.usersBucket.nextPageCursor
		}

		guard cursor != nil else { return }

		do {
			let response = try await KService
				.search(self.scope, types: [type], query: self.activeSearchText)
				.cursor(cursor)
				.limit(100)
				.response()

			self.appendPageResults(from: response.data, for: type)
			await self.hydrateAll(for: type)
		} catch {
			print("Next page fetch error for \(type): \(error.localizedDescription)")
		}
	}

	private func appendPageResults(from search: Search, for type: SearchType) {
		switch type {
		case .shows:
			if let shows = search.shows {
				self.showsBucket.identities.append(contentsOf: shows.data.filter { identity in
					!self.showsBucket.identities.contains(where: { $0.id == identity.id })
				})
				self.showsBucket.nextPageCursor = shows.nextCursor
			}
		case .literatures:
			if let literatures = search.literatures {
				self.literaturesBucket.identities.append(contentsOf: literatures.data.filter { identity in
					!self.literaturesBucket.identities.contains(where: { $0.id == identity.id })
				})
				self.literaturesBucket.nextPageCursor = literatures.nextCursor
			}
		case .games:
			if let games = search.games {
				self.gamesBucket.identities.append(contentsOf: games.data.filter { identity in
					!self.gamesBucket.identities.contains(where: { $0.id == identity.id })
				})
				self.gamesBucket.nextPageCursor = games.nextCursor
			}
		case .episodes:
			if let episodes = search.episodes {
				self.episodesBucket.identities.append(contentsOf: episodes.data.filter { identity in
					!self.episodesBucket.identities.contains(where: { $0.id == identity.id })
				})
				self.episodesBucket.nextPageCursor = episodes.nextCursor
			}
		case .characters:
			if let characters = search.characters {
				self.charactersBucket.identities.append(contentsOf: characters.data.filter { identity in
					!self.charactersBucket.identities.contains(where: { $0.id == identity.id })
				})
				self.charactersBucket.nextPageCursor = characters.nextCursor
			}
		case .people:
			if let people = search.people {
				self.peopleBucket.identities.append(contentsOf: people.data.filter { identity in
					!self.peopleBucket.identities.contains(where: { $0.id == identity.id })
				})
				self.peopleBucket.nextPageCursor = people.nextCursor
			}
		case .songs:
			if let songs = search.songs {
				self.songsBucket.identities.append(contentsOf: songs.data.filter { identity in
					!self.songsBucket.identities.contains(where: { $0.id == identity.id })
				})
				self.songsBucket.nextPageCursor = songs.nextCursor
			}
		case .studios:
			if let studios = search.studios {
				self.studiosBucket.identities.append(contentsOf: studios.data.filter { identity in
					!self.studiosBucket.identities.contains(where: { $0.id == identity.id })
				})
				self.studiosBucket.nextPageCursor = studios.nextCursor
			}
		case .users:
			if let users = search.users {
				self.usersBucket.identities.append(contentsOf: users.data.filter { identity in
					!self.usersBucket.identities.contains(where: { $0.id == identity.id })
				})
				self.usersBucket.nextPageCursor = users.nextCursor
			}
		}
	}
}

// MARK: - SearchType+Watch
extension SearchType {
	/// The short display label for the tab picker on watchOS.
	var watchLabel: String {
		switch self {
		case .shows: return "Anime"
		case .literatures: return "Manga"
		case .games: return "Games"
		case .episodes: return "Episodes"
		case .characters: return "Characters"
		case .people: return "People"
		case .songs: return "Songs"
		case .studios: return "Studios"
		case .users: return "Users"
		}
	}
}
