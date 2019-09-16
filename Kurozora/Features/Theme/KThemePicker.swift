//
//  KThemePicker.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

/**
	List of theme picker attributes.

	```
	case statusBarStyle = "UIStatusBarStyle"
	case visualEffect = "UIVisualEffectView"
	case backgroundColor = "Global.backgroundColor"
	case tintedBackgroundColor = "Global.tintedBackgroundColor"
	case barTintColor = "Global.barTintColor"
	```
	etc.
*/
enum KThemePicker: ThemeColorPicker {
	case statusBarStyle = "UIStatusBarStyle"
	case visualEffect = "UIVisualEffectView"

	// Global
	case backgroundColor = "Global.backgroundColor"
	case tintedBackgroundColor = "Global.tintedBackgroundColor"
	case barTintColor = "Global.barTintColor"
	case barTitleTextColor = "Global.barTitleTextColor"
	case blurBackgroundColor = "Global.blurBackgroundColor"
	case borderColor = "Global.borderColor"
	case textColor = "Global.textColor"
	case textFieldBackgroundColor = "Global.textFieldBackgroundColor"
	case textFieldTextColor = "Global.textFieldTextColor"
	case textFieldPlaceholderTextColor = "Global.textFieldPlaceholderTextColor"
	case tintColor = "Global.tintColor"
	case tintedButtonTextColor = "Global.tintedButtonTextColor"
	case separatorColor = "Global.separatorColor"
	case separatorColorLight = "Global.separatorColorLight"
	case subTextColor = "Global.subTextColor"

	// TableViewCell
	case tableViewCellBackgroundColor = "TableViewCell.backgroundColor"
	case tableViewCellTitleTextColor = "TableViewCell.titleTextColor"
	case tableViewCellSubTextColor = "TableViewCell.subTextColor"
	case tableViewCellChevronColor = "TableViewCell.chevronColor"
	case tableViewCellSelectedBackgroundColor = "TableViewCell.selectedBackgroundColor"
	case tableViewCellSelectedTitleTextColor = "TableViewCell.selectedTitleTextColor"
	case tableViewCellSelectedSubTextColor = "TableViewCell.selectedSubTextColor"
	case tableViewCellSelectedChevronColor = "TableViewCell.selectedChevronColor"
	case tableViewCellActionDefaultColor = "TableViewCell.actionDefaultColor"

	// Notifications
	case accentColor = "Notifications.accentColor"

	/// The string value of a theme picker attribute.
	var stringValue: String {
		switch self {
		case .statusBarStyle:
			return "UIStatusBarStyle"
		case .visualEffect:
			return "UIVisualEffectView"
		// Global
		case .backgroundColor:
			return "Global.backgroundColor"
		case .tintedBackgroundColor:
			return "Global.tintedBackgroundColor"
		case .barTintColor:
			return "Global.barTintColor"
		case .barTitleTextColor:
			return "Global.barTitleTextColor"
		case .blurBackgroundColor:
			return "Global.blurBackgroundColor"
		case .borderColor:
			return "Global.borderColor"
		case .textColor:
			return "Global.textColor"
		case .textFieldBackgroundColor:
			return "Global.textFieldBackgroundColor"
		case .textFieldTextColor:
			return "Global.textFieldTextColor"
		case .textFieldPlaceholderTextColor:
			return "Global.textFieldPlaceholderTextColor"
		case .tintColor:
			return "Global.tintColor"
		case .tintedButtonTextColor:
			return "Global.tintedButtonTextColor"
		case .separatorColor:
			return "Global.separatorColor"
		case .separatorColorLight:
			return "Global.separatorColorLight"
		case .subTextColor:
			return "Global.subTextColor"
		// TableViewCell
		case .tableViewCellBackgroundColor:
			return "TableViewCell.backgroundColor"
		case .tableViewCellTitleTextColor:
			return "TableViewCell.titleTextColor"
		case .tableViewCellSubTextColor:
			return "TableViewCell.subTextColor"
		case .tableViewCellChevronColor:
			return "TableViewCell.chevronColor"
		case .tableViewCellSelectedBackgroundColor:
			return "TableViewCell.selectedBackgroundColor"
		case .tableViewCellSelectedTitleTextColor:
			return "TableViewCell.selectedTitleTextColor"
		case .tableViewCellSelectedSubTextColor:
			return "TableViewCell.selectedSubTextColor"
		case .tableViewCellSelectedChevronColor:
			return "TableViewCell.selectedChevronColor"
		case .tableViewCellActionDefaultColor:
			return "TableViewCell.actionDefaultColor"
		// Notifications
		case .accentColor:
			return "Notifications.accentColor"
		}
	}

	/// The color value of a theme picker attribute.
	var colorValue: UIColor {
		switch self {
		case .statusBarStyle:
			switch UIStatusBarStyle.fromString(self.stringValue) {
			case .lightContent:
				return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
			case .darkContent:
				return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
			default:
				return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
			}
		default:
			return ThemeManager.color(for: self.stringValue) ?? .kurozora
		}
	}
}
