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
	// MARK: - Properties
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return KThemePicker.statusBarStyle.statusBarValue
	}

	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(updateNormalStyle), name: .ThemeUpdateNotification, object: nil)
		toggleStyle(.normal)
		setupToolbarStyle()
    }

	// MARK: - Functions
	/// Updates the normal navigation bar style with the changed values.
	@objc func updateNormalStyle() {
		toggleStyle(.normal)
	}

	/**
		Toggles between navigation bar styles.

		- Parameter style: The KNavigationStyle to be used on the navigation bar.
	*/
	func toggleStyle(_ style: KNavigationStyle) {
		self.navigationBar.isTranslucent = true

		switch style {
		case .normal:
			if #available(iOS 13.0, macCatalyst 13.0, *) {
				let appearance = UINavigationBarAppearance()
				appearance.backgroundColor = KThemePicker.barTintColor.colorValue
				appearance.titleTextAttributes = [.foregroundColor: KThemePicker.barTitleTextColor.colorValue]
				appearance.largeTitleTextAttributes = [.foregroundColor: KThemePicker.barTitleTextColor.colorValue]

				self.navigationBar.standardAppearance = appearance
				self.navigationBar.compactAppearance = appearance
				self.navigationBar.scrollEdgeAppearance = appearance
			} else {
				self.navigationBar.theme_titleTextAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.barTitleTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
					guard let rgba = value as? String else { return nil }
					let color = UIColor(rgba: rgba)
					let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

					return titleTextAttributes
				}

				self.navigationBar.theme_largeTitleTextAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.barTitleTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
					guard let rgba = value as? String else { return nil }
					let color = UIColor(rgba: rgba)
					let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

					return titleTextAttributes
				}
			}

			self.navigationBar.backgroundColor = .clear
			self.navigationBar.barStyle = .default
			self.navigationBar.theme_tintColor = KThemePicker.tintColor.rawValue
			self.navigationBar.theme_barTintColor = KThemePicker.barTintColor.rawValue
			self.navigationBar.prefersLargeTitles = UserSettings.largeTitlesEnabled
		case .blurred:
			self.navigationBar.barStyle = .black
			self.navigationBar.backgroundColor = .clear
			self.navigationBar.tintColor = nil
			self.navigationBar.barTintColor = nil
		}
	}

	/// Setup toolbar style with the currently used theme.
	func setupToolbarStyle() {
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue
	}
}
