//
//  MentionTracker.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// Represents an active `@mention` context extracted from cursor position.
struct MentionContext {
	/// The range of `@query` in the text view's text.
	let range: NSRange
	/// The characters typed after `@` (may be empty when the user just types `@`).
	let query: String
}

/// Utility for tracking active `@mention` contexts in a `UITextView`.
struct MentionTracker {
	/// Returns the active mention context at the current cursor position, or `nil` if the cursor
	/// is not inside a `@mention` token.
	///
	/// This method walks backward from `selectedRange.location`. If `@` is found before any
	/// whitespace/newline (and `@` is at text start or preceded by whitespace), returns the context.
	static func activeMention(in textView: UITextView) -> MentionContext? {
		guard let text = textView.text as NSString?,
		      text.length > 0
		else {
			return nil
		}

		let cursorLocation = textView.selectedRange.location
		guard cursorLocation > 0, cursorLocation <= text.length else {
			return nil
		}

		// Walk backward from cursor to find '@'
		var searchIndex = cursorLocation - 1

		while searchIndex >= 0 {
			let character = text.character(at: searchIndex)
			guard let scalar = Unicode.Scalar(character) else {
				searchIndex -= 1
				continue
			}

			if scalar == Unicode.Scalar("@") {
				// Found '@' then verify it's at text start or preceded by whitespace
				if searchIndex == 0 {
					let mentionRange = NSRange(location: searchIndex, length: cursorLocation - searchIndex)
					let query = text.substring(with: NSRange(location: searchIndex + 1, length: cursorLocation - searchIndex - 1))
					return MentionContext(range: mentionRange, query: query)
				}

				if let precedingScalar = Unicode.Scalar(text.character(at: searchIndex - 1)),
				   CharacterSet.whitespacesAndNewlines.contains(precedingScalar)
				{
					let mentionRange = NSRange(location: searchIndex, length: cursorLocation - searchIndex)
					let query = text.substring(with: NSRange(location: searchIndex + 1, length: cursorLocation - searchIndex - 1))
					return MentionContext(range: mentionRange, query: query)
				}

				// '@' not preceded by whitespace, not a valid mention trigger
				return nil
			}

			// If we hit whitespace or newline before finding '@', no active mention
			if CharacterSet.whitespacesAndNewlines.contains(scalar) {
				return nil
			}

			searchIndex -= 1
		}

		return nil
	}
}
