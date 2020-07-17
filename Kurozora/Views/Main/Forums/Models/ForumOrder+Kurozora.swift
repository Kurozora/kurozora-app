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
		case .top:
			return R.image.symbols.arrow_up_line_horizontal_3_decrease()!
		case .recent:
			return R.image.symbols.clock()!
		}
	}

	/// An array containing all forum order type string value and its equivalent raw value.
	static var alertControllerItems: [(String, ForumOrder, UIImage)] {
		var items = [(String, ForumOrder, UIImage)]()
		for sortType in ForumOrder.allCases {
			var title = sortType.rawValue
			title.firstCharacterUppercased()
			items.append((title, sortType, sortType.imageValue))
		}
		return items
	}
}
