//
//  KKServices.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KeychainAccess

/**
	`KKServices` is a root object, that serves as a provider for KurozoraKit services.

	`KKServices` provides the following services:
	- Process and save user data in Keychain.
*/
internal class KKServices {
	/// KurozoraKit's base keychain service.
	internal var KeychainDefaults: Keychain = Keychain()

	/// The shared instance of `KKServices`.
	static let shared = KKServices()

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/**
		Processes some user data such as saving the current user's username in the Keychain.

		- Parameter userSession: The user session from which the data should be fetched and processed.
	*/
	func processUserData(fromSession userSession: UserSessions) {
		if let userID = userSession.user?.id, userID != 0 {
			try? KKServices.shared.KeychainDefaults.set(String(userID), key: "user_id")
		}

		if let username = userSession.user?.username, !username.isEmpty {
			try? KKServices.shared.KeychainDefaults.set(username, key: "username")
		}

		if let profileImage = userSession.user?.profileImage, !profileImage.isEmpty {
			try? KKServices.shared.KeychainDefaults.set(profileImage, key: "profile_image")
		}

		if let authToken = userSession.authToken, !authToken.isEmpty {
			try? KKServices.shared.KeychainDefaults.set(authToken, key: "auth_token")
		}

		if let sessionID = userSession.currentSessions?.id, sessionID != 0 {
			try? KKServices.shared.KeychainDefaults.set(String(sessionID), key: "session_id")
		}
	}
}
