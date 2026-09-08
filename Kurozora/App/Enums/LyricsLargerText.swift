//
//  LyricsLargerText.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The text shown larger when a lyric line and its pronunciation both appear.
enum LyricsLargerText: Int, CaseIterable {
	// MARK: - Cases
	/// The lyric line is shown larger.
	case lyrics = 0

	/// The pronunciation is shown larger.
	case pronunciation

	// MARK: - Properties
	/// The default larger text option.
	static let `default`: LyricsLargerText = .lyrics
}
