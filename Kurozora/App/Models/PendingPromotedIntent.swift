//
//  PendingPromotedIntent.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// Persists a promoted-IAP intent so the consent flow can resume after sign-in or app relaunch.
struct PendingPromotedIntent {
	private static let productIDKey = "PendingPromotedIntent.productID"
	private static let savedAtKey = "PendingPromotedIntent.savedAt"

	/// How long a persisted intent stays eligible for resume before it's discarded.
	private static let timeToLive: TimeInterval = 24 * 60 * 60

	/// Persist the product ID of a promoted-IAP intent.
	static func save(productID: String) {
		let defaults = UserDefaults.standard
		defaults.set(productID, forKey: self.productIDKey)
		defaults.set(Date().timeIntervalSince1970, forKey: self.savedAtKey)
	}

	/// Return the persisted product ID if it exists and hasn't expired.
	static func peek() -> String? {
		let defaults = UserDefaults.standard
		guard let productID = defaults.string(forKey: self.productIDKey) else { return nil }

		let savedAt = defaults.double(forKey: self.savedAtKey)
		if Date().timeIntervalSince1970 - savedAt > self.timeToLive {
			self.clear()
			return nil
		}

		return productID
	}

	/// Forget any persisted intent.
	static func clear() {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: self.productIDKey)
		defaults.removeObject(forKey: self.savedAtKey)
	}
}
