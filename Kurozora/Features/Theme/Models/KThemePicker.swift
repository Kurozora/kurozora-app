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
	// MARK: - Cases
	case version = "Version"
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

	// MARK: - Properties
	/// The string value of a theme picker attribute.
	var stringValue: String {
		switch self {
		case .version:
			return "Version"
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
		case .visualEffect:
			switch KThemePicker.visualEffect.blurValue {
			case .dark:
				return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
			case .light, .extraLight:
				return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
			default:
				return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
			}
		default:
			return ThemeManager.color(for: self.stringValue) ?? .kurozora
		}
	}

	var cgColorPicker: ThemeCGColorPicker? {
		switch self {
		case .borderColor:
			return ThemeCGColorPicker(stringLiteral: KThemePicker.borderColor.stringValue)
		default: return nil
		}
	}

	/// Returns a UIBlurEffect.Style from the currently selected theme.
	var blurValue: UIBlurEffect.Style {
		guard let blurEffectStyleString = ThemeManager.value(for: KThemePicker.visualEffect.stringValue) as? String else { return .light }

		switch blurEffectStyleString {
		case "Dark":
			return .systemMaterialDark
		case "Light":
			return .systemMaterialLight
		case "Extralight":
			return .extraLight
		case "Prominent":
			return .prominent
		case "Regular":
			return .systemMaterial
		default:
			return .systemMaterial
		}
	}

	/// Returns a `UIStatusBarStyle` from the currently selected theme.
	var statusBarValue: UIStatusBarStyle {
		guard let statusBarStyleString = ThemeManager.value(for: KThemePicker.statusBarStyle.stringValue) as? String else { return .default }

		switch statusBarStyleString {
		case "LightContent":
			return .lightContent
		default:
			return .darkContent
		}
	}

	/// Returns the `UIUserInterfaceStyle` from the currently selected theme.
	var userInterfaceStyleValue: UIUserInterfaceStyle {
		guard let statusBarStyleString = ThemeManager.value(for: KThemePicker.statusBarStyle.stringValue) as? String else { return .unspecified }

		switch statusBarStyleString {
		case "LightContent":
			return .dark
		default:
			return .light
		}
	}

	// MARK: - Functions
	/**
		Returns a ThemeVisualEffectPicker from the currently selected theme.

		- Parameter vibrancyEnabled: Boolean indicating whether the visual effect is vibrant.

		- Returns: a ThemeVisualEffectPicker from the currently selected theme.
	*/
	func effectValue(vibrancyEnabled: Bool = false) -> ThemeVisualEffectPicker {
		return ThemeVisualEffectPicker(keyPath: KThemePicker.visualEffect.stringValue, vibrancyEnabled: vibrancyEnabled)
	}

	/**
		Return attributed string theme from the currently selected theme.

		- Parameter attributes: The attributes to merge with the theme color attribute.

		- Returns: attributed string theme from the currently selected theme.
	*/
	func attributedStringValue(attributes: [NSAttributedString.Key: Any] = [:]) -> ThemeStringAttributesPicker {
		return ThemeStringAttributesPicker(keyPath: self.stringValue) { value -> [NSAttributedString.Key: Any]? in
			guard let rgba = value as? String else { return nil }
			let color = UIColor(rgba: rgba)
			let themeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: color].merging(attributes, uniquingKeysWith: { current, _ -> Any in current })
			return themeAttributes
		}
	}
}
