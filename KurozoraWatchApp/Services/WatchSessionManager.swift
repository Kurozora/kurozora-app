//
//  WatchSessionManager.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 01/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import WatchConnectivity

final class WatchSessionManager: NSObject {
	// MARK: - Properties
	static let shared = WatchSessionManager()
	private var authManager: AuthenticationManager?

	// MARK: - Initializers
	override private init() {
		super.init()
	}

	// MARK: - Functions
	/// Activates the WatchConnectivity session and stores a reference to the auth manager.
	///
	/// - Parameter authManager: The app's authentication manager used to apply received auth state.
	func activate(authManager: AuthenticationManager) {
		self.authManager = authManager

		guard WCSession.isSupported() else { return }
		WCSession.default.delegate = self
		WCSession.default.activate()
	}

	// MARK: - Private
	private func handleApplicationContext(_ context: [String: Any]) {
		guard let authManager else { return }

		if let slug = context["authSlug"] as? String,
		   let token = context["authToken"] as? String
		{
			Task { @MainActor in
				await authManager.authenticate(slug: slug, token: token)
			}
		} else if context["signedOut"] as? Bool == true {
			Task { @MainActor in
				authManager.signOut()
			}
		}
	}
}

// MARK: - WCSessionDelegate
extension WatchSessionManager: WCSessionDelegate {
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		if let error {
			NSLog("Watch WCSession activation failed: %@", error.localizedDescription)
			return
		}

		NSLog("Watch WCSession activated with state: %d", activationState.rawValue)

		// Process any context received while the app was not running.
		if activationState == .activated {
			let pending = session.receivedApplicationContext
			NSLog("Watch WCSession pending context keys: %@", pending.keys.joined(separator: ", "))

			if !pending.isEmpty {
				self.handleApplicationContext(pending)
			}
		}
	}

	func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
		self.handleApplicationContext(applicationContext)
	}

	func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
		self.handleApplicationContext(message)
	}
}
