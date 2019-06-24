//
//  KNavigationController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftTheme

class KNavigationController: UINavigationController {
	private var statusBarStyle: UIStatusBarStyle {
		guard let statusBarStyleString = ThemeManager.value(for: "UIStatusBarStyle") as? String else { return .default }
		let statusBarStyle = UIStatusBarStyle.fromString(statusBarStyleString)

		return statusBarStyle
	}
	private var shadowImageView: UIImageView?

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return statusBarStyle
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(updateNormalStyle), name: updateNormalLargeTitlesNotification, object: nil)

		toggleStyle(.normal)
    }

	@objc func updateNormalStyle() {
		toggleStyle(.normal)
	}

	func toggleStyle(_ style: KNavigationStyle) {
		self.navigationBar.isTranslucent = true

		switch style {
		case .normal:
			self.navigationBar.barStyle = .default
			self.navigationBar.backgroundColor = .clear
			self.navigationBar.theme_tintColor = KThemePicker.tintColor.rawValue
			self.navigationBar.theme_barTintColor = KThemePicker.barTintColor.rawValue

			self.navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker(keyPath: KThemePicker.barTitleTextColor.stringValue()) { value -> [NSAttributedString.Key : AnyObject]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}

			if #available(iOS 11.0, *) {
				self.navigationBar.prefersLargeTitles = UserSettings.largeTitles
				self.navigationBar.theme_largeTitleTextAttributes = ThemeDictionaryPicker(keyPath: KThemePicker.barTitleTextColor.stringValue()) { value -> [NSAttributedString.Key : AnyObject]? in
					guard let rgba = value as? String else { return nil }
					let color = UIColor(rgba: rgba)
					let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

					return titleTextAttributes
				}
			}
		case .blurred:
			// TODO: - Implement a better blurry navigation bar
			self.navigationBar.barStyle = .black
			self.navigationBar.backgroundColor = .clear
			self.navigationBar.tintColor = nil
			self.navigationBar.barTintColor = nil
		}
	}
}
