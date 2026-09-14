//
//  LibraryKind+Notifications.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension LibraryKind {
	/// The scheme path a title of this kind is opened with.
	var schemePath: String {
		switch self {
		case .shows:
			return Scheme.anime.rawValue
		case .literatures:
			return Scheme.manga.rawValue
		case .games:
			return Scheme.game.rawValue
		}
	}
}
