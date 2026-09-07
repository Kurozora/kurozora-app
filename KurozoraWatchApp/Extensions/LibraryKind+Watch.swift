//
//  LibraryKind+Watch.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension LibraryKind {
	/// The kind title shown on the Watch.
	var watchTitle: String {
		switch self {
		case .shows:
			return L10n.anime
		case .literatures:
			return L10n.manga
		case .games:
			return L10n.games
		}
	}

	/// The symbol shown on the library kind picker.
	var symbolName: String {
		switch self {
		case .shows:
			return "tv.fill"
		case .literatures:
			return "book.fill"
		case .games:
			return "gamecontroller.fill"
		}
	}

	/// The aspect ratio the kind's posters are rendered at.
	var artworkShape: ArtworkShape {
		switch self {
		case .shows, .literatures:
			return .poster
		case .games:
			return .square
		}
	}

	/// The status name under which the iOS list cell shows a countdown.
	var airingStatusName: String {
		switch self {
		case .shows:
			return "Currently Airing"
		case .literatures, .games:
			return "Currently Publishing"
		}
	}
}
