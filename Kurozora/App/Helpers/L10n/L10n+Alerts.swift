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
}
