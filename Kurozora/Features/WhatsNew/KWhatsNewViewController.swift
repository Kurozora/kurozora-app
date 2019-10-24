//
//  KWhatsNewViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import WhatsNew
import SwiftTheme

class KWhatsNewViewController: WhatsNewViewController {
	// MARK: - Properties
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return KThemePicker.statusBarStyle.statusBarValue
	}

	// MARK: - Initializer
	required init(titleText: String, buttonText: String, items: [WhatsNewItem]) {
		super.init(items: items)
		self.titleText = titleText
		self.buttonText = buttonText
		self.titleColor = KThemePicker.textColor.colorValue
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.itemTitleColor = KThemePicker.textColor.colorValue
		self.itemSubtitleColor = KThemePicker.subTextColor.colorValue
		self.buttonTextColor = KThemePicker.tintedButtonTextColor.colorValue
		self.buttonBackgroundColor = KThemePicker.tintColor.colorValue
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
