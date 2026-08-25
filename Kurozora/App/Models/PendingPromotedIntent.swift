//
//  PendingPromotedIntent.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// A promoted in-app purchase intent persisted between launches.
struct PendingPromotedIntent {
	/// The key to the persisted product ID.
	private static let productIDKey = "PendingPromotedIntent.productID"

	/// The key to the time the intent was persisted.
	private static let savedAtKey = "PendingPromotedIntent.savedAt"

	/// How long a persisted intent stays valid.
	private static let timeToLive: TimeInterval = 24 * 60 * 60

	/// Persists the product ID of a promoted intent.
	///
	/// - Parameter productID: The product ID to persist.
	static func save(productID: String) {
		let defaults = UserDefaults.standard
		defaults.set(productID, forKey: Self.productIDKey)
		defaults.set(Date().timeIntervalSince1970, forKey: Self.savedAtKey)
	}

	/// Returns the product ID of the persisted intent.
	static func peek() -> String? {
		let defaults = UserDefaults.standard
		guard let productID = defaults.string(forKey: Self.productIDKey) else { return nil }

		let savedAt = defaults.double(forKey: Self.savedAtKey)
		if Date().timeIntervalSince1970 - savedAt > Self.timeToLive {
			self.clear()
			return nil
		}

		return productID
	}

	/// Clears the persisted intent.
	static func clear() {
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: Self.productIDKey)
		defaults.removeObject(forKey: Self.savedAtKey)
	}
}
