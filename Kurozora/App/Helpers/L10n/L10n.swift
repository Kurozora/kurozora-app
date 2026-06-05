//
//  L10n.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

/// Namespace for all localized user-facing strings in Kurozora.
///
/// Strings are organized across five domains, each backed by its own
/// `.xcstrings` catalog for independent translation workflows:
///
/// - ``Account`` domain → `Account.xcstrings`
/// - ``Alerts`` domain → `Alerts.xcstrings`
/// - ``Common`` domain → `Localizable.xcstrings`  *(default, unscoped strings)*
/// - ``Content`` domain → `Content.xcstrings`
/// - ``Moderation`` domain → `Moderation.xcstrings`
/// - ``Settings`` domain → `Settings.xcstrings`
///
/// - Tag: L10n
struct L10n {
	/// Resolves a localized string and records how to re-resolve it for live language switching.
	///
	/// - Parameter resolver: A closure that produces the localized string against the current language.
	/// - Returns: The resolved string for the current language.
	static func resolve(_ resolver: @escaping () -> String) -> String {
		let value = resolver()

		if Thread.isMainThread {
			L10nProvenance.pending = resolver
		}

		return value
	}
}

/// Main-thread scratch state for re-resolving the most recently produced localized string.
enum L10nProvenance {
	/// The re-resolve closure for the most recently resolved localized string.
	static var pending: (() -> String)?

	/// A Boolean value indicating whether the engine is re-applying bindings after a language change.
	static var isReapplying = false
}
