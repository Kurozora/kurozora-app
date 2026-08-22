//
//  AdaptedFilter+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension AdaptedFilter {
	/// The localized title of an adapted filter.
	var localizedTitle: String {
		switch self {
		case .all:
			return L10n.all
		case .airing:
			return L10n.airingNow
		case .upcoming:
			return L10n.upcomingAnime
		}
	}
}
