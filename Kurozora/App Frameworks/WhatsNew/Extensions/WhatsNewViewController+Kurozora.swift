//
//  WhatsNewViewController+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import WhatsNew

extension WhatsNewViewController {
	// MARK: - Initializers
	/// Initialize an instance of `WhatsNewViewController` with the given details.
	///
	/// - Parameters:
	///    - titleText: Text of the top title.
	///    - buttonText: Text of the bottom button that dismisses the view controller.
	///    - items: Items presented on the view controller.
	convenience init(titleText: String, buttonText: String, items: [WhatsNewItem]) {
		self.init(items: items)
		self.titleText = titleText
		self.buttonText = buttonText
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the view controller.
	func sharedInit() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.configureView), name: .ThemeUpdateNotification, object: nil)
		self.configureView()
	}

	/// Configures the view with the predefined settings.
	@objc func configureView() {
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			self.titleColor = KThemePicker.textColor.colorValue
			self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
			self.itemTitleColor = KThemePicker.textColor.colorValue
			self.itemSubtitleColor = KThemePicker.subTextColor.colorValue
			self.buttonTextColor = KThemePicker.tintedButtonTextColor.colorValue
			self.buttonBackgroundColor = KThemePicker.tintColor.colorValue
		}
	}
}
