//
//  ShortcutsProvider.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import AppIntents

/// An `AppShortcut` wraps an intent to make it automatically discoverable throughout the system. An `AppShortcutsProvider` manages the shortcuts the app
/// makes available. The app can update the available shortcuts by calling `updateAppShortcutParameters()` as needed.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
final class ShortcutsProvider: AppShortcutsProvider {
	/// The color the system uses to display the App Shortcuts in the Shortcuts app.
	static let shortcutTileColor: ShortcutTileColor = ShortcutTileColor.purple

	/// The array of supported app shortcuts.
	///
	/// Every phrase that people use to invoke an App Shortcut needs to contain the app name, using the `applicationName` placeholder in the provided
	/// localized in a string catalog named `AppShortcuts.xcstrings`.
	static var appShortcuts: [AppShortcut] {
		AppShortcut(
			intent: LaunchAppIntent(),
			phrases: [
				"Open \(\.$target) in \(.applicationName)",
				"Open \(.applicationName) \(\.$target)",
				"Open my \(\.$target) in \(.applicationName)",
				"Open my \(.applicationName) \(\.$target)",
				"Show \(\.$target) in \(.applicationName)",
				"Show \(.applicationName) \(\.$target)",
				"Show my \(.applicationName) \(\.$target)"
			],
			shortTitle: "Open Kurozora",
			systemImageName: "arrow.up.forward"
		)
	}
}
