//
//  WatchSessionManager.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 01/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import WatchConnectivity

final class WatchSessionManager: NSObject {
	// MARK: - Properties
	static let shared = WatchSessionManager()

	private static let apiEndpointKey = "syncedAPIEndpoint"

	private var authManager: AuthenticationManager?
	private weak var notificationSettings: WatchNotificationSettings?
	private var theme: WatchTheme?

	// MARK: - Initializers
	override private init() {
		super.init()
	}

	// MARK: - Functions
	/// Activates the WatchConnectivity session and stores references to the app's managers.
	///
	/// - Parameters:
	///   - authManager: The app's authentication manager used to apply received auth state.
	///   - notificationSettings: The notification settings object to apply received grouping state.
	///   - theme: The theme object to apply the received tint color to.
	func activate(authManager: AuthenticationManager, notificationSettings: WatchNotificationSettings, theme: WatchTheme) {
		self.authManager = authManager
		self.notificationSettings = notificationSettings
		self.theme = theme

		guard WCSession.isSupported() else { return }
		WCSession.default.delegate = self
		WCSession.default.activate()
	}

	/// Tells the paired iPhone that the Up Next queue changed.
	func notifyUpNextDidChange() {
		guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }

		WCSession.default.sendMessage(["upNextDidChange": true], replyHandler: nil) { error in
			NSLog("Watch failed to notify Up Next change: %@", error.localizedDescription)
		}
	}

	/// Asks the paired iPhone for the current authentication state.
	func requestAuthState() {
		guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }

		// sendMessage wakes the iOS app in the background when it is not running. In the
		// Simulator this is the only path that works, because iCloud Keychain never syncs.
		WCSession.default.sendMessage(["requestAuthState": true]) { [weak self] reply in
			self?.handleApplicationContext(reply)
		} errorHandler: { error in
			NSLog("Watch WCSession auth request failed: %@", error.localizedDescription)
		}
	}

	/// Applies the API endpoint persisted from the last sync with the iPhone.
	func restoreAPIEndpoint() {
		guard let baseURL = UserDefaults.standard.string(forKey: Self.apiEndpointKey) else { return }

		self.applyAPIEndpoint(baseURL)
	}

	// MARK: - Private
	/// Points KurozoraKit at the given host and remembers it for the next launch.
	private func applyAPIEndpoint(_ baseURL: String) {
		#if DEBUG
		let endpoint = APIEndpoints.first { $0.baseURL == baseURL } ?? .custom(baseURL)
		#else
		// Release builds accept only known hosts, never an arbitrary pushed URL.
		guard let endpoint = KurozoraAPI.allCases.first(where: { $0.baseURL == baseURL }) else { return }
		#endif

		UserDefaults.standard.set(baseURL, forKey: Self.apiEndpointKey)

		guard KService.apiEndpoint.baseURL != baseURL else { return }

		KService.apiEndpoint(endpoint)
		NSLog("Watch API endpoint synced to: %@", baseURL)
	}

	private func handleApplicationContext(_ context: [String: Any]) {
		if context["upNextDidChange"] as? Bool == true {
			// The phone sends this after any library or watch status change, so the local
			// store is pulled up to date alongside the Up Next refetch.
			if let slug = User.current?.attributes.slug {
				Task.detached(priority: .utility) {
					await LibrarySyncEngine.shared.syncAll(forUserSlug: slug)
				}
			}

			Task { @MainActor in
				NotificationCenter.default.post(name: .upNextDidChangeRemotely, object: nil)
			}

			return
		}

		// The endpoint has to land before the token is used, otherwise the first
		// authenticated request goes to the wrong host.
		if let baseURL = context["apiEndpoint"] as? String {
			self.applyAPIEndpoint(baseURL)
		}

		let tintColor = context["themeTintColor"] as? String
		let tintedButtonTextColor = context["themeTintedButtonTextColor"] as? String

		if tintColor != nil || tintedButtonTextColor != nil {
			Task { @MainActor [weak self] in
				if let tintColor {
					self?.theme?.applyTint(hex: tintColor)
				}

				if let tintedButtonTextColor {
					self?.theme?.applyTintedButtonText(hex: tintedButtonTextColor)
				}
			}
		}

		// Auth state
		if let authManager {
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

		// Notification settings
		let grouping = context["notificationsGrouping"] as? Int
		let mirrorWatch = context["notificationsMirrorWatch"] as? Bool
		if grouping != nil || mirrorWatch != nil {
			Task { @MainActor [weak self] in
				self?.notificationSettings?.applyContext(grouping: grouping, mirrorWatch: mirrorWatch)
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

			// A stale context can carry settings but no auth state, so the presence of
			// any context is not enough to skip the request.
			let hasAuthState = pending["authToken"] != nil || pending["signedOut"] != nil

			if !hasAuthState {
				self.requestAuthState()
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
