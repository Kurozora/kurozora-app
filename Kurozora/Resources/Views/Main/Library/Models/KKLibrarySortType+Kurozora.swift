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
			return UIImage(systemName: "line.3.horizontal.decrease.circle.fill")!
		case .alphabetically:
			return UIImage(systemName: "textformat.abc")!
		case .popularity:
			return UIImage(systemName: "flame.fill")!
//			case .nextAiringEpisode:
//				return UIImage(named: "arrowshape.turn.up.forward.tv.fill")!
//			case .nextEpisodeToWatch:
//				return UIImage(named: "eye.tv.fill")!
		case .date:
			return UIImage(systemName: "calendar")!
		case .rating:
			return UIImage(systemName: "star.fill")!
		case .myRating:
			return UIImage(named: "Symbols/person.crop.circle.fill.badge.star")!
		}
	}
}
