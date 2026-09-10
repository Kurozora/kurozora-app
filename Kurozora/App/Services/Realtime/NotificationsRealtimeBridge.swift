//
//  NotificationsRealtimeBridge.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import os.log

private let bridgeLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "NotificationsRealtimeBridge")

private func bridgeLog(_ message: String) {
	bridgeLogger.info("\(message, privacy: .public)")
	print("----- [NotificationsRealtimeBridge] \(message)")
}

final class NotificationsRealtimeBridge {
	// MARK: - Properties
	/// The shared instance of `NotificationsRealtimeBridge`.
	static let shared = NotificationsRealtimeBridge()

	private var task: Task<Void, Never>?

	/// Highest `stateVersion` observed for the signed-in user.
	@MainActor private static var lastSeenStateVersion: Int = 0

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Begins forwarding realtime user notification events onto the local NotificationCenter.
	func start() {
		guard self.task == nil else { return }

		bridgeLog("start — subscribing to KService.userNotificationEvents()")
		self.task = Task { @MainActor in
			while !Task.isCancelled {
				for await event in KService.userNotificationEvents() {
					NotificationsRealtimeBridge.dispatch(event)
				}
				bridgeLog("event stream finished — re-subscribing after brief backoff")
				try? await Task.sleep(nanoseconds: 250_000_000)
			}
		}
	}

	@MainActor
	private static func dispatch(_ event: UserNotification.Event) {
		bridgeLog("dispatch event=\(String(describing: event))")
		switch event {
		case .read(let ids, let read):
			NotificationCenter.default.post(
				name: .KUNDidUpdate,
				object: nil,
				userInfo: Self.userInfo(for: ids, extras: ["read": read])
			)
		case .deleted(let ids):
			NotificationCenter.default.post(
				name: .KUNDidDelete,
				object: nil,
				userInfo: Self.userInfo(for: ids)
			)
		case .userStateChanged(let stateVersion):
			Self.handleStateChanged(stateVersion: stateVersion)
		case .newSession, .newFollower, .newFeedMessageReply, .newFeedMessageReShare,
			.newUserMention, .subscriptionStatus, .userTimedOut, .userTimeoutExpired,
			.libraryImportFinished, .libraryImportUnsupported, .localLibraryImportFinished:
			NotificationCenter.default.post(name: .KUNDidUpdate, object: nil)
		}
	}

	/// Hints the sync engine that the server holds newer state.
	@MainActor
	private static func handleStateChanged(stateVersion: Int) {
		bridgeLog("handleStateChanged stateVersion=\(stateVersion) lastSeen=\(Self.lastSeenStateVersion)")
		guard stateVersion > Self.lastSeenStateVersion else {
			bridgeLog("dropping non-advancing stateVersion")
			return
		}
		Self.lastSeenStateVersion = stateVersion

		guard let slug = User.current?.attributes.slug else {
			bridgeLog("no current user slug, skipping delta sync")
			return
		}

		bridgeLog("server state advanced, hinting the sync engine")
		Task {
			await LibrarySyncEngine.shared.serverStateAdvanced(forUserSlug: slug)
		}
	}

	private static func userInfo(for ids: UserNotification.IDs, extras: [AnyHashable: Any] = [:]) -> [AnyHashable: Any] {
		var info = extras

		switch ids {
		case .specific(let values): info["ids"] = values
		case .all: info["ids"] = "all"
		}

		return info
	}
}
