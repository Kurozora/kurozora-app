//
//  KeychainAccess+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KeychainAccess

extension Keychain {
	/// Returns all keys that match with the given regex.
	///
	/// - Parameter regex: The regex used to match keys.
	///
	/// - Returns: all keys that match with the given regex.
	func allKeys(matching regex: String) -> [String] {
		return self.allKeys().matching(regex: regex)
	}
}
