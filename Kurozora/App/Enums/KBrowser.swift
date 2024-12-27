//
//  KBrowser.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

enum KBrowser: Int, CaseIterable {
	// MARK: - Cases
	case kurozora = 0
	case safari
	case duckduckgo
	case firefox
	case firefoxfocus
	case googlechrome
	case brave
	case opera
	case dolphin

	// MARK: - Properties
	/// The string value of the browser.
	var stringValue: String {
		switch self {
		case .kurozora:
			return "In-app (default)"
		case .safari:
			return "Safari"
		case .brave:
			return "Brave"
		case .dolphin:
			return "Dolphin"
		case .duckduckgo:
			return "DuckDuckGo"
		case .firefox:
			return "FireFox"
		case .firefoxfocus:
			return "FireFox Focus"
		case .googlechrome:
			return "Chrome"
		case .opera:
			return "Opera"
		}
	}

	/// The short string value of the browser.
	var shortStringValue: String {
		switch self {
		case .kurozora:
			return "Default"
		default:
			return self.stringValue
		}
	}

	/// The image value of the browser.
	var image: UIImage? {
		switch self {
		case .kurozora:
			return UIImage(named: UserSettings.appIcon)
		case .safari:
			return R.image.browsers.safari()
		case .brave:
			return R.image.browsers.brave()
		case .dolphin:
			return R.image.browsers.dolphin()
		case .duckduckgo:
			return R.image.browsers.duckDuckGo()
		case .firefox:
			return R.image.browsers.fireFox()
		case .firefoxfocus:
			return R.image.browsers.fireFoxFocus()
		case .googlechrome:
			return R.image.browsers.googleChrome()
		case .opera:
			return R.image.browsers.opera()
		}
	}

	// MARK: - Functions
	/// Get the scheme value of the browser.
	///
	/// - Parameter urlScheme: The URL scheme.
	///
	/// - Returns: The scheme value of the browser.
	func schemeValue(for urlScheme: String) -> String {
		switch self {
		case .kurozora:
			return ""
		case .safari:
			return ""
		case .brave:
			return "brave://"
		case .dolphin:
			return "dolphin://"
		case .duckduckgo:
			return "ddgQuickLink://"
		case .firefox:
			return "firefox://open-url?url="
		case .firefoxfocus:
			return "firefox-focus://open-url?url="
		case .googlechrome:
			if urlScheme == "http://" {
				return "googlechrome://"
			} else {
				return "googlechromes://"
			}
		case .opera:
			return "opera://open-url?url=http://"
		}
	}

	/// Get the short scheme value of the browser.
	///
	/// - Parameter urlScheme: The URL scheme.
	///
	/// - Returns: The short scheme value of the browser.
	func shortSchemeValue(for urlScheme: String) -> String {
		switch self {
		case .kurozora:
			return ""
		case .safari:
			return ""
		case .brave:
			return "brave://"
		case .dolphin:
			return "dolphin://"
		case .duckduckgo:
			return "ddgQuickLink://"
		case .firefox:
			return "firefox://"
		case .firefoxfocus:
			return "firefox-focus://"
		case .googlechrome:
			if urlScheme == "http://" {
				return "googlechrome://"
			} else {
				return "googlechromes://"
			}
		case .opera:
			return "opera://"
		}
	}

	/// Get the short scheme URL value of the browser.
	///
	/// - Parameter urlScheme: The URL scheme.
	///
	/// - Returns: The short scheme URL value of the browser.
	func shortSchemeUrlValue(for urlScheme: String) -> URL? {
		return URL(string: self.shortSchemeValue(for: urlScheme))
	}
}
