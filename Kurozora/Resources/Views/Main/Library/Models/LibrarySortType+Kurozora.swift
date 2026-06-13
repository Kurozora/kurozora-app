//
//  LibrarySortType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension LibrarySortType {
	/// The image value of a sort type.
	var imageValue: UIImage {
		switch self {
		case .none:
			return UIImage(systemName: "line.3.horizontal.decrease.circle.fill")!
		case .alphabetically:
			return UIImage(systemName: "textformat.abc")!
		case .popularity:
			return UIImage(systemName: "flame.fill")!
//		case .nextAiringEpisode:
//			return .Symbols.arrowshapeTurnUpForwardTvFill
//		case .nextEpisodeToWatch:
//			return .Symbols.eyeTvFill
		case .date:
			return UIImage(systemName: "calendar")!
		case .rating:
			return UIImage(systemName: "star.fill")!
		case .myRating:
			return .Symbols.personCropCircleFillBadgeStar
		}
	}
}
