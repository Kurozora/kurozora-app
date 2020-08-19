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
	/// The string value of a KBrowser type.
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
			return "DuckDuck Go"
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

	/// The image value of a KBrowser type.
	var image: UIImage {
		switch self {
		case .kurozora:
			return #imageLiteral(resourceName: UserSettings.appIcon)
		case .safari:
			return R.image.browsers.safari()!
		case .brave:
			return R.image.browsers.brave()!
		case .dolphin:
			return R.image.browsers.dolphin()!
		case .duckduckgo:
			return R.image.browsers.duckDuckGo()!
		case .firefox:
			return R.image.browsers.fireFox()!
		case .firefoxfocus:
			return R.image.browsers.fireFoxFocus()!
		case .googlechrome:
			return R.image.browsers.googleChrome()!
		case .opera:
			return R.image.browsers.opera()!
		}
	}

	// MARK: - Functions
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

	func shortSchemeUrlValue(for urlScheme: String) -> URL? {
		return URL(string: self.shortSchemeValue(for: urlScheme))
	}
}
