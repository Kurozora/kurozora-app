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
class ShortcutsProvider: AppShortcutsProvider {
	/// The color the system uses to display the App Shortcuts in the Shortcuts app.
	static let shortcutTileColor: ShortcutTileColor = ShortcutTileColor.purple

	/// This sample app contains several examples of different intents, but only the intents this array describes make sense as App Shortcuts.
	/// Put the App Shortcut most people will use as the first item in the array. This first shortcut shouldn't bring the app to the foreground.
	/// Every phrase that people use to invoke an App Shortcut needs to contain the app name, using the `applicationName` placeholder in the provided
	/// phrase text, as well as any app name synonyms declared in the `INAlternativeAppNames` key of the app's `Info.plist` file. These phrases are
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
