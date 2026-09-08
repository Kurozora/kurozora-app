//
//  L10n.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// Namespace for the widget extension's user-facing strings, backed by the widget target's own `Localizable.xcstrings`.
///
/// - Tag: L10n
struct L10n {
	// MARK: - Up Next Widget
	static var upNext: String {
		String(localized: "Up Next", comment: "The name of the Up Next widget in the widget gallery.")
	}

	static var upNextDescription: String {
		String(localized: "Keep up with your upcoming episodes.", comment: "The description of the Up Next widget in the widget gallery.")
	}

	static var upNextSignInPrompt: String {
		String(localized: "Sign in to see your Up Next episodes", comment: "Shown on the Up Next widget in place of episodes when no account is signed in.")
	}

	static var upNextEmptyTitle: String {
		String(localized: "You're all caught up!", comment: "The heading shown on the Up Next widget when the queue is empty.")
	}

	static var upNextEmptyMessage: String {
		String(localized: "Start a new anime, manga or game from your library", comment: "The message shown beneath the heading on the Up Next widget when the queue is empty.")
	}

	static var upNextUnavailable: String {
		String(localized: "Unable to retrieve your Up-Next Episodes", comment: "Shown on the Up Next widget when the queue could not be loaded.")
	}

	// MARK: - Date Widget
	static var date: String {
		String(localized: "Date", comment: "The name of the Date widget in the widget gallery.")
	}

	static var dateDescription: String {
		String(localized: "Track the current date with random anime, manga or game images every hour.", comment: "The description of the Date widget in the widget gallery.")
	}
}
