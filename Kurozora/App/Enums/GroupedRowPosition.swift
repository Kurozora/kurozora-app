//
//  GroupedRowPosition.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import QuartzCore

/// Where a row sits within a grouped card.
enum GroupedRowPosition: nonisolated Equatable, nonisolated Hashable {
	// MARK: - Cases
	/// Indicates the row is the card's only one.
	case only

	/// Indicates the row opens the card.
	case first

	/// Indicates the row sits between two others.
	case middle

	/// Indicates the row closes the card.
	case last

	// MARK: - Properties
	/// The corners the row rounds.
	var maskedCorners: CACornerMask {
		switch self {
		case .only:
			return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		case .first:
			return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		case .middle:
			return []
		case .last:
			return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		}
	}

	// MARK: - Initializers
	/// Creates the position of a row at the given index.
	///
	/// - Parameters:
	///    - index: The position of the row.
	///    - count: The number of rows in the card.
	init(index: Int, count: Int) {
		if count <= 1 {
			self = .only
		} else if index == 0 {
			self = .first
		} else if index == count - 1 {
			self = .last
		} else {
			self = .middle
		}
	}
}
