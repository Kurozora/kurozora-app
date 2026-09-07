//
//  WatchSessionManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftTheme
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
		guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }

		var context: [String: Any]
		if let slug, let token {
			context = ["authSlug": slug, "authToken": token]
		} else {
			context = ["signedOut": true]
		}

		// Merge notification settings into the context.
		context["notificationsGrouping"] = UserSettings.notificationsGrouping
		context["notificationsMirrorWatch"] = UserSettings.notificationsMirrorWatch

		// The Watch must talk to the same host as the iPhone, otherwise the token is rejected.
		context["apiEndpoint"] = KService.apiEndpoint.baseURL
		context["themeTintColor"] = ThemeManager.value(for: KThemePicker.tintColor.stringValue) as? String
		context["themeTintedButtonTextColor"] = ThemeManager.value(for: KThemePicker.tintedButtonTextColor.stringValue) as? String

		do {
			try WCSession.default.updateApplicationContext(context)
			print("WCSession sent context:", context.keys.joined(separator: ", "))
		} catch {
			print("WCSession failed to send context:", error.localizedDescription)
		}

		// Also send via message for immediate delivery when the Watch app is reachable.
		if WCSession.default.isReachable {
			WCSession.default.sendMessage(context, replyHandler: nil) { error in
				print("WCSession sendMessage failed:", error.localizedDescription)
			}
		}
	}

	/// Tells the paired Watch that the Up Next queue changed.
	func notifyUpNextDidChange() {
		guard WCSession.isSupported(),
			  WCSession.default.activationState == .activated,
			  WCSession.default.isWatchAppInstalled,
			  WCSession.default.isReachable
		else { return }

		WCSession.default.sendMessage(["upNextDidChange": true], replyHandler: nil) { error in
			print("WCSession failed to notify Up Next change:", error.localizedDescription)
		}
	}

	/// Pushes the selected account's authentication state to the paired Watch.
	func sendCurrentAuthState() {
		let slug = UserSettings.selectedAccount

		// Staying silent when no account is selected keeps a launch that beats
		// session restore from signing the Watch out.
		guard let account = AccountManager.shared.account(forSlug: slug) else { return }

		self.sendAuthState(slug: slug, token: account.authenticationToken)
	}

	/// Pushes the current notification settings to the paired Watch.
	///
	/// - Parameters:
	///   - grouping: The notification grouping raw value.
	///   - mirrorWatch: Whether the watch should mirror the iPhone's setting.
	func sendNotificationSettings(grouping: Int, mirrorWatch: Bool) {
		guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }

		let context: [String: Any] = [
			"notificationsGrouping": grouping,
			"notificationsMirrorWatch": mirrorWatch
		]

		do {
			try WCSession.default.updateApplicationContext(context)
		} catch {
			print("WCSession failed to send notification settings:", error.localizedDescription)
		}

		if WCSession.default.isReachable {
			WCSession.default.sendMessage(context, replyHandler: nil) { error in
				print("WCSession sendMessage (notification settings) failed:", error.localizedDescription)
			}
		}
	}
}

// MARK: - WCSessionDelegate
extension WatchSessionManager: WCSessionDelegate {
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		if let error {
			print("----- [WatchConnectivitySession] WCSession activation failed:", error.localizedDescription)
			return
		}

		print("----- [WatchConnectivitySession] WCSession activated with state: %d", activationState.rawValue)

		guard activationState == .activated else { return }

		self.pushStateToWatch()
	}

	func sessionReachabilityDidChange(_ session: WCSession) {
		guard session.isReachable else { return }

		self.pushStateToWatch()
	}

	func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
		guard message["upNextDidChange"] as? Bool == true else { return }

		Task { @MainActor in
			NotificationCenter.default.post(name: .KUpNextDidChangeRemotely, object: nil)
		}
	}

	func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
		guard message["requestAuthState"] as? Bool == true else {
			replyHandler([:])
			return
		}

		let slug = UserSettings.selectedAccount
		var reply: [String: Any] = ["apiEndpoint": KService.apiEndpoint.baseURL]

		if let tintColor = ThemeManager.value(for: KThemePicker.tintColor.stringValue) as? String {
			reply["themeTintColor"] = tintColor
		}

		if let tintedButtonTextColor = ThemeManager.value(for: KThemePicker.tintedButtonTextColor.stringValue) as? String {
			reply["themeTintedButtonTextColor"] = tintedButtonTextColor
		}

		guard let account = AccountManager.shared.account(forSlug: slug) else {
			reply["signedOut"] = true
			replyHandler(reply)
			return
		}

		reply["authSlug"] = slug
		reply["authToken"] = account.authenticationToken
		replyHandler(reply)
	}

	/// Pushes the authentication state and notification settings to the paired Watch.
	private func pushStateToWatch() {
		self.sendCurrentAuthState()
		self.sendNotificationSettings(
			grouping: UserSettings.notificationsGrouping,
			mirrorWatch: UserSettings.notificationsMirrorWatch
		)
	}

	func sessionDidBecomeInactive(_ session: WCSession) {}

	func sessionDidDeactivate(_ session: WCSession) {
		// Re-activate to support account switching on multi-watch setups.
		WCSession.default.activate()
	}
}
