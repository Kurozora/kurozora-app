//
//  Obfuscated.swift
//  Obfuscation
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

/// Reconstructs a string literal at runtime so its characters do not appear in the compiled binary.
///
///     let selector = NSSelectorFromString(#obfuscated("_displayCornerRadius"))
///
/// - Parameter value: A string literal.
///
/// - Returns: The literal's value.
@freestanding(expression)
public macro obfuscated(_ value: String) -> String = #externalMacro(module: "ObfuscationMacros", type: "ObfuscatedMacro")
