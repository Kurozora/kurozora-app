//
//  ObfuscatedMacroTests.swift
//  Obfuscation
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Obfuscation
import XCTest

/// Verifies the macro reconstructs the strings it enciphers.
final class ObfuscatedMacroTests: XCTestCase {
	// MARK: - Functions
	func testObfuscatedRestoresAnASCIIString() {
		XCTAssertEqual(#obfuscated("_displayCornerRadius"), "_displayCornerRadius")
	}

	func testObfuscatedRestoresAnEmptyString() {
		XCTAssertEqual(#obfuscated(""), "")
	}

	func testObfuscatedRestoresMultiByteCharacters() {
		XCTAssertEqual(#obfuscated("クロゾラ 🎬 مرحبا"), "クロゾラ 🎬 مرحبا")
	}

	func testObfuscatedRestoresEscapeSequences() {
		XCTAssertEqual(#obfuscated("tab\tnewline\nquote\"backslash\\"), "tab\tnewline\nquote\"backslash\\")
	}

	func testObfuscatedRestoresRepeatedLiteralsAtSeparateCallSites() {
		XCTAssertEqual(#obfuscated("repeated"), #obfuscated("repeated"))
	}
}
