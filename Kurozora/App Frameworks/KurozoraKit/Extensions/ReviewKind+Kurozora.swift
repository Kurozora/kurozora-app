//
//  ReviewKind+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension ReviewKind {
	// MARK: - Properties
	/// The kinds in the order the reviews list offers them.
	static let listOrder: [ReviewKind] = [.shows, .literatures, .games, .episodes, .songs, .characters, .people, .studios]

	/// The localized title of the review kind.
	var title: String {
		switch self {
		case .shows:
			return L10n.anime
		case .literatures:
			return L10n.manga
		case .games:
			return L10n.games
		case .characters:
			return L10n.characters
		case .people:
			return L10n.people
		case .studios:
			return L10n.studios
		case .songs:
			return L10n.songs
		case .episodes:
			return L10n.episodes
		}
	}
}
