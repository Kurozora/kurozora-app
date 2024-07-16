//
//  SearchResults.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit

struct SearchResults {
	/// List of character section layout.
	enum Section: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates the discover section.
		case discover

		/// Indicates the browse section.
		case browse

		/// Indicates the characters' section.
		case characters

		/// Indicates the episodes' section.
		case episodes

		/// Indicates the games' section.
		case games

		/// Indicates the literatures' section.
		case literatures

		/// Indicates the people's section.
		case people

		/// Indicates the songs' section.
		case songs

		/// Indicates the shows' section.
		case shows

		/// Indicates the studios' section.
		case studios

		/// Indicates the users' section.
		case users
	}

	/// List of available Item types.
	enum Item: Hashable {
		// MARK: - Cases
		/// Indicates the item contains a discover suggestion.
		case discoverSuggestion(_: QuickLink)

		/// Indicates the item contains a browse identifier.
		case browseCategory(_: BrowseCategory)

		/// Indicates the item contains a `Show` object.
		case show(_: Show)

		/// Indicates the item contains a `Literature` object.
		case literature(_: Literature)

		/// Indicates the item contains a `Game` object.
		case game(_: Game)

		/// Indicates the item contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity, _: UUID = UUID())

		/// Indicates the item contains a `EpisodeIdentity` object.
		case episodeIdentity(_: EpisodeIdentity, _: UUID = UUID())

		/// Indicates the item contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, _: UUID = UUID())

		/// Indicates the item contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, _: UUID = UUID())

		/// Indicates the item contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, _: UUID = UUID())

		/// Indicates the item contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, _: UUID = UUID())

		/// Indicates the item contains a `SongIdentity` object.
		case songIdentity(_: SongIdentity, _: UUID = UUID())

		/// Indicates the item contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity, _: UUID = UUID())

		/// Indicates the item contains a `UserIdentity` object.
		case userIdentity(_: UserIdentity, _: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .discoverSuggestion(let discoverSuggestion):
				hasher.combine(discoverSuggestion)
			case .browseCategory(let browseCategory):
				hasher.combine(browseCategory)
			case .show(let show):
				hasher.combine(show)
			case .literature(let literature):
				hasher.combine(literature)
			case .game(let game):
				hasher.combine(game)
			case .characterIdentity(let characterIdentity, let uuid):
				hasher.combine(characterIdentity)
				hasher.combine(uuid)
			case .episodeIdentity(let episodeIdentity, let uuid):
				hasher.combine(episodeIdentity)
				hasher.combine(uuid)
			case .gameIdentity(let gameIdentity, let uuid):
				hasher.combine(gameIdentity)
				hasher.combine(uuid)
			case .literatureIdentity(let literatureIdentity, let uuid):
				hasher.combine(literatureIdentity)
				hasher.combine(uuid)
			case .personIdentity(let personIdentity, let uuid):
				hasher.combine(personIdentity)
				hasher.combine(uuid)
			case .showIdentity(let showIdentity, let uuid):
				hasher.combine(showIdentity)
				hasher.combine(uuid)
			case .songIdentity(let songIdentity, let uuid):
				hasher.combine(songIdentity)
				hasher.combine(uuid)
			case .studioIdentity(let studioIdentity, let uuid):
				hasher.combine(studioIdentity)
				hasher.combine(uuid)
			case .userIdentity(let userIdentity, let uuid):
				hasher.combine(userIdentity)
				hasher.combine(uuid)
			}
		}

		static func == (lhs: Item, rhs: Item) -> Bool {
			switch (lhs, rhs) {
			case (.discoverSuggestion(let discoverSuggestion1), .discoverSuggestion(let discoverSuggestion2)):
				return discoverSuggestion1 == discoverSuggestion2
			case (.browseCategory(let browseCategory1), .browseCategory(let browseCategory2)):
				return browseCategory1 == browseCategory2
			case (.show(let show1), .show(let show2)):
				return show1 == show2
			case (.literature(let literature1), .literature(let literature2)):
				return literature1 == literature2
			case (.game(let game1), .game(let game2)):
				return game1 == game2
			case (.characterIdentity(let characterIdentity1, let uuid1), .characterIdentity(let characterIdentity2, let uuid2)):
				return characterIdentity1 == characterIdentity2 && uuid1 == uuid2
			case (.episodeIdentity(let episodeIdentity1, let uuid1), .episodeIdentity(let episodeIdentity2, let uuid2)):
				return episodeIdentity1 == episodeIdentity2 && uuid1 == uuid2
			case (.gameIdentity(let gameIdentity1, let uuid1), .gameIdentity(let gameIdentity2, let uuid2)):
				return gameIdentity1 == gameIdentity2 && uuid1 == uuid2
			case (.literatureIdentity(let literatureIdentity1, let uuid1), .literatureIdentity(let literatureIdentity2, let uuid2)):
				return literatureIdentity1 == literatureIdentity2 && uuid1 == uuid2
			case (.personIdentity(let personIdentity1, let uuid1), .personIdentity(let personIdentity2, let uuid2)):
				return personIdentity1 == personIdentity2 && uuid1 == uuid2
			case (.showIdentity(let showIdentity1, let uuid1), .showIdentity(let showIdentity2, let uuid2)):
				return showIdentity1 == showIdentity2 && uuid1 == uuid2
			case (.songIdentity(let songIdentity1, let uuid1), .songIdentity(let songIdentity2, let uuid2)):
				return songIdentity1 == songIdentity2 && uuid1 == uuid2
			case (.studioIdentity(let studioIdentity1, let uuid1), .studioIdentity(let studioIdentity2, let uuid2)):
				return studioIdentity1 == studioIdentity2 && uuid1 == uuid2
			case (.userIdentity(let userIdentity1, let uuid1), .userIdentity(let userIdentity2, let uuid2)):
				return userIdentity1 == userIdentity2 && uuid1 == uuid2
			default:
				return false
			}
		}
	}
}
