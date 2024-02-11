//
//  KKSearchTypeAppEnum.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/02/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation
import AppIntents
import KurozoraKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
enum KKSearchTypeAppEnum: String, AppEnum {
    case characters
    case episodes
    case games
    case literatures
    case people
    case shows
    case songs
    case studios
    case users

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Search Kind")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .characters: "Characters",
        .episodes: "Episodes",
        .games: "Games",
        .literatures: "Literatures",
        .people: "People",
        .shows: "Shows",
        .songs: "Songs",
        .studios: "Studios",
        .users: "Users"
    ]

	/// The `KKSearchType` value of a `KKSearchTypeAppEnum` type.
	var kkSearchTypeValue: KKSearchType {
		switch self {
		case .characters:
			return .characters
		case .episodes:
			return .episodes
		case .games:
			return .games
		case .literatures:
			return .literatures
		case .people:
			return .people
		case .shows:
			return .shows
		case .songs:
			return .songs
		case .studios:
			return .studios
		case .users:
			return .users
		}
	}
}
