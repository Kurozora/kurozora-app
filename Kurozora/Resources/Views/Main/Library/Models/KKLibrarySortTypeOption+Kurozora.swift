//
//  KKLibrarySortTypeOption+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension KKLibrary.SortType.Option {
	/// The image value of a sort type option.
	var imageValue: UIImage {
		switch self {
		case .none:
			return UIImage(systemName: "line.3.horizontal.decrease.circle.fill")!
		case .ascending:
			return UIImage(systemName: "line.3.horizontal.decrease")!
		case .descending:
			return R.image.symbols.line3HorizontalIncrease()!
		case .most:
			return UIImage(systemName: "chart.line.uptrend.xyaxis")!
		case .least:
			return UIImage(systemName: "chart.line.downtrend.xyaxis")!
		case .newest:
			return R.image.symbols.calendarBadgeArrowshapeTurnUpRight()!
		case .oldest:
			return R.image.symbols.calendarBadgeArrowshapeTurnUpLeft()!
		case .best:
			return UIImage(systemName: "hand.thumbsup.fill")!
		case .worst:
			return UIImage(systemName: "hand.thumbsdown.fill")!
		}
	}
}
