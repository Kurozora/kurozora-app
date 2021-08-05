//
//  DefaultTheme.swift
//  DefaultTheme
//
//  Created by Khoren Katklian on 04/08/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

/**
	The list of available default theme types.
*/
enum DefaultTheme: Int, CaseIterable {
	// MARK: - Cases
	case `default` = 0
	case day
	case night
	case grass
	case sky
	case sakura

	// MARK: - Properties
	/// The string value of the default theme type.
	var stringValue: String {
		switch self {
		case .default:
			return "Default"
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
		}
	}

	/// The description value of the default theme type.
	var descriptionValue: String {
		switch self {
		case .default:
			return "The official Kurozora theme."
		case .day:
			return "Rise and shine."
		case .night:
			return "Easy on the eyes."
		case .grass:
			return "Get off my lawn!"
		case .sky:
			return "Cloudless."
		case .sakura:
			return "In full bloom."
		}
	}

	/// The color value of the default theme type.
	var colorValue: UIColor {
		switch self {
		case .default:
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
		}
	}

	/// The image values of the default theme type.
	var imageValues: [UIImage] {
		switch self {
		case .default:
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
		}
	}

	// MARK: - Functions
	/// Switches to the theme respective to the default theme type.
	func switchToTheme() {
		switch self {
		case .default:
			KThemeStyle.switchTo(.default)
		case .day:
			KThemeStyle.switchTo(.day)
		case .night:
			KThemeStyle.switchTo(.night)
		case .grass:
			KThemeStyle.switchTo(.grass)
		case .sky:
			KThemeStyle.switchTo(.sky)
		case .sakura:
			KThemeStyle.switchTo(.sakura)
		}
	}

	/**
		Checks and returns if the given string is equal to the default theme type.

		- Returns: true if the given string is equal to the default theme type.
	*/
	func isEqual(_ theme: String) -> Bool {
		switch self {
		case .night:
			return theme == self.stringValue || theme == "Black"
		default:
			return theme == self.stringValue
		}
	}
}
