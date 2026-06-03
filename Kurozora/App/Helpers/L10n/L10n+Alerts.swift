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
	static let noSignalTitle: String = String(
		localized: "Network Unavailable",
		table: "Alerts",
		comment: "The string for the no signal warning title."
	)
	/// The string for the no signal warning message.
	///
	/// - Tag: L10n-noSignalMessage
	static let noSignalMessage: String = String(
		localized: "You must connect to a Wi-Fi network or have a cellular data plan to use Kurozora.",
		table: "Alerts",
		comment: "The string for the no signal warning message."
	)
	/// The string for the force update warning title.
	///
	/// - Tag: L10n-forceUpdateTitle
	static let forceUpdateTitle: String = String(
		localized: "Update Available",
		table: "Alerts",
		comment: "The string for the force update warning title."
	)
	/// The string for the force update warning message.
	///
	/// - Tag: L10n-forceUpdateMessage
	static let forceUpdateMessage: String = String(
		localized: "Kurozora was updated with breaking changes. To avoid the app from crashing, you must update it to continue using it as usual. The update should be available soon on the App Store.",
		table: "Alerts",
		comment: "The string for the force update warning message."
	)
	/// The string for the maintenance warning title.
	///
	/// - Tag: L10n-maintenanceModeTitle
	static let maintenanceModeTitle: String = String(
		localized: "Scheduled Maintenance",
		table: "Alerts",
		comment: "The string for the maintenance warning title."
	)
	/// The string for the maintenance warning message.
	///
	/// - Tag: L10n-maintenanceModeMessage
	static let maintenanceModeMessage: String = String(
		localized: "Kurozora is currently under maintenance. All services will be available shortly. If this continues for more than an hour, you can follow the status on Twitter.",
		table: "Alerts",
		comment: "The string for the maintenance warning message."
	)

	// MARK: - Library
	/// The alert title shown when adding an item to the library fails.
	///
	/// - Tag: L10n-cantAddToLibraryTitle
	static let cantAddToLibraryTitle: String = String(
		localized: "Can't Add to Your Library 😔",
		table: "Alerts",
		comment: "The alert title shown when adding an item to the library fails."
	)
	/// The alert title shown when removing an item from the library fails.
	///
	/// - Tag: L10n-cantRemoveFromLibraryTitle
	static let cantRemoveFromLibraryTitle: String = String(
		localized: "Can't Remove From Your Library 😔",
		table: "Alerts",
		comment: "The alert title shown when removing an item from the library fails."
	)

	// MARK: - Purchases
	/// The alert title shown when a purchase fails verification.
	///
	/// - Tag: L10n-purchaseFailedTitle
	static let purchaseFailedTitle: String = String(
		localized: "Purchase Failed",
		table: "Alerts",
		comment: "The alert title shown when a purchase fails verification."
	)
	/// The alert message shown when a purchase cannot be verified by the App Store.
	///
	/// - Tag: L10n-purchaseVerificationFailedMessage
	static let purchaseVerificationFailedMessage: String = String(
		localized: "Your purchase could not be verified by App Store. If this continues to happen, please contact the developer.",
		table: "Alerts",
		comment: "The alert message shown when a purchase cannot be verified by the App Store."
	)

	// MARK: - Redeem
	/// The alert title shown when no camera is available to scan a code.
	///
	/// - Tag: L10n-redeemNoCameraTitle
	static let redeemNoCameraTitle: String = String(
		localized: "Well, this is awkward.",
		table: "Alerts",
		comment: "The alert title shown when no camera is available to scan a code."
	)
	/// The alert message shown when no camera is available to scan a code.
	///
	/// - Tag: L10n-redeemNoCameraMessage
	static let redeemNoCameraMessage: String = String(
		localized: "You don't seem to have a camera 😓",
		table: "Alerts",
		comment: "The alert message shown when no camera is available to scan a code."
	)

	// MARK: - Account
	/// The alert title shown when signing out fails.
	///
	/// - Tag: L10n-cantSignOutTitle
	static let cantSignOutTitle: String = String(
		localized: "Can't Sign Out 😔",
		table: "Alerts",
		comment: "The alert title shown when signing out fails."
	)
	/// The alert title shown when deleting the account fails.
	///
	/// - Tag: L10n-cantDeleteAccountTitle
	static let cantDeleteAccountTitle: String = String(
		localized: "Can't Delete Account 😔",
		table: "Alerts",
		comment: "The alert title shown when deleting the account fails."
	)
	/// The alert title shown when importing to the library fails.
	///
	/// - Tag: L10n-cantImportToLibraryTitle
	static let cantImportToLibraryTitle: String = String(
		localized: "Can't Import To Library 😔",
		table: "Alerts",
		comment: "The alert title shown when importing to the library fails."
	)
}
