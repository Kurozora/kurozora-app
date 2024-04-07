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
