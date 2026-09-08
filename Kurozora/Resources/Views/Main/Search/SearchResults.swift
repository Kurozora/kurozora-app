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
	enum Section: Int, CaseIterable, Sendable {
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
	enum Item: nonisolated Hashable, Sendable {
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
	}
}
