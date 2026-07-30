//
//  KotodamaKey.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

enum KotodamaKey: Hashable {
	// MARK: - Cases
	/// A key that types a letter.
	case letter(Swift.Character)

	/// A key that submits the typed letters.
	case submit

	/// A key that removes the last typed letter.
	case delete

	// MARK: - Properties
	/// The rows of the keyboard, from top to bottom.
	static var rows: [[KotodamaKey]] {
		return [
			"QWERTYUIOP".map { .letter($0) },
			"ASDFGHJKL".map { .letter($0) },
			"ZXCVBNM".map { .letter($0) },
			[.delete, .submit]
		]
	}

	/// A Boolean value indicating whether the key types a letter.
	var isLetter: Bool {
		switch self {
		case .letter:
			return true
		case .submit, .delete:
			return false
		}
	}

	/// The label read out for the key.
	var accessibilityLabel: String {
		switch self {
		case .letter(let letter):
			return String(letter)
		case .submit:
			return L10n.kotodamaSubmitGuess
		case .delete:
			return L10n.kotodamaDeleteLetter
		}
	}

	/// The width a letter key grows towards.
	static let maximumLetterWidth: CGFloat = 40

	/// The height of every key.
	static let height: CGFloat = 44

	/// The gap between keys, and between rows of keys.
	static let spacing: CGFloat = 4

}
