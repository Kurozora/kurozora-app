//
//  SharedDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KeychainAccess
import KurozoraKit

/// A root object that stores information about a song resource.
typealias KKSong = Song

// MARK: - KurozoraKit
let KService = KurozoraKit(apiEndpoint: UserSettings.apiEndpoint).services(SharedDelegate.shared.services)
var KSettings: Settings?

#if DEBUG
let APIEndpoints: [KurozoraAPI] = KurozoraAPI.allCases
#endif

class SharedDelegate {
	// MARK: - Properties
	/// Returns the singleton `SharedDelegate` instance.
	static let shared = SharedDelegate()

	// KurozoraKit
	/// The app's identifier prefix.
	let appIdentifierPrefix: String

	/// The app's base keychain service.
	let keychain: Keychain

	/// KurozoraKit's enabled services
	let services: KKServices

	// MARK: - Initializers
	/// Initializes an instance of `SharedDelegate` with `Keychain` and `KKService` objects.
	private init() {
		if let appIdentifierPrefix = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as? String {
			self.appIdentifierPrefix = appIdentifierPrefix
		} else {
			fatalError("Failed to get AppIdentifierPrefix from Info.plist")
		}

		#if DEBUG
		let accessGroup = "\(self.appIdentifierPrefix)app.kurozora.shared.debug"
		#else
		let accessGroup = "\(self.appIdentifierPrefix)app.kurozora.shared"
		#endif
		self.keychain = Keychain(service: "Kurozora", accessGroup: "\(accessGroup)").synchronizable(true).accessibility(.afterFirstUnlock)
		self.services = KKServices(keychain: self.keychain)
	}
}
