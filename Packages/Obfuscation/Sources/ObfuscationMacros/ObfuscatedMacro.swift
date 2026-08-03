//
//  ObfuscatedMacro.swift
//  Obfuscation
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Expands `#obfuscated` into an expression that deciphers the literal at runtime.
public struct ObfuscatedMacro: ExpressionMacro {
	// MARK: - Functions
	public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
		guard node.arguments.count == 1,
			  let literal = node.arguments.first?.expression.as(StringLiteralExprSyntax.self),
			  let text = literal.representedLiteralValue else {
			throw ObfuscationMacroError.expectedStringLiteral
		}

		let salt = UInt64(node.positionAfterSkippingLeadingTrivia.utf8Offset)
		let seed = ObfuscationCipher.seed(for: text, salt: salt)
		let ciphertext = ObfuscationCipher.encipher(text, seed: seed)
		let bytes = ciphertext.map { self.hexadecimal($0, digits: 2) }.joined(separator: ", ")

		return """
			{ () -> String in
				var state: UInt64 = \(raw: self.hexadecimal(seed, digits: 16))
				var bytes: [UInt8] = []
				bytes.reserveCapacity(\(raw: ciphertext.count))

				for cipher in [\(raw: bytes)] as [UInt8] {
					var key: UInt8 = 0

					while key == 0 {
						state = state &* \(raw: self.hexadecimal(ObfuscationCipher.multiplier, digits: 16)) &+ \(raw: self.hexadecimal(ObfuscationCipher.increment, digits: 16))
						key = UInt8(truncatingIfNeeded: state >> \(raw: ObfuscationCipher.keyShift))
					}

					bytes.append(cipher ^ key)
				}

				return String(decoding: bytes, as: UTF8.self)
			}()
			"""
	}

	/// Formats a value as a fixed-width Swift hexadecimal literal.
	///
	/// - Parameters:
	///    - value: The value to format.
	///    - digits: How many digits to pad the value out to.
	///
	/// - Returns: The formatted literal.
	private static func hexadecimal(_ value: some BinaryInteger, digits: Int) -> String {
		let value = String(UInt64(value), radix: 16, uppercase: true)

		return "0x" + String(repeating: "0", count: max(digits - value.count, 0)) + value
	}
}
