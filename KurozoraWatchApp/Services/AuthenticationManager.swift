//
//  AuthenticationManager.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KeychainAccess
import KurozoraKit
import Observation

@Observable
final class AuthenticationManager {
	// MARK: - Properties
	var isSignedIn = false
	var isLoading = true

	// MARK: - Functions
	/// Attempts to restore the user session from the shared keychain.
	func restoreSession() async {
		self.isLoading = true
		defer { self.isLoading = false }

		let selectedSlug = try? WatchShared.keychain.get("_selectedAccount")

		// 1. Try the new accounts keychain (JSON-encoded StoredAccount entries)
		if let slug = selectedSlug,
		   let token = self.token(fromAccountsKeychain: slug)
		{
			await self.authenticate(withToken: token)
			return
		}

		// Try any account in the new keychain
		for key in WatchShared.accountsKeychain.allKeys() {
			if let token = self.token(fromAccountsKeychain: key) {
				await self.authenticate(withToken: token)
				return
			}
		}

		// 2. Legacy fallback: flat slug to token in "Kurozora" keychain
		if let slug = selectedSlug,
		   let token = try? WatchShared.keychain.get(slug)
		{
			await self.authenticate(withToken: token)
			return
		}

		let allKeys = WatchShared.keychain.allKeys()
		if let slug = allKeys.first(where: { !$0.hasPrefix("_") }),
		   let token = try? WatchShared.keychain.get(slug)
		{
			await self.authenticate(withToken: token)
			return
		}

		self.isSignedIn = false
	}

	/// Authenticates with a slug and token received from WatchConnectivity.
	///
	/// - Parameters:
	///   - slug: The user's account slug.
	///   - token: The authentication token.
	func authenticate(slug: String, token: String) async {
		try? WatchShared.keychain.set(token, key: slug)
		try? WatchShared.keychain.set(slug, key: "_selectedAccount")
		await self.authenticate(withToken: token)
	}

	/// Silently revalidates the current session without tearing down the view tree.
	///
	/// Unlike `restoreSession()`, this does not flip `isLoading`, so `ContentView`
	/// and all child views stay alive during revalidation.
	func revalidateSessionIfNeeded() async {
		guard self.isSignedIn else { return }

		do {
			_ = try await KService.profileDetails().response()
		} catch let error as APIError where error.response?.statusCode == 401 || error.response?.statusCode == 403 {
			NSLog("Session revalidation: token rejected (%d), signing out.", error.response?.statusCode ?? 0)
			self.signOut()
		} catch {
			// Transient failure (no network, timeout) — keep session alive
			NSLog("Session revalidation failed (transient): %@", error.localizedDescription)
		}
	}

	/// Signs out the current user on the watch (clears local state only).
	func signOut() {
		KService.authenticationKey = ""
		self.isSignedIn = false
	}

	// MARK: - Private
	/// Decodes a token from the new `Kurozora.Accounts` keychain entry for the given slug.
	private func token(fromAccountsKeychain slug: String) -> String? {
		guard let jsonString = try? WatchShared.accountsKeychain.get(slug),
			  let data = jsonString.data(using: .utf8),
			  let account = try? JSONDecoder().decode(WatchStoredAccount.self, from: data)
		else { return nil }
		return account.authenticationToken
	}

	private func authenticate(withToken token: String) async {
		KService.authenticationKey = token

		do {
			_ = try await KService.profileDetails().response()
			self.isSignedIn = true
		} catch {
			NSLog("Watch auth restore failed: %@", error.localizedDescription)
			self.isSignedIn = false
		}
	}
}

// MARK: - WatchStoredAccount
/// Minimal decodable mirror of the iPhone's `StoredAccount` for reading from the shared accounts keychain.
private struct WatchStoredAccount: Decodable {
	let authenticationToken: String
}
