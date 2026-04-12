//
//  WatchSessionManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import WatchConnectivity

final class WatchSessionManager: NSObject {
	// MARK: - Properties
	static let shared = WatchSessionManager()

	// MARK: - Initializers
	private override init() {
		super.init()
	}

	// MARK: - Functions
	/// Activates the WatchConnectivity session if supported.
	func activate() {
		guard WCSession.isSupported() else { return }
		WCSession.default.delegate = self
		WCSession.default.activate()
	}

	/// Pushes the current auth state to the paired Watch via `updateApplicationContext`.
	///
	/// - Parameters:
	///   - slug: The authenticated user's slug, or `nil` on sign-out.
	///   - token: The authentication token, or `nil` on sign-out.
	func sendAuthState(slug: String?, token: String?) {
		guard WCSession.isSupported() else { return }

		let context: [String: Any]
		if let slug, let token {
			context = ["authSlug": slug, "authToken": token]
		} else {
			context = ["signedOut": true]
		}

		do {
			try WCSession.default.updateApplicationContext(context)
			print("----- [WatchConnectivitySession] WCSession sent auth context: %@", context.keys.joined(separator: ", "))
		} catch {
			print("----- [WatchConnectivitySession] WCSession failed to send auth context: %@", error.localizedDescription)
		}

		// Also send via message for immediate delivery when the Watch app is reachable.
		if WCSession.default.isReachable {
			WCSession.default.sendMessage(context, replyHandler: nil) { error in
				print("----- [WatchConnectivitySession] WCSession sendMessage failed: %@", error.localizedDescription)
			}
		}
	}
}

// MARK: - WCSessionDelegate
extension WatchSessionManager: WCSessionDelegate {
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		if let error {
			print("----- [WatchConnectivitySession] WCSession activation failed: %@", error.localizedDescription)
			return
		}

		print("----- [WatchConnectivitySession] WCSession activated with state: %d", activationState.rawValue)
	}

	func sessionReachabilityDidChange(_ session: WCSession) {
		guard session.isReachable else { return }

		// Push auth state when the Watch becomes reachable.
		let slug = UserSettings.selectedAccount
		if let account = AccountManager.shared.account(forSlug: slug) {
			self.sendAuthState(slug: slug, token: account.authenticationToken)
		}
	}

	func sessionDidBecomeInactive(_ session: WCSession) {}

	func sessionDidDeactivate(_ session: WCSession) {
		// Re-activate to support account switching on multi-watch setups.
		WCSession.default.activate()
	}
}
