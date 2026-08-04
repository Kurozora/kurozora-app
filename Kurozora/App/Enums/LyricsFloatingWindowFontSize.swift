//
//  LyricsFloatingWindowFontSize.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The font size of the text shown in the floating lyrics window.
enum LyricsFloatingWindowFontSize: Int, CaseIterable {
	// MARK: - Cases
	/// The text is shown at the standard size.
	case standard = 0

	/// The text is shown at a bigger size.
	case big

	// MARK: - Properties
	/// The default font size option.
	static let `default`: LyricsFloatingWindowFontSize = .standard

	/// The title of the option.
	var stringValue: String {
		switch self {
		case .standard:
			return L10n.fontSizeStandard
		case .big:
			return L10n.fontSizeBig
		}
	}
}
