//
//  LyricsFloatingWindowRows.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The number of lyric lines shown in the floating lyrics window.
enum LyricsFloatingWindowRows: Int, CaseIterable {
	// MARK: - Cases
	/// A single lyric line is shown.
	case one = 0

	/// Two lyric lines are shown.
	case two

	// MARK: - Properties
	/// The default rows option.
	static let `default`: LyricsFloatingWindowRows = .one

	/// The title of the option.
	var stringValue: String {
		switch self {
		case .one:
			return L10n.oneLine
		case .two:
			return L10n.twoLines
		}
	}
}
