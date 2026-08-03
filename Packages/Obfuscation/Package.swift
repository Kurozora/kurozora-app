// swift-tools-version: 5.9
//
//  Package.swift
//  Obfuscation
//
//  Created by Khoren Katklian on 03/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CompilerPluginSupport
import PackageDescription

let package = Package(
	name: "Obfuscation",
	platforms: [
		.iOS(.v15),
		.macOS(.v12),
		.watchOS(.v8),
	],
	products: [
		.library(name: "Obfuscation", targets: ["Obfuscation"]),
	],
	dependencies: [
		.package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0" ..< "700.0.0"),
	],
	targets: [
		.macro(
			name: "ObfuscationMacros",
			dependencies: [
				.product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
				.product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
				.product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
			]
		),
		.target(name: "Obfuscation", dependencies: ["ObfuscationMacros"]),
		.testTarget(name: "ObfuscationTests", dependencies: ["Obfuscation"]),
	]
)
