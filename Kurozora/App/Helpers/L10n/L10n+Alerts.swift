//
//  L10n+Alerts.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

extension L10n {
	// MARK: - Warnings
	/// The string for the no signal warning title.
	///
	/// - Tag: L10n-noSignalTitle
	static var noSignalTitle: String {
		L10n.resolve {
			String(
				localized: "Network Unavailable",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the no signal warning title."
			)
		}
	}
	/// The string for the no signal warning message.
	///
	/// - Tag: L10n-noSignalMessage
	static var noSignalMessage: String {
		L10n.resolve {
			String(
				localized: "You must connect to a Wi-Fi network or have a cellular data plan to use Kurozora.",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the no signal warning message."
			)
		}
	}
	/// The string for the force update warning title.
	///
	/// - Tag: L10n-forceUpdateTitle
	static var forceUpdateTitle: String {
		L10n.resolve {
			String(
				localized: "Update Available",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the force update warning title."
			)
		}
	}
	/// The string for the force update warning message.
	///
	/// - Tag: L10n-forceUpdateMessage
	static var forceUpdateMessage: String {
		L10n.resolve {
			String(
				localized: "Kurozora was updated with breaking changes. To avoid the app from crashing, you must update it to continue using it as usual. The update should be available soon on the App Store.",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the force update warning message."
			)
		}
	}
	/// The string for the maintenance warning title.
	///
	/// - Tag: L10n-maintenanceModeTitle
	static var maintenanceModeTitle: String {
		L10n.resolve {
			String(
				localized: "Scheduled Maintenance",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the maintenance warning title."
			)
		}
	}
	/// The string for the maintenance warning message.
	///
	/// - Tag: L10n-maintenanceModeMessage
	static var maintenanceModeMessage: String {
		L10n.resolve {
			String(
				localized: "Kurozora is currently under maintenance. All services will be available shortly. If this continues for more than an hour, you can follow the status on Twitter.",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the maintenance warning message."
			)
		}
	}

	// MARK: - Library
	/// The alert title shown when adding an item to the library fails.
	///
	/// - Tag: L10n-cantAddToLibraryTitle
	static var cantAddToLibraryTitle: String {
		L10n.resolve {
			String(
				localized: "Can't Add to Your Library 😔",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when adding an item to the library fails."
			)
		}
	}
	/// The alert title shown when removing an item from the library fails.
	///
	/// - Tag: L10n-cantRemoveFromLibraryTitle
	static var cantRemoveFromLibraryTitle: String {
		L10n.resolve {
			String(
				localized: "Can't Remove From Your Library 😔",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when removing an item from the library fails."
			)
		}
	}

	// MARK: - Purchases
	/// The alert title shown when a purchase fails verification.
	///
	/// - Tag: L10n-purchaseFailedTitle
	static var purchaseFailedTitle: String {
		L10n.resolve {
			String(
				localized: "Purchase Failed",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when a purchase fails verification."
			)
		}
	}
	/// The alert message shown when a purchase cannot be verified by the App Store.
	///
	/// - Tag: L10n-purchaseVerificationFailedMessage
	static var purchaseVerificationFailedMessage: String {
		L10n.resolve {
			String(
				localized: "Your purchase could not be verified by App Store. If this continues to happen, please contact the developer.",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert message shown when a purchase cannot be verified by the App Store."
			)
		}
	}

	// MARK: - Redeem
	/// The alert title shown when no camera is available to scan a code.
	///
	/// - Tag: L10n-redeemNoCameraTitle
	static var redeemNoCameraTitle: String {
		L10n.resolve {
			String(
				localized: "Well, this is awkward.",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when no camera is available to scan a code."
			)
		}
	}
	/// The alert message shown when no camera is available to scan a code.
	///
	/// - Tag: L10n-redeemNoCameraMessage
	static var redeemNoCameraMessage: String {
		L10n.resolve {
			String(
				localized: "You don't seem to have a camera 😓",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert message shown when no camera is available to scan a code."
			)
		}
	}

	// MARK: - Account
	/// The alert title shown when signing out fails.
	///
	/// - Tag: L10n-cantSignOutTitle
	static var cantSignOutTitle: String {
		L10n.resolve {
			String(
				localized: "Can't Sign Out 😔",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when signing out fails."
			)
		}
	}
	/// The alert title shown when deleting the account fails.
	///
	/// - Tag: L10n-cantDeleteAccountTitle
	static var cantDeleteAccountTitle: String {
		L10n.resolve {
			String(
				localized: "Can't Delete Account 😔",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when deleting the account fails."
			)
		}
	}
	/// The alert title shown when importing to the library fails.
	///
	/// - Tag: L10n-cantImportToLibraryTitle
	static var cantImportToLibraryTitle: String {
		L10n.resolve {
			String(
				localized: "Can't Import To Library 😔",
				table: "Alerts",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when importing to the library fails."
			)
		}
	}
}
