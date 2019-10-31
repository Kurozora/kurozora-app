//
//  KBrowser.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

enum KBrowser: Int {
	case safari = 0
	case duckduckgo = 1
	case firefox = 2
	case firefoxfocus = 3
	case googlechrome = 4
	case brave = 5
	case opera = 6
	case dolphin = 7

	static var all: [KBrowser] = [.safari, .brave, .dolphin, .duckduckgo, .firefox, .firefoxfocus, .googlechrome, .opera]

	// MARK: - Properties
	var stringValue: String {
		switch self {
		case .safari:
			return "Safari (default)"
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

	var image: UIImage {
		switch self {
		case .safari:
			return #imageLiteral(resourceName: "safari_icon")
		case .brave:
			return #imageLiteral(resourceName: "brave_icon")
		case .dolphin:
			return #imageLiteral(resourceName: "dolphin_icon")
		case .duckduckgo:
			return #imageLiteral(resourceName: "duckduckgo_icon")
		case .firefox:
			return #imageLiteral(resourceName: "firefox_icon")
		case .firefoxfocus:
			return #imageLiteral(resourceName: "firefoxfocus_icon")
		case .googlechrome:
			return #imageLiteral(resourceName: "googlechrome_icon")
		case .opera:
			return #imageLiteral(resourceName: "opera_icon")
		}
	}

	// MARK: - Functions
	func schemeValue(for urlScheme: String) -> String {
		switch self {
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
