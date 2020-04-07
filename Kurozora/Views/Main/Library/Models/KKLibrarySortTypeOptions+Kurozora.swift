//
//  KKLibrarySortTypeOptions+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension KKLibrary.SortType.Options {
	/// The image value of a sort type option.
	var imageValue: UIImage {
		switch self {
		case .none:
			return R.image.symbols.line_horizontal_3_decrease_circle_fill()!
		case .ascending:
			return R.image.symbols.arrow_up_line_horizontal_3_decrease()!
		case .descending:
			return R.image.symbols.arrow_down_line_horizontal_3_increase()!
		case .newest:
			return R.image.symbols.calendar_badge_arrowshape_turn_up_right()!
		case .oldest:
			return R.image.symbols.calendar_badge_arrowshape_turn_up_left()!
		case .best:
			return R.image.symbols.hand_thumbsup_fill()!
		case .worst:
			return R.image.symbols.hand_thumbsdown_fill()!
		}
	}
}
