//
//  WatchTheme.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 06/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Observation
import SwiftUI

/// The tint color mirrored from the theme selected on the paired iPhone.
@MainActor @Observable
final class WatchTheme {
	// MARK: - Keys
	private enum Keys {
		static let tintColor = "syncedThemeTintColor"
		static let tintedButtonTextColor = "syncedThemeTintedButtonTextColor"
	}

	// MARK: - Properties
	/// The hex string of the tint color last received from the iPhone.
	private(set) var tintHex: String

	/// The hex string of the tinted button text color last received from the iPhone.
	private(set) var tintedButtonTextHex: String

	/// The tint applied to titles and controls throughout the app.
	var tint: Color {
		return Color(hex: self.tintHex) ?? .kurozora
	}

	/// The foreground used on tinted buttons, mirroring `Global.tintedButtonTextColor`.
	var tintedButtonText: Color {
		return Color(hex: self.tintedButtonTextHex) ?? .white
	}

	// MARK: - Initializers
	init() {
		self.tintHex = UserDefaults.standard.string(forKey: Keys.tintColor) ?? Color.kurozoraHex
		self.tintedButtonTextHex = UserDefaults.standard.string(forKey: Keys.tintedButtonTextColor) ?? "#EEEEEE"
	}

	// MARK: - Functions
	/// Applies the tint color pushed from the iPhone and remembers it for the next launch.
	///
	/// - Parameter hex: The hex string of the theme's tint color.
	func applyTint(hex: String) {
		guard Color(hex: hex) != nil, hex != self.tintHex else { return }

		self.tintHex = hex
		UserDefaults.standard.set(hex, forKey: Keys.tintColor)
	}

	/// Applies the tinted button text color pushed from the iPhone.
	///
	/// - Parameter hex: The hex string of the theme's tinted button text color.
	func applyTintedButtonText(hex: String) {
		guard Color(hex: hex) != nil, hex != self.tintedButtonTextHex else { return }

		self.tintedButtonTextHex = hex
		UserDefaults.standard.set(hex, forKey: Keys.tintedButtonTextColor)
	}
}
