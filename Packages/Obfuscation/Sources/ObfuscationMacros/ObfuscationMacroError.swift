//
//  ObfuscationMacroError.swift
//  Obfuscation
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

/// An error raised while expanding an obfuscation macro.
enum ObfuscationMacroError: Error, CustomStringConvertible {
	/// The macro was given something other than a string literal.
	case expectedStringLiteral

	// MARK: - Properties
	var description: String {
		switch self {
		case .expectedStringLiteral:
			return "#obfuscated requires a string literal without interpolation, since the string is enciphered while building."
		}
	}
}
