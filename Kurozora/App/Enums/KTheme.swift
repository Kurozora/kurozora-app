//
//  KTheme.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/// The set of available default theme types.
enum KTheme {
	// MARK: - Cases
	case kurozora
	case day
	case night
	case grass
	case sky
	case sakura
	case other(_: AppTheme)

	// MARK: - Initializers
	/// Creates a new instance with the specified raw value.
	///
	/// If there is no value of the type that corresponds with the specified raw value, this initializer returns nil.
	///
	/// - Parameter rawValue: The raw value to use for the new instance.
	init?(rawValue: Int) {
		switch rawValue {
		case 0:
			self = .kurozora
		case 1:
			self = .day
		case 2:
			self = .night
		case 3:
			self = .grass
		case 4:
			self = .sky
		case 5:
			self = .sakura
		default:
			return nil
		}
	}

	// MARK: - Properties
	/// The default themes of Kurozora.
	static let defaultCases: [KTheme] = [.kurozora, .day, .night, .grass, .sky, .sakura]

	/// The string value of the default theme type.
	var stringValue: String {
		switch self {
		case .kurozora:
			return "Kurozora"
		case .day:
			return "Day"
		case .night:
			return "Night"
		case .grass:
			return "Grass"
		case .sky:
			return "Sky"
		case .sakura:
			return "Sakura"
		case .other(let theme):
			return theme.attributes.name
		}
	}

	/// The description value of the default theme type.
	var descriptionValue: String {
		switch self {
		case .kurozora:
			return Trans.defaultThemeDescription
		case .day:
			return Trans.dayThemeDescription
		case .night:
			return Trans.nightThemeDescription
		case .grass:
			return Trans.grassThemeDescription
		case .sky:
			return Trans.skyThemeDescription
		case .sakura:
			return Trans.sakuraThemeDescription
		case .other(let theme):
			let downloadCount = theme.attributes.downloadCount
			switch downloadCount {
			case 0:
				return Trans.new
			case 1:
				return "\(downloadCount) Download"
			default:
				return "\(downloadCount.kkFormatted) Downloads"
			}
		}
	}

	/// The color value of the default theme type.
	var colorValue: UIColor {
		switch self {
		case .kurozora:
			return #colorLiteral(red: 0.2078431373, green: 0.2274509804, blue: 0.3137254902, alpha: 1)
		case .day:
			return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		case .night:
			return #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
		case .grass:
			return #colorLiteral(red: 0.8980392157, green: 0.937254902, blue: 0.6745098039, alpha: 1)
		case .sky:
			return #colorLiteral(red: 0.7921568627, green: 0.9411764706, blue: 1, alpha: 1)
		case .sakura:
			return #colorLiteral(red: 1, green: 0.862745098, blue: 0.8901960784, alpha: 1)
		case .other:
			return .clear
		}
	}

	/// The image values of the default theme type.
	var imageValues: [UIImage] {
		switch self {
		case .kurozora:
			return [#imageLiteral(resourceName: "Themes/Default/Screenshot_1"), #imageLiteral(resourceName: "Themes/Default/Screenshot_2"), #imageLiteral(resourceName: "Themes/Default/Screenshot_3")]
		case .day:
			return [#imageLiteral(resourceName: "Themes/Day/Screenshot_1"), #imageLiteral(resourceName: "Themes/Day/Screenshot_2"), #imageLiteral(resourceName: "Themes/Day/Screenshot_3")]
		case .night:
			return [#imageLiteral(resourceName: "Themes/Night/Screenshot_1"), #imageLiteral(resourceName: "Themes/Night/Screenshot_2"), #imageLiteral(resourceName: "Themes/Night/Screenshot_3")]
		case .grass:
			return [#imageLiteral(resourceName: "Themes/Grass/Screenshot_1"), #imageLiteral(resourceName: "Themes/Grass/Screenshot_2"), #imageLiteral(resourceName: "Themes/Grass/Screenshot_3")]
		case .sky:
			return [#imageLiteral(resourceName: "Themes/Sky/Screenshot_1"), #imageLiteral(resourceName: "Themes/Sky/Screenshot_2"), #imageLiteral(resourceName: "Themes/Sky/Screenshot_3")]
		case .sakura:
			return [#imageLiteral(resourceName: "Themes/Sakura/Screenshot_1"), #imageLiteral(resourceName: "Themes/Sakura/Screenshot_2"), #imageLiteral(resourceName: "Themes/Sakura/Screenshot_3")]
		case .other:
			return []
		}
	}

	// MARK: - Functions
	/// Switches to the theme respective to the default theme type.
	func switchToTheme() {
		switch self {
		case .kurozora:
			KThemeStyle.switchTo(style: .default)
		case .day:
			KThemeStyle.switchTo(style: .day)
		case .night:
			KThemeStyle.switchTo(style: .night)
		case .grass:
			KThemeStyle.switchTo(style: .grass)
		case .sky:
			KThemeStyle.switchTo(style: .sky)
		case .sakura:
			KThemeStyle.switchTo(style: .sakura)
		case .other(let appTheme):
			KThemeStyle.switchTo(appTheme: appTheme)
		}
	}

	/// Checks and returns if the given string is equal to the default theme type.
	///
	/// - Returns: true if the given string is equal to the default theme type.
	func isEqual(_ theme: String) -> Bool {
		switch self {
		case .night:
			return theme == self.stringValue || theme == "Black"
		default:
			return theme == self.stringValue
		}
	}
}
