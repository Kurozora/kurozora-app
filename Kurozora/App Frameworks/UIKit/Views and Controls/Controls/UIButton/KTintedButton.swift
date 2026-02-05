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

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.springEnabled = false
			self.backgroundColor = nil
			self.setTitleColor(nil, for: .normal)
			self.theme_setTitleColor(nil, forState: .normal)

			let cornerRadius = self.layer.cornerRadius
			self.clipsToBounds = false
			self.layer.masksToBounds = false

			self.configuration = .prominentGlass()
			self.configuration?.background.cornerRadius = cornerRadius == .zero ? 10 : cornerRadius
		} else {
			self.theme_tintColor = KThemePicker.tintedButtonTextColor.rawValue
			self.theme_backgroundColor = KThemePicker.tintColor.rawValue
			self.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)

			self.layerCornerRadius = self.layerCornerRadius == .zero ? 10 : self.layerCornerRadius
		}
	}
}
