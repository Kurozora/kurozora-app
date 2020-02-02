//
//  BasicTabBarItemContentView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import SwiftTheme

class BasicTabBarItemContentView: ESTabBarItemContentView {
    override init(frame: CGRect) {
        super.init(frame: frame)
		ESTabBar.appearance().theme_barTintColor = KThemePicker.barTintColor.rawValue

		updateTabBarItemStyle()

		NotificationCenter.default.addObserver(self, selector: #selector(updateTabBarItemStyle), name: Notification.Name(rawValue: ThemeUpdateNotification), object: nil
		)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	// MARK: - Function
	@objc fileprivate func updateTabBarItemStyle() {
		textColor = KThemePicker.subTextColor.colorValue
		highlightTextColor = KThemePicker.tintColor.colorValue
		iconColor = KThemePicker.subTextColor.colorValue
		highlightIconColor = KThemePicker.tintColor.colorValue
	}
}
