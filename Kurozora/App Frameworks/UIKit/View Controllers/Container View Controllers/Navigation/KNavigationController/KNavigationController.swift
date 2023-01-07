//
//  KNavigationController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class KNavigationController: UINavigationController {
	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(updateTheme(_:)), name: .ThemeUpdateNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updatePrefersLargeTitles(_:)), name: .KSPrefersLargeTitlesDidChange, object: nil)

		self.sharedInit()
    }

	// MARK: - Functions
	/// The shared settings used to initialize tab bar view.
	private func sharedInit() {
		// Configure theme
		self.configureNavigationBarStyle()
		self.setupToolbarStyle()
	}

	/// Used to update the large title preference.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func updatePrefersLargeTitles(_ notification: NSNotification) {
		self.navigationBar.prefersLargeTitles = UserSettings.largeTitlesEnabled
	}

	/// Used to update the theme of the view.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func updateTheme(_ notification: NSNotification) {
		self.configureNavigationBarStyle()
	}

	/// Setup navigation bar style with the currently used theme.
	func configureNavigationBarStyle() {
		self.navigationBar.isTranslucent = true
		self.navigationBar.backgroundColor = .clear
		self.navigationBar.barStyle = .default
		self.navigationBar.theme_tintColor = KThemePicker.tintColor.rawValue
		if #available(macCatalyst 16.0, *) {
			self.navigationBar.preferredBehavioralStyle = .pad
		}

		let appearance = UINavigationBarAppearance()
		appearance.theme_backgroundColor = KThemePicker.barTintColor.rawValue
		appearance.theme_titleTextAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.barTitleTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
			guard let rgba = value as? String else { return nil }
			let color = UIColor(rgba: rgba)
			let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

			return titleTextAttributes
		}
		appearance.theme_largeTitleTextAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.barTitleTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
			guard let rgba = value as? String else { return nil }
			let color = UIColor(rgba: rgba)
			let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

			return titleTextAttributes
		}

		self.navigationBar.theme_standardAppearance = ThemeNavigationBarAppearancePicker(appearances: appearance)
		self.navigationBar.theme_compactAppearance = ThemeNavigationBarAppearancePicker(appearances: appearance)
		self.navigationBar.prefersLargeTitles = UserSettings.largeTitlesEnabled
	}

	/// Setup toolbar style with the currently used theme.
	func setupToolbarStyle() {
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue
	}
}
