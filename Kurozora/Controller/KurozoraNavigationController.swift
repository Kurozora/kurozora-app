//
//  KurozoraNavigationController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class KurozoraNavigationController: UINavigationController {
	var statusBarStyle: UIStatusBarStyle {
		guard let statusBarStyleString = ThemeManager.value(for: "UIStatusBarStyle") as? String else { return .default }
		let statusBarStyle = UIStatusBarStyle.fromString(statusBarStyleString)

		return statusBarStyle
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return statusBarStyle
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.navigationBar.isTranslucent = true
        self.navigationBar.barStyle = .black
		self.navigationBar.theme_tintColor = "Global.tintColor"
		self.navigationBar.theme_barTintColor = "Global.barTintColor"
		self.navigationBar.backgroundColor = .clear
		self.navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker(keyPath: "Global.barTitleTextColor") { value -> [NSAttributedString.Key : AnyObject]? in
			guard let rgba = value as? String else {
				return nil
			}

			let color = UIColor(rgba: rgba)
			let shadow = NSShadow()
			shadow.shadowOffset = CGSize.zero
			let titleTextAttributes = [
				NSAttributedString.Key.foregroundColor: color,
				NSAttributedString.Key.shadow: shadow
			]

			return titleTextAttributes
		}

        if #available(iOS 11.0, *) {
            self.navigationBar.prefersLargeTitles = true
			self.navigationBar.theme_largeTitleTextAttributes = ThemeDictionaryPicker(keyPath: "Global.barTitleTextColor") { value -> [NSAttributedString.Key : AnyObject]? in
				guard let rgba = value as? String else {
					return nil
				}

				let color = UIColor(rgba: rgba)
				let shadow = NSShadow()
				shadow.shadowOffset = CGSize.zero
				let titleTextAttributes = [
					NSAttributedString.Key.foregroundColor: color,
					NSAttributedString.Key.shadow: shadow
				]

				return titleTextAttributes
			}
        }
    }
}
