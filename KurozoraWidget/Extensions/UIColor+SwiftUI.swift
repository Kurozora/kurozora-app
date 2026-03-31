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
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
		guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil) else {
			return .white
		}

		@inline(__always)
		func linearize(_ c: CGFloat) -> CGFloat {
			let c = min(max(c, 0), 1)
			return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
		}

		let luminance = 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
		return luminance > 0.5 ? .black : .white
	}
}
