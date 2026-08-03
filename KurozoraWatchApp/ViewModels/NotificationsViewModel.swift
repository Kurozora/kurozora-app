//
//  NotificationsViewModel.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import Observation

// MARK: - NotificationSection
/// A grouping of notifications for display in a section.
struct NotificationSection: Identifiable {
	let id: String
	let title: String
	var notifications: [UserNotification]
}

// MARK: - NotificationsViewModel
@MainActor @Observable
final class NotificationsViewModel {
	// MARK: - Properties
	var loadState: LoadState = .idle
	var sections: [NotificationSection] = []

	private var rawNotifications: [UserNotification] = []
	private var hasFetchedOnce = false

	// MARK: - Functions
	func fetchIfNeeded(groupStyle: WatchGroupStyle) async {
		guard !self.hasFetchedOnce else { return }
		await self.fetch(groupStyle: groupStyle)
	}

	func refresh(groupStyle: WatchGroupStyle) async {
		self.hasFetchedOnce = false
		await self.fetch(groupStyle: groupStyle)
	}

	/// Toggles the read/unread status of a notification.
	func toggleReadStatus(for notification: UserNotification, groupStyle: WatchGroupStyle) async {
		let originalStatus = notification.attributes.readStatus
		let newStatus: ReadStatus = originalStatus == .read ? .unread : .read

		// Optimistic update
		notification.attributes.readStatus = newStatus
		self.rebuildSections(groupStyle: groupStyle)

		do {
			let response = try await KService
				.updateNotification(notification.id.rawValue, readStatus: newStatus)
				.response()
			notification.attributes.readStatus = response.data.readStatus
			self.rebuildSections(groupStyle: groupStyle)
		} catch {
			// Rollback
			notification.attributes.readStatus = originalStatus
			self.rebuildSections(groupStyle: groupStyle)
			NSLog("Notification read status update failed: %@", error.localizedDescription)
		}
	}

	/// Deletes a notification.
	func delete(notification: UserNotification, groupStyle: WatchGroupStyle) async {
		let originalNotifications = self.rawNotifications

		// Optimistic update
		self.rawNotifications.removeAll { $0.id == notification.id }
		self.rebuildSections(groupStyle: groupStyle)

		do {
			_ = try await KService.deleteNotification(notification).response()
		} catch {
			// Rollback
			self.rawNotifications = originalNotifications
			self.rebuildSections(groupStyle: groupStyle)
			NSLog("Notification delete failed: %@", error.localizedDescription)
		}
	}

	/// Marks all notifications with the given read status.
	func markAll(withStatus readStatus: ReadStatus, groupStyle: WatchGroupStyle) async {
		let originalStatuses = self.rawNotifications.map { $0.attributes.readStatus }

		// Optimistic update
		self.rawNotifications.forEach { $0.attributes.readStatus = readStatus }
		self.rebuildSections(groupStyle: groupStyle)

		do {
			let response = try await KService
				.updateNotification("all", readStatus: readStatus)
				.response()
			self.rawNotifications.forEach { $0.attributes.readStatus = response.data.readStatus }
			self.rebuildSections(groupStyle: groupStyle)
		} catch {
			// Rollback
			for (index, notification) in self.rawNotifications.enumerated() where index < originalStatuses.count {
				notification.attributes.readStatus = originalStatuses[index]
			}
			self.rebuildSections(groupStyle: groupStyle)
			NSLog("Mark all notifications failed: %@", error.localizedDescription)
		}
	}

	/// Rebuilds sections from the current raw notifications with the given group style.
	func rebuildSections(groupStyle: WatchGroupStyle) {
		switch groupStyle {
		case .automatic:
			self.sections = self.groupedByDate(self.rawNotifications)
		case .byType:
			self.sections = self.groupedByType(self.rawNotifications)
		case .off:
			self.sections = self.flat(self.rawNotifications)
		}
	}

	// MARK: - Private
	private func fetch(groupStyle: WatchGroupStyle) async {
		self.hasFetchedOnce = true
		self.loadState = .loading

		do {
			let response = try await KService.notifications().response()
			self.rawNotifications = response.data
			self.rebuildSections(groupStyle: groupStyle)
			self.loadState = .loaded
		} catch {
			self.hasFetchedOnce = false
			self.loadState = .error("Failed to load notifications.")
			NSLog("Notifications fetch error: %@", error.localizedDescription)
		}
	}

	private func groupedByDate(_ notifications: [UserNotification]) -> [NotificationSection] {
		let grouped = notifications.reduce(into: [String: [UserNotification]]()) { result, notification in
			let key = notification.attributes.createdAt.groupTime
			result[key, default: []].append(notification)
		}

		return grouped.map { key, value in
			NotificationSection(id: key, title: key, notifications: value)
		}.sorted { lhs, rhs in
			let lhsDate = lhs.notifications.first?.attributes.createdAt ?? Date()
			let rhsDate = rhs.notifications.first?.attributes.createdAt ?? Date()
			return lhsDate > rhsDate
		}
	}

	private func groupedByType(_ notifications: [UserNotification]) -> [NotificationSection] {
		let grouped = notifications.reduce(into: [String: [UserNotification]]()) { result, notification in
			let key = notification.attributes.type.watchLabel
			result[key, default: []].append(notification)
		}

		return grouped.map { key, value in
			NotificationSection(id: key, title: key, notifications: value)
		}.sorted { $0.title < $1.title }
	}

	private func flat(_ notifications: [UserNotification]) -> [NotificationSection] {
		guard !notifications.isEmpty else { return [] }
		return [NotificationSection(id: "main", title: "", notifications: notifications)]
	}
}

// MARK: - Date+GroupTime
private extension Date {
	/// Returns a string indicating the group a given date falls in.
	var groupTime: String {
		let timeInterval = Int(-self.timeIntervalSince(Date()))

		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE"
		let weekDay = formatter.string(from: self)

		if let yearsAgo = timeInterval / (12 * 4 * 7 * 24 * 60 * 60) as Int?, yearsAgo > 0 {
			return yearsAgo == 1 ? "Last Year" : "\(yearsAgo) Years Ago"
		} else if let monthsAgo = timeInterval / (4 * 7 * 24 * 60 * 60) as Int?, monthsAgo > 0 {
			return monthsAgo == 1 ? "Last Month" : "\(monthsAgo) Months Ago"
		} else if let weeksAgo = timeInterval / (7 * 24 * 60 * 60) as Int?, weeksAgo > 0 {
			return weeksAgo == 1 ? "Last Week" : "\(weeksAgo) Weeks Ago"
		} else if let daysAgo = timeInterval / (24 * 60 * 60) as Int?, daysAgo > 0 {
			return daysAgo == 1 ? "Yesterday" : weekDay
		} else if let hoursAgo = timeInterval / (60 * 60) as Int?, hoursAgo > 0 {
			return "Earlier Today"
		}
		return "Recent"
	}
}

// MARK: - UserNotificationType+Watch
extension UserNotificationType {
	/// The display label for this notification type on watchOS.
	var watchLabel: String {
		switch self {
		case .session:
			return "New Session"
		case .follower:
			return "Follower"
		case .feedMessageReply, .feedMessageReShare:
			return "Message"
		case .userMention:
			return "Mention"
		case .libraryImportFinished:
			return "Library Import"
		case .subscriptionStatus:
			return "Subscription Update"
		case .userTimedOut, .userTimeoutExpired:
			return "Moderation"
		case .other:
			return "Other"
		}
	}

	/// The icon representing this notification type.
	var watchIcon: ImageResource {
		switch self {
		case .session:
			return .Icons.clockArrowCirclepath
		case .follower:
			return .Icons.person2
		case .feedMessageReply, .feedMessageReShare, .userMention:
			return .Icons.message
		case .libraryImportFinished:
			return .Icons.library
		case .subscriptionStatus:
			return .Icons.lockOpen
		case .userTimedOut, .userTimeoutExpired:
			return .Icons.shieldCheckered
		case .other:
			return .Icons.appBadge
		}
	}

	/// Whether this notification type displays a user profile image.
	var hasProfileImage: Bool {
		switch self {
		case .follower, .feedMessageReply, .feedMessageReShare:
			return true
		default:
			return false
		}
	}
}
