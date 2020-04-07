//
//  KKLibrarySortType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension KKLibrary.SortType {
	/// The image value of a sort type.
	var imageValue: UIImage {
		switch self {
		case .none:
			return R.image.symbols.line_horizontal_3_decrease_circle_fill()!
		case .alphabetically:
			return R.image.symbols.textformat_abc()!
			//			case .popularity:
			//				return R.image.symbols.flame_fill()!
			//			case .nextAiringEpisode:
			//				return R.image.symbols.tv_arrowshape_turn_up_right_fill()!
			//			case .nextEpisodeToWatch:
		//				return R.image.symbols.tv_eye_fill()!
		case .date:
			return R.image.symbols.calendar()!
		case .rating:
			return R.image.symbols.star_fill()!
		case .myRating:
			return R.image.symbols.person_crop_circle_fill_badge_star()!
		}
	}

	/// An array containing all library sort type string value and its equivalent raw value.
	static var alertControllerItems: [(String, KKLibrary.SortType, UIImage)] {
		var items = [(String, KKLibrary.SortType, UIImage)]()
		for sortType in KKLibrary.SortType.all {
			items.append((sortType.stringValue, sortType, sortType.imageValue))
		}
		return items
	}

	/// An array containing all library sort type string value and its equivalent raw value.
	var subAlertControllerItems: [(String, KKLibrary.SortType.Options, UIImage)] {
		var items = [(String, KKLibrary.SortType.Options, UIImage)]()
		for option in self.optionValue {
			items.append((option.stringValue, option, option.imageValue))
		}
		return items
	}
}
