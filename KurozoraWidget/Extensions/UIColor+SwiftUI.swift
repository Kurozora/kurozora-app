//
//  UIColor+SwiftUI.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 07/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import SwiftUI
import UIKit

extension UIColor {
	/// Converts `UIColor` to `Color`.
	var color: Color {
		return Color(uiColor: self)
	}
}

extension Color {
	// MARK: - font colors
	/// This color is either black or white, whichever is more accessible when viewed against the current color.
	var accessibleFontColor: Color {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil)
		return self.isLightColor(red: red, green: green, blue: blue) ? .black : .white
	}

	/// Determine whether the given red, green, and blue values represent a light color.
	///
	/// - Parameters:
	///    - red: The red value.
	///    - green: The green value.
	///    - blue: The blue value.
	///
	/// - Returns: `true` if the color is light, `false` otherwise.
	private func isLightColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> Bool {
		let lightRed = red > 0.65
		let lightGreen = green > 0.65
		let lightBlue = blue > 0.65

		let lightness = [lightRed, lightGreen, lightBlue].reduce(0) { $1 ? $0 + 1 : $0 }
		return lightness >= 2
	}
}
