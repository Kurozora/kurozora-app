//
//  WatchSharedDelegate.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KeychainAccess
import KurozoraKit

// MARK: - KurozoraKit
let KService = KurozoraKit(apiEndpoint: .v1, apiKey: "7N5lvvXRDnSz61WBe8CL8yPpBDHkky4xTAWdZrzf").services(WatchShared.services)

#if DEBUG
let APIEndpoints: [KurozoraAPI] = KurozoraAPI.allCases + [
	.custom("https://choice-settling-perch.ngrok-free.app/api/v1/")
]
#endif

struct WatchSharedDelegate {
	// MARK: - Properties
	/// Returns the singleton `WatchSharedDelegate` instance.
	static let shared = WatchSharedDelegate()

	/// The app's identifier prefix.
	let appIdentifierPrefix: String

	/// The app's base keychain service.
	let keychain: Keychain

	/// The dedicated keychain for the new account storage format.
	let accountsKeychain: Keychain

	/// KurozoraKit's enabled services.
	let services: KKServices

	// MARK: - Initializers
	private init() {
		if let appIdentifierPrefix = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as? String {
			self.appIdentifierPrefix = appIdentifierPrefix
		} else {
			fatalError("Failed to get AppIdentifierPrefix from Info.plist")
		}

		let accessGroup = "\(self.appIdentifierPrefix)app.kurozora.shared"
		self.keychain = Keychain(service: "Kurozora", accessGroup: accessGroup).synchronizable(true).accessibility(.afterFirstUnlock)
		self.accountsKeychain = Keychain(service: "Kurozora.Accounts", accessGroup: accessGroup).synchronizable(true).accessibility(.afterFirstUnlock)
		self.services = KKServices(keychain: self.keychain)
	}
}

/// Global accessor matching iOS convention.
let WatchShared = WatchSharedDelegate.shared
