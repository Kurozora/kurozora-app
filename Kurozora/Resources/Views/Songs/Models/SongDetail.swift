//
//  SongDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

struct SongDetail { }

// MARK: - Ratings
extension SongDetail {
	/// List of available song rating types.
	enum Rating: Int, CaseIterable {
		case average = 0
		case sentiment
		case bar

		// MARK: - Properties
		/// The cell identifier string of a song rating section.
		var identifierString: String {
			switch self {
			case .average:
				return R.reuseIdentifier.ratingCollectionViewCell.identifier
			case .sentiment:
				return R.reuseIdentifier.ratingSentimentCollectionViewCell.identifier
			case .bar:
				return R.reuseIdentifier.ratingBarCollectionViewCell.identifier
			}
		}
	}
}

// MARK: - Rating & Review
extension SongDetail {
	/// List of available song rate & review types.
	enum RateAndReview: Int, CaseIterable {
		case tapToRate = 0
		case writeAReview

		// MARK: - Properties
		/// The cell identifier string of a song rate & review section.
		var identifierString: String {
			switch self {
			case .tapToRate:
				return R.reuseIdentifier.tapToRateCollectionViewCell.identifier
			case .writeAReview:
				return R.reuseIdentifier.writeAReviewCollectionViewCell.identifier
			}
		}
	}
}
