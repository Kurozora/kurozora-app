//
//  ReviewRecommendation+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension ReviewRecommendation {
	// MARK: - Properties
	/// The localized name of the recommendation.
	var localizedName: String {
		switch self {
		case .recommended:
			return L10n.reviewRecommended
		case .mixedFeelings:
			return L10n.reviewMixedFeelings
		case .notRecommended:
			return L10n.reviewNotRecommended
		}
	}
}
