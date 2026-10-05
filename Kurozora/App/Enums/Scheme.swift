//
//  Scheme.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/// List of supported schemes.
///
/// ```
/// case anime, show, shows
/// case episode, episodes
/// case game, games
/// case manga, literature, literatures
/// case profile, user
/// case explore, home
/// case library, myLibrary, list
/// case feed, timeline
/// case notification, notifications
/// case schedule
/// case museum
/// case search
/// case parentalGuide
/// case stickers
/// case kotodama
/// ```
enum Scheme: String, CaseIterable {
	// MARK: - Cases
	case anime, show, shows
	case episode, episodes
	case game, games
	case manga, literature, literatures
	case profile, user
	case people, person
	case character, characters
	case studio, studios
	case song, songs
	case explore, home
	case library, myLibrary, list
	case feed, timeline
	case notification, notifications
	case schedule
	case season
	case seasons
	case museum
	case recap
	case search
	case parentalGuide = "parentalguide"
	case stickers
	case kotodama
	case genres
	case themes
	case charts
	case kurozoraPlus = "kurozora-plus"
	case tipJar = "tip-jar"
	case digest
	case leaderboards
	case themeStore = "theme-store"
	case upNext = "up-next"

	// MARK: - Properties
	var urlValue: URL {
		return URL(string: "kurozora://\(self.rawValue)")!
	}
}
