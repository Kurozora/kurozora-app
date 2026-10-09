//
//  ReviewSortOption+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ReviewSortOption {
	// MARK: - Properties
	/// The localized title of the sort option.
	var title: String {
		switch self {
		case .newest:
			return L10n.reviewSortNewest
		case .oldest:
			return L10n.reviewSortOldest
		case .ascending:
			return L10n.reviewSortAscending
		case .descending:
			return L10n.reviewSortDescending
		case .best:
			return L10n.reviewSortHighest
		case .worst:
			return L10n.reviewSortLowest
		}
	}

	/// The image of the sort option.
	var imageValue: UIImage? {
		switch self {
		case .newest:
			return UIImage.Symbols.calendarBadgeArrowshapeTurnUpRight
		case .oldest:
			return UIImage.Symbols.calendarBadgeArrowshapeTurnUpLeft
		case .ascending:
			return UIImage(systemName: "line.3.horizontal.decrease")
		case .descending:
			return UIImage.Symbols.line3HorizontalIncrease
		case .best:
			return UIImage(systemName: "hand.thumbsup.fill")
		case .worst:
			return UIImage(systemName: "hand.thumbsdown.fill")
		}
	}
}
