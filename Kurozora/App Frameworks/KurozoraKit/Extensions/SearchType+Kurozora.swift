//
//  SearchType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension SearchType {
	/// The string value of a search type.
	var stringValue: String {
		switch self {
		case .characters:
			return L10n.characters
		case .episodes:
			return L10n.episodes
		case .games:
			return L10n.games
		case .literatures:
			return L10n.literatures
		case .people:
			return L10n.people
		case .shows:
			return L10n.shows
		case .songs:
			return L10n.songs
		case .studios:
			return L10n.studios
		case .users:
			return L10n.users
		}
	}

	/// Lowercased synonyms used to match a typed keyword to this search type.
	var tokenKeywords: [String] {
		switch self {
		case .shows:
			return ["anime", "show", "shows", "tv"]
		case .literatures:
			return ["manga", "literature", "literatures", "novel"]
		case .games:
			return ["game", "games"]
		case .characters:
			return ["character", "characters"]
		case .episodes:
			return ["episode", "episodes"]
		case .people:
			return ["person", "people"]
		case .songs:
			return ["song", "songs", "music"]
		case .studios:
			return ["studio", "studios"]
		case .users:
			return ["user", "users"]
		}
	}
}
