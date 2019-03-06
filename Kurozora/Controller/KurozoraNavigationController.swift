//
//  KurozoraNavigationController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import SwiftTheme

class KurozoraNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar
		self.navigationBar.isTranslucent = true
        self.navigationBar.barStyle = .black
		self.navigationBar.theme_barTintColor = "Global.barTintColor"
		self.navigationBar.backgroundColor = .clear

        // Navigation item
		self.navigationBar.theme_tintColor = "Global.tintColor"

        // Navigation Title
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

//extension UINavigationController {
//    open override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//}
