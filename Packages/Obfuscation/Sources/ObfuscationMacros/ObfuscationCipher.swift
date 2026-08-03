//
//  ObfuscationCipher.swift
//  Obfuscation
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

/// Enciphers a string by XOR-ing it against a keystream a seed reproduces.
struct ObfuscationCipher {
	// MARK: - Properties
	/// The multiplier of the linear congruential generator producing the keystream.
	static let multiplier: UInt64 = 0x5851_F42D_4C95_7F2D

	/// The increment of the linear congruential generator producing the keystream.
	static let increment: UInt64 = 0x1405_7B7E_F767_814F

	/// How far the generator's state is shifted before a key byte is taken from it.
	static let keyShift: UInt64 = 40

	// MARK: - Functions
	/// Derives the seed that produces a string's keystream.
	///
	/// - Parameters:
	///    - text: The string to derive a seed for.
	///    - salt: A value distinguishing this occurrence from an identical one elsewhere.
	///
	/// - Returns: A non-zero seed.
	static func seed(for text: String, salt: UInt64) -> UInt64 {
		var hash: UInt64 = 0xCBF2_9CE4_8422_2325

		for byte in text.utf8 {
			hash ^= UInt64(byte)
			hash = hash &* 0x0000_0100_0000_01B3
		}

		return self.mixed(hash ^ salt) | 1
	}

	/// Enciphers a string against the keystream its seed produces.
	///
	/// - Parameters:
	///    - text: The string to encipher.
	///    - seed: The seed whose keystream to encipher against.
	///
	/// - Returns: The enciphered UTF-8 bytes of the string.
	static func encipher(_ text: String, seed: UInt64) -> [UInt8] {
		var state = seed

		return text.utf8.map { byte in
			var key: UInt8 = 0

			while key == 0 {
				state = state &* self.multiplier &+ self.increment
				key = UInt8(truncatingIfNeeded: state >> self.keyShift)
			}

			return byte ^ key
		}
	}

	/// Scrambles a value so neighbouring inputs land far apart.
	///
	/// - Parameter value: The value to scramble.
	///
	/// - Returns: The scrambled value.
	private static func mixed(_ value: UInt64) -> UInt64 {
		var result = value &+ 0x9E37_79B9_7F4A_7C15
		result = (result ^ (result >> 30)) &* 0xBF58_476D_1CE4_E5B9
		result = (result ^ (result >> 27)) &* 0x94D0_49BB_1331_11EB

		return result ^ (result >> 31)
	}
}
