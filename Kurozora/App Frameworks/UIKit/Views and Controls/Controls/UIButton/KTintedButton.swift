//
//  KTintedButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// A themed control that executes your custom code in response to user interactions.
///
/// `KTintedButton` provides themed buttons that match with the currently enabled theme.
class KTintedButton: KButton {
	override func sharedInit() {
		super.sharedInit()

		self.layerCornerRadius = self.layerCornerRadius == .zero ? 10 : self.layerCornerRadius
		self.theme_backgroundColor = KThemePicker.tintColor.rawValue
		self.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
	}
}
