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
			return UIImage(systemName: "line.horizontal.3.decrease.circle.fill")!
		case .alphabetically:
			return UIImage(systemName: "textformat.abc")!
//			case .popularity:
//				return UIImage(UIImage(systemName: "flame.fill")!
//			case .nextAiringEpisode:
//				return UIImage(named: "tv.arrowshape.turn.up.forward.fill")!
//			case .nextEpisodeToWatch:
//				return UIImage(named: "tv.eye.fill")!
		case .date:
			return UIImage(systemName: "calendar")!
		case .rating:
			return UIImage(systemName: "star.fill")!
		case .myRating:
			return UIImage(named: "Symbols/person.crop.circle.fill.badge.star")!
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
