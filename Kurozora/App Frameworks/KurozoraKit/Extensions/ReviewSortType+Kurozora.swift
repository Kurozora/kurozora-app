//
//  ReviewSortType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ReviewSortType {
	// MARK: - Properties
	/// The localized title of the sort type.
	var title: String {
		switch self {
		case .date:
			return L10n.reviewSortDate
		case .title:
			return L10n.reviewSortTitle
		case .rating:
			return L10n.reviewSortRating
		}
	}

	/// The image of the sort type.
	var imageValue: UIImage? {
		switch self {
		case .date:
			return UIImage(systemName: "calendar")
		case .title:
			return UIImage(systemName: "textformat.abc")
		case .rating:
			return UIImage(systemName: "star.fill")
		}
	}
}
