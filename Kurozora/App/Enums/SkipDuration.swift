//
//  SkipDuration.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The list of available skip durations.
enum SkipDuration: Int, CaseIterable {
	// MARK: - Cases
	case three = 3
	case five = 5
	case ten = 10
	case fifteen = 15
	case thirty = 30

	// MARK: - Properties
	/// The default skip duration.
	static let `default`: SkipDuration = .three
}
