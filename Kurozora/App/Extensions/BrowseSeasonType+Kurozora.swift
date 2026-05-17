//
//  BrowseSeasonType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension BrowseSeasonType {
	/// Creates a browse season type from the given URL path component.
	///
	/// - Parameter pathComponent: The path component to match.
	init?(pathComponent: String) {
		switch pathComponent.lowercased() {
		case "anime", "show", "shows":
			self = .shows
		case "manga", "literature", "literatures":
			self = .literatures
		case "game", "games":
			self = .games
		default:
			return nil
		}
	}
}
