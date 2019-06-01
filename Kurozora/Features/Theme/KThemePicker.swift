//
//  KThemePicker.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation
import SwiftTheme

enum KThemePicker: ThemeColorPicker {
	// Global
	case backgroundColor = "Global.backgroundColor"
	case tintedBackgroundColor = "Global.tintedBackgroundColor"
	case barTintColor = "Global.barTintColor"
	case barTitleTextColor = "Global.barTitleTextColor"
	case textColor = "Global.textColor"
	case textFieldBackgroundColor = "Global.textFieldBackgroundColor"
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

	func stringValue() -> String {
		switch self {
		// Global
		case .backgroundColor:
			return "Global.backgroundColor"
		case .tintedBackgroundColor:
			return "Global.tintedBackgroundColor"
		case .barTintColor:
			return "Global.barTintColor"
		case .barTitleTextColor:
			return "Global.barTitleTextColor"
		case .textColor:
			return "Global.textColor"
		case .textFieldBackgroundColor:
			return "Global.textFieldBackgroundColor"
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

	func colorValue() -> UIColor {
		return ThemeManager.color(for: self.stringValue()) ?? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
	}
}
