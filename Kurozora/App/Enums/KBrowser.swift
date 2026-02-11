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
	case firefoxFocus
	case googleChrome
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
		case .firefoxFocus:
			return "FireFox Focus"
		case .googleChrome:
			return "Chrome"
		case .opera:
			return "Opera"
		}
	}

	/// The short string value of the browser.
	var shortStringValue: String {
		switch self {
		case .kurozora:
			return Trans.default
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
            return .Browsers.safari
		case .brave:
            return .Browsers.brave
		case .dolphin:
            return .Browsers.dolphin
		case .duckduckgo:
            return .Browsers.duckDuckGo
		case .firefox:
            return .Browsers.fireFox
		case .firefoxFocus:
            return .Browsers.fireFoxFocus
		case .googleChrome:
            return .Browsers.googleChrome
		case .opera:
            return .Browsers.opera
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
		case .firefoxFocus:
			return "firefox-focus://open-url?url="
		case .googleChrome:
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
		case .firefoxFocus:
			return "firefox-focus://"
		case .googleChrome:
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
	func shortSchemeURLValue(for urlScheme: String) -> URL? {
		return URL(string: self.shortSchemeValue(for: urlScheme))
	}
}
