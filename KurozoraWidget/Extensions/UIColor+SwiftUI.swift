//
//  UIColor+SwiftUI.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 07/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import SwiftUI

extension UIColor {
	/// Converts `UIColor` to `Color`.
	var color: Color {
		return Color(uiColor: self)
	}
}

extension Color {
	func luminance() -> Double {
		// Convert SwiftUI Color to UIColor
		let uiColor = UIColor(self)

		// Extract RGB values
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)

		// Compute luminance.
		return 0.2126 * Double(red) + 0.7152 * Double(green) + 0.0722 * Double(blue)
	}

	func isLight() -> Bool {
		return self.luminance() > 0.5
	}

	func adaptedTextColor() -> Color {
		return self.isLight() ? Color.black : Color.white
	}
}
