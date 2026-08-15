//
//  RatingCategory+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension RatingCategory {
	// MARK: - Properties
	/// The category's formatted score.
	var formattedScore: String {
		let score = self.attributes.score ?? RatingCategory.Attributes.maximumScore / 2.0
		return score.formatted(.number.precision(.fractionLength(1)))
	}
}

extension [RatingCategory] {
	// MARK: - Properties
	/// The weighted average of the scored categories on the five star scale.
	var weightedStarRating: Double {
		var weightedSum = 0.0
		var totalWeight = 0.0

		for ratingCategory in self {
			guard let score = ratingCategory.attributes.score else { continue }

			weightedSum += score * ratingCategory.attributes.weight
			totalWeight += ratingCategory.attributes.weight
		}

		guard totalWeight > 0 else { return 0.0 }

		let scale = RatingCategory.Attributes.maximumScore / 5.0

		return weightedSum / totalWeight / scale
	}

	/// The formatted weighted average on the five star scale.
	var formattedStarRating: String {
		return self.weightedStarRating.formatted(.number.precision(.fractionLength(0...1)))
	}
}
