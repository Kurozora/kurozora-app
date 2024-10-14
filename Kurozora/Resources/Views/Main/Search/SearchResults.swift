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
		case characterIdentity(_: CharacterIdentity)

		/// Indicates the item contains a `EpisodeIdentity` object.
		case episodeIdentity(_: EpisodeIdentity)

		/// Indicates the item contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity)

		/// Indicates the item contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity)

		/// Indicates the item contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity)

		/// Indicates the item contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity)

		/// Indicates the item contains a `SongIdentity` object.
		case songIdentity(_: SongIdentity)

		/// Indicates the item contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity)

		/// Indicates the item contains a `UserIdentity` object.
		case userIdentity(_: UserIdentity)

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
			case .characterIdentity(let characterIdentity):
				hasher.combine(characterIdentity)
			case .episodeIdentity(let episodeIdentity):
				hasher.combine(episodeIdentity)
			case .gameIdentity(let gameIdentity):
				hasher.combine(gameIdentity)
			case .literatureIdentity(let literatureIdentity):
				hasher.combine(literatureIdentity)
			case .personIdentity(let personIdentity):
				hasher.combine(personIdentity)
			case .showIdentity(let showIdentity):
				hasher.combine(showIdentity)
			case .songIdentity(let songIdentity):
				hasher.combine(songIdentity)
			case .studioIdentity(let studioIdentity):
				hasher.combine(studioIdentity)
			case .userIdentity(let userIdentity):
				hasher.combine(userIdentity)
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
			case (.characterIdentity(let characterIdentity1), .characterIdentity(let characterIdentity2)):
				return characterIdentity1 == characterIdentity2
			case (.episodeIdentity(let episodeIdentity1), .episodeIdentity(let episodeIdentity2)):
				return episodeIdentity1 == episodeIdentity2
			case (.gameIdentity(let gameIdentity1), .gameIdentity(let gameIdentity2)):
				return gameIdentity1 == gameIdentity2
			case (.literatureIdentity(let literatureIdentity1), .literatureIdentity(let literatureIdentity2)):
				return literatureIdentity1 == literatureIdentity2
			case (.personIdentity(let personIdentity1), .personIdentity(let personIdentity2)):
				return personIdentity1 == personIdentity2
			case (.showIdentity(let showIdentity1), .showIdentity(let showIdentity2)):
				return showIdentity1 == showIdentity2
			case (.songIdentity(let songIdentity1), .songIdentity(let songIdentity2)):
				return songIdentity1 == songIdentity2
			case (.studioIdentity(let studioIdentity1), .studioIdentity(let studioIdentity2)):
				return studioIdentity1 == studioIdentity2
			case (.userIdentity(let userIdentity1), .userIdentity(let userIdentity2)):
				return userIdentity1 == userIdentity2
			default:
				return false
			}
		}
	}
}
