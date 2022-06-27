//
//  KKSearchType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension KKSearchType {
	/// The string value of a search scope.
	var stringValue: String {
		switch self {
		case .characters:
			return Trans.characters
//		case .games:
//			return Trans.games
//		case .literature:
//			return Trans.literature
		case .people:
			return Trans.people
		case .shows:
			return Trans.anime
		case .songs:
			return Trans.songs
		case .studios:
			return Trans.studios
		case .users:
			return Trans.users
		}
	}

	/// The suggestions value of a search scope.
	var suggestionsValue: [String] {
		switch self {
		case .characters:
			return ["Kirito", "Luffy", "Monokuma", ""]
//		case .games:
//			return [""]
		case .shows:
			return ["One Piece", "Shaman Asakaura", "a young girl with big ambitions", "massively multiplayer online role-playing game", "vampires"]
//		case .literature:
//			return ["Sword Art Online", "One Piece", "BLAME", "Bungo Stray Dogs"]
		case .people:
			return ["Konomi Suzuki", "Reiki Kawahara"]
		case .songs:
			return ["Blue Bird", "Amadeus", "Strike It Out", "Shadow and Truth", "Trash Candy", "Redo"]
		case .studios:
			return ["Rooster Teeth", "White Fox", "MAPPA", "A-1 Pictures"]
		case .users:
			return ["Kirito", "Usopp"]
		}
	}
}
