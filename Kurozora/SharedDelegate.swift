//
//  SharedDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

@preconcurrency import KeychainAccess
import Kingfisher
import KurozoraKit
import Foundation

/// A root object that stores information about a song resource.
typealias KKSong = Song

// MARK: - KurozoraKit
nonisolated let KService = KurozoraKit(apiEndpoint: UserSettings.apiEndpoint).services(KKServices(keychain: SharedDelegate.shared.keychain, webSocketAppKey: "8qrx4dilbbnlxuovxke8"))
var KSettings: Settings?

#if DEBUG
let APIEndpoints: [KurozoraAPI] = KurozoraAPI.allCases
#endif

nonisolated struct SharedDelegate {
	// MARK: - Properties
	/// Returns the singleton `SharedDelegate` instance.
	static let shared = SharedDelegate()

	// KurozoraKit
	/// The app's identifier prefix.
	let appIdentifierPrefix: String

	/// The app's base keychain service.
	let keychain: Keychain

	// MARK: - Initializers
	/// Initializes an instance of `SharedDelegate` with a `Keychain` object.
	private init() {
		// Max disk cache size
		ImageCache.default.diskStorage.config.sizeLimit = 100 * 1024 * 1024

		if let appIdentifierPrefix = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as? String {
			self.appIdentifierPrefix = appIdentifierPrefix
		} else {
			fatalError("Failed to get AppIdentifierPrefix from Info.plist")
		}

		let accessGroup = "\(self.appIdentifierPrefix)app.kurozora.shared"
		self.keychain = Keychain(service: "Kurozora", accessGroup: accessGroup).synchronizable(true).accessibility(.afterFirstUnlock)
	}
}
