//
//  AccountManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KeychainAccess

/// Manages account storage in a dedicated keychain namespace.
///
/// All account data is stored as JSON-encoded `StoredAccount` values
/// under the `"Kurozora.Accounts"` service, separate from the legacy keychain.
final class AccountManager {
	// MARK: - Properties
	/// Returns the singleton `AccountManager` instance.
	static let shared = AccountManager()

	/// The dedicated keychain for account storage.
	private let keychain: Keychain

	// MARK: - Initializers
	private init() {
		#if DEBUG
		let accessGroup = "\(SharedDelegate.shared.appIdentifierPrefix)app.kurozora.shared.debug"
		#else
		let accessGroup = "\(SharedDelegate.shared.appIdentifierPrefix)app.kurozora.shared"
		#endif

		self.keychain = Keychain(service: "Kurozora.Accounts", accessGroup: accessGroup)
			.synchronizable(true)
			.accessibility(.afterFirstUnlock)
	}

	/// Saves an account to the keychain, JSON-encoded and keyed by slug.
	///
	/// - Parameter account: The account to save.
	func save(_ account: StoredAccount) {
		guard let data = try? JSONEncoder().encode(account) else { return }
		guard let jsonString = String(data: data, encoding: .utf8) else { return }
		try? self.keychain.set(jsonString, key: account.slug)
	}

	/// Returns the stored account for the given slug, or nil if not found.
	///
	/// - Parameter slug: The user's unique slug.
	///
	/// - Returns: The decoded `StoredAccount`, or nil.
	func account(forSlug slug: String) -> StoredAccount? {
		guard let jsonString = try? self.keychain.get(slug) else { return nil }
		guard let data = jsonString.data(using: .utf8) else { return nil }
		return try? JSONDecoder().decode(StoredAccount.self, from: data)
	}

	/// Returns all stored accounts, sorted alphabetically by slug.
	///
	/// - Returns: An array of `StoredAccount`.
	func allAccounts() -> [StoredAccount] {
		return self.keychain.allKeys()
			.compactMap { self.account(forSlug: $0) }
			.sorted { $0.slug.localizedCaseInsensitiveCompare($1.slug) == .orderedAscending }
	}

	/// Removes the account entry for the given slug.
	///
	/// - Parameter slug: The user's unique slug.
	func remove(slug: String) {
		try? self.keychain.remove(slug)
	}

	/// Updates the display name and/or profile image URL for an existing account.
	///
	/// - Parameters:
	///   - slug: The user's unique slug.
	///   - username: The new display name, or nil to leave unchanged.
	///   - profileImageURL: The new profile image URL string, or nil to leave unchanged.
	func updateMetadata(forSlug slug: String, username: String?, profileImageURL: String?) {
		guard var account = self.account(forSlug: slug) else { return }

		if let username {
			account.username = username
		}

		if let profileImageURL {
			account.profileImageURL = profileImageURL
		}

		self.save(account)
	}

	/// One-time migration from the legacy flat slug to token keychain format.
	func migrateIfNeeded() {
		guard !UserSettings.accountStorageMigrationCompleted else { return }

		let legacyKeychain = SharedDelegate.shared.keychain
		let legacyKeys = legacyKeychain.allKeys()

		for key in legacyKeys {
			// Skip watch sentinel keys
			guard !key.hasPrefix("_") else { continue }

			// Skip if already migrated
			guard self.account(forSlug: key) == nil else { continue }

			// Read legacy token
			guard let token = try? legacyKeychain.get(key) else { continue }

			// Write to new keychain
			let account = StoredAccount(
				slug: key,
				username: nil,
				profileImageURL: nil,
				authenticationToken: token
			)
			self.save(account)

			// Remove from old keychain only after confirmed write
			if self.account(forSlug: key) != nil {
				try? legacyKeychain.remove(key)
			}
		}

		UserSettings.set(true, forKey: .accountStorageMigrationCompleted)
	}
}
