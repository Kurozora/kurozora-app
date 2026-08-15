//
//  RatingStyle+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension RatingStyle {
	// MARK: - Properties
	/// The localized name of the rating style.
	var localizedName: String {
		switch self {
		case .quickReaction:
			return L10n.ratingStyleQuickReaction
		case .standard:
			return L10n.ratingStyleStandard
		case .detailed:
			return L10n.ratingStyleDetailed
		}
	}
}
