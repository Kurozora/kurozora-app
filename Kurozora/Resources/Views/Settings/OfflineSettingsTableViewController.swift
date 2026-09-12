//
//  OfflineSettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// The settings available while the device has no connection.
class OfflineSettingsTableViewController: SettingsTableViewController {
	// MARK: - Properties
	/// The rows that work without a connection.
	private static let offlineRows: [Row] = [
		.account, .switchAccount,
		.keychain, .syncScenarios,
		.browser, .cache, .displayBlindness, .gestures, .icon, .library, .media, .music, .lowDataMode, .motion, .theme,
		.notifications, .soundsAndHaptics,
		.biometrics, .privacy
	]

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.settings
	}

	// MARK: - Functions
	override func isEnabled(_ row: Row) -> Bool {
		return Self.offlineRows.contains(row)
	}
}
