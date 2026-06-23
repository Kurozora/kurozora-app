//
//  CrossfadeDuration.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The list of available crossfade durations.
enum CrossfadeDuration: Int, CaseIterable {
	// MARK: - Cases
	case one = 1
	case two
	case three
	case four
	case five
	case six
	case seven
	case eight
	case nine
	case ten
	case eleven
	case twelve

	// MARK: - Properties
	/// The default crossfade duration.
	static let `default`: CrossfadeDuration = .four

	/// The shortest selectable duration.
	static var minimumSeconds: Int {
		return self.allCases.map(\.rawValue).min() ?? 1
	}

	/// The longest selectable duration.
	static var maximumSeconds: Int {
		return self.allCases.map(\.rawValue).max() ?? 12
	}
}
