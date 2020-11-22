//
//  BasicTabBarItemContentView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class BasicTabBarItemContentView: ESTabBarItemContentView {
	// MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
		self.sharedInit()
    }

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.sharedInit()
	}

	// MARK: - Function
	/// The shared settings used to initialize the tab bar item content view.
	fileprivate func sharedInit() {
		ESTabBar.appearance().theme_barTintColor = KThemePicker.barTintColor.rawValue

		updateTabBarItemStyle()

		NotificationCenter.default.addObserver(self, selector: #selector(updateTabBarItemStyle), name: .ThemeUpdateNotification, object: nil
		)
	}

	/// Applies the default tab bar item style to the tab bar items.
	@objc fileprivate func updateTabBarItemStyle() {
		textColor = KThemePicker.subTextColor.colorValue
		highlightTextColor = KThemePicker.tintColor.colorValue
		iconColor = KThemePicker.subTextColor.colorValue
		highlightIconColor = KThemePicker.tintColor.colorValue
	}
}
