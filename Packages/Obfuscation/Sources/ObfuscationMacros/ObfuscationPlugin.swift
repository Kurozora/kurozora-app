//
//  ObfuscationPlugin.swift
//  Obfuscation
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ObfuscationPlugin: CompilerPlugin {
	// MARK: - Properties
	let providingMacros: [any Macro.Type] = [
		ObfuscatedMacro.self,
	]
}
