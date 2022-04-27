//
//  KWhatsNewViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import WhatsNew

class KWhatsNewViewController: WhatsNewViewController {
	// MARK: - Initializers
	/// Initialize an instance of `WhatsNewViewController` with the given details.
	///
	/// - Parameters:
	///    - titleText: Text of the top title.
	///    - buttonText: Text of the bottom button that dismisses the view controller.
	///    - items: Items presented on the view controller.
	required init(titleText: String, buttonText: String, items: [WhatsNewItem]) {
		super.init(items: items)
		self.titleText = titleText
		self.buttonText = buttonText
		self.sharedInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the view controller.
	func sharedInit() {
		NotificationCenter.default.addObserver(self, selector: #selector(configureView), name: .ThemeUpdateNotification, object: nil)
		self.configureView()
	}

	/// Configures the view with the predefined settings.
	@objc func configureView() {
		self.titleColor = KThemePicker.textColor.colorValue
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.itemTitleColor = KThemePicker.textColor.colorValue
		self.itemSubtitleColor = KThemePicker.subTextColor.colorValue
		self.buttonTextColor = KThemePicker.tintedButtonTextColor.colorValue
		self.buttonBackgroundColor = KThemePicker.tintColor.colorValue
	}
}
