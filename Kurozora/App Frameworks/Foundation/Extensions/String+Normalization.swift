//
//  String+Normalization.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

extension String {
	// MARK: - Properties
	/// Returns a normalized version of the string suitable for profanity checking.
	///
	/// Applies the following transformations in order:
	/// 1. Uppercases the entire string
	/// 2. Maps common leet speak substitutions to ASCII equivalents
	/// 3. Applies NFKC Unicode normalization to collapse homoglyphs (fullwidth, circled, etc.)
	/// 4. Strips non-ASCII-letter characters
	var normalizedForProfanityCheck: String {
		let uppercased = self.uppercased()

		// Leet speak substitutions
		let leetMapped = uppercased.map { character -> Character in
			switch character {
			case "0": return "O"
			case "1": return "I"
			case "3": return "E"
			case "4": return "A"
			case "5": return "S"
			case "7": return "T"
			case "@": return "A"
			case "$": return "S"
			case "!": return "I"
			case "8": return "B"
			default: return character
			}
		}

		// NFKC normalization to collapse Unicode homoglyphs
		let nfkcNormalized = String(leetMapped).precomposedStringWithCompatibilityMapping

		// Strip non-letter characters
		let filtered = nfkcNormalized.unicodeScalars.filter { CharacterSet.letters.contains($0) }
		return String(String.UnicodeScalarView(filtered))
	}
}
