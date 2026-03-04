//
//  FeedMessageEditorLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// Defines the layout variant for the feed message text editor.
enum FeedMessageEditorLayout: Int {
	/// Indicates a standard new message.
	case standard = 0

	/// Indicates the layout of a reply message.
	case reply = 1

	/// Indicates the layout of a re-share message.
	case reShare = 2
}
