//
//  LanguageManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

extension Notification.Name {
	/// Posted when the app's selected language changes.
	static let appLanguageDidChange = Notification.Name("appLanguageDidChange")
}

/// Resolves the app's UI language independently of the system language.
///
/// Localized strings read ``bundle`` and ``locale`` at access time, so switching the
/// language and rebuilding the UI re-localizes everything without an app relaunch.
final class LanguageManager {
	// MARK: - Properties
	/// The shared language manager instance.
	static let shared = LanguageManager()

	/// The selected language code, or `nil` to follow the system language.
	private(set) var languageCode: String?

	private let storageKey = "appLanguageCode"

	/// The bundle providing localized resources for the selected language.
	///
	/// Falls back to the main bundle when no language is selected or the app does not ship that localization.
	var bundle: Bundle {
		guard let code = self.languageCode, let bundle = Self.localizedBundle(for: code) else {
			return .main
		}
		return bundle
	}

	/// The locale for the selected language, driving plural rules and number formatting.
	var locale: Locale {
		guard let code = self.languageCode, Self.localizedBundle(for: code) != nil else {
			return .current
		}
		return Locale(identifier: code)
	}

	// MARK: - Initializers
	private init() {
		self.languageCode = UserDefaults.standard.string(forKey: self.storageKey)
	}

	// MARK: - Functions
	/// Switches the app's language and notifies observers to re-localize.
	///
	/// - Parameter code: The language code to switch to, or `nil` to follow the system language.
	func setLanguage(_ code: String?) {
		guard code != self.languageCode else { return }

		self.languageCode = code
		UserDefaults.standard.set(code, forKey: self.storageKey)
		NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
	}

	/// Returns the localized bundle for the given language code when the app ships that localization.
	///
	/// - Parameter code: The language code to resolve.
	///
	/// - Returns: The matching `.lproj` bundle.
	private static func localizedBundle(for code: String) -> Bundle? {
		guard let path = Bundle.main.path(forResource: code, ofType: "lproj") else {
			return nil
		}
		return Bundle(path: path)
	}
}
