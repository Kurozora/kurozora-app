//
//  NotificationsRealtimeBridge.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

final class NotificationsRealtimeBridge {
	// MARK: - Properties
	/// The shared instance of `NotificationsRealtimeBridge`.
	static let shared = NotificationsRealtimeBridge()

	private var task: Task<Void, Never>?

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Begins forwarding realtime user notification events onto the local NotificationCenter.
	func start() {
		guard self.task == nil else { return }

		self.task = Task { @MainActor in
			for await event in KService.userNotificationEvents() {
				NotificationsRealtimeBridge.dispatch(event)
			}
		}
	}

	@MainActor
	private static func dispatch(_ event: UserNotification.Event) {
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
		case .newSession, .newFollower, .newFeedMessageReply, .newFeedMessageReShare,
			.newUserMention, .subscriptionStatus, .userTimedOut, .userTimeoutExpired,
			.libraryImportFinished, .libraryImportUnsupported, .localLibraryImportFinished:
			NotificationCenter.default.post(name: .KUNDidUpdate, object: nil)
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
