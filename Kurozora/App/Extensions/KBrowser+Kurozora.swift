//
//  KBrowser+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

extension KBrowser {
	// MARK: - Properties
	/// The string value of the browser.
	var stringValue: String {
		switch self {
		case .kurozora:
			return L10n.browserInAppDefault
		case .safari:
			return "Safari"
		case .brave:
			return "Brave"
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
			return L10n.default
		default:
			return self.stringValue
		}
	}

	/// The image value of the browser.
	var image: UIImage? {
		switch self {
		case .kurozora:
			return .appIconPreview(named: UserSettings.appIcon)
		case .safari:
			return .Browsers.safari
		case .brave:
			return .Browsers.brave
		case .duckduckgo:
			return .Browsers.duckduckgo
		case .firefox:
			return .Browsers.firefox
		case .firefoxFocus:
			return .Browsers.firefoxFocus
		case .googleChrome:
			return .Browsers.googleChrome
		case .opera:
			return .Browsers.opera
		}
	}
}
