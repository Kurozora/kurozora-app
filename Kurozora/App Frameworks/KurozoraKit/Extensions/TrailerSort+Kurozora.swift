//
//  TrailerSort+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension TrailerSort {
	// MARK: - Properties
	/// The localized title of the sort order.
	var title: String {
		switch self {
		case .justAdded:
			return L10n.justAdded
		case .trending:
			return L10n.trending
		case .mostPopular:
			return L10n.mostPopular
		case .mostAnticipated:
			return L10n.mostAnticipated
		}
	}
}
