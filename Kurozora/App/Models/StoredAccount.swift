//
//  StoredAccount.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// A codable representation of an account stored in the keychain.
struct StoredAccount: Codable {
	/// The user's slug.
	let slug: String

	/// The user's display name.
	var username: String?

	/// The URL string for the user's profile image.
	var profileImageURL: String?

	/// The authentication token for this account.
	var authenticationToken: String
}
