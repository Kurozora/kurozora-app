//
//  ForumOrder+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit

extension ForumOrder {
	// MARK: - Properties
	/// The image value of a forum order type.
	var imageValue: UIImage {
		switch self {
		case .best:
			return R.image.symbols.hand_thumbsup()!
		case .top:
			return R.image.symbols.arrow_up_line_horizontal_3_decrease()!
		case .new:
			return R.image.symbols.calendar_badge_arrowshape_turn_up_right()!
		case .old:
			return R.image.symbols.calendar_badge_arrowshape_turn_up_left()!
		case .poor:
			return R.image.symbols.arrow_down_line_horizontal_3_increase()!
		case .controversial:
			return R.image.symbols.hand_thumbsdown()!
		}
	}

	/// An array containing all forum order type string value and its equivalent raw value.
	static var alertControllerItems: [(String, ForumOrder, UIImage)] {
		var items = [(String, ForumOrder, UIImage)]()
		for sortType in ForumOrder.allCases {
			let title = sortType.rawValue
			items.append((title.capitalized, sortType, sortType.imageValue))
		}
		return items
	}
}
