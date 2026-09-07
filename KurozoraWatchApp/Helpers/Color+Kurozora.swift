//
//  Color+Kurozora.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 06/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

extension Color {
	/// The hex string of Kurozora's default tint, used until the iPhone pushes a theme.
	static let kurozoraHex = "#FF9300"

	/// Kurozora's default tint color.
	static let kurozora = Color(hex: Color.kurozoraHex) ?? .orange

	/// Creates a color from a hex string.
	///
	/// - Parameter hex: A hex string in `RGB`, `RRGGBB`, or `AARRGGBB` form, with an optional leading `#`.
	init?(hex: String) {
		var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)

		if sanitized.hasPrefix("#") {
			sanitized.removeFirst()
		}

		guard let value = UInt64(sanitized, radix: 16) else { return nil }

		let red: Double
		let green: Double
		let blue: Double
		let alpha: Double

		switch sanitized.count {
		case 3:
			red = Double((value >> 8) & 0xF) / 15
			green = Double((value >> 4) & 0xF) / 15
			blue = Double(value & 0xF) / 15
			alpha = 1
		case 6:
			red = Double((value >> 16) & 0xFF) / 255
			green = Double((value >> 8) & 0xFF) / 255
			blue = Double(value & 0xFF) / 255
			alpha = 1
		case 8:
			alpha = Double((value >> 24) & 0xFF) / 255
			red = Double((value >> 16) & 0xFF) / 255
			green = Double((value >> 8) & 0xFF) / 255
			blue = Double(value & 0xFF) / 255
		default:
			return nil
		}

		self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
	}
}
