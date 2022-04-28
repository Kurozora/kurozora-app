//
//  SubscriptionTier.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

/// The set of available  subscription tier types.
public enum SubscriptionTier: Int, Comparable {
	// MARK: - Cases
	/// Indicating no subscription tier.
	case none = 0

	/// Indicating the 1 month subscription tier type.
	case plus1Month = 1

	/// Indicating the 6 months subscription tier type.
	case plus6Months = 2

	/// Indicating the 12 months subscription tier type.
	case plus12Months = 3

	// MARK: - Functions
	public static func < (lhs: Self, rhs: Self) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
}
