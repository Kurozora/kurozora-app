//
//  AiringNotificationScheduler.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit
import UserNotifications
import os.log

private nonisolated let airingLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "AiringNotificationScheduler")

/// Schedules the local notifications for the reminded shows in the library.
actor AiringNotificationScheduler {
	// MARK: - Properties
	/// Returns the singleton `AiringNotificationScheduler` instance.
	static let shared = AiringNotificationScheduler()

	/// The prefix every scheduled request's identifier carries.
	static let identifierPrefix = "library-airing-"

	/// The identifier of the category an airing reminder belongs to.
	static let categoryIdentifier = "LIBRARY_AIRING"

	/// The number of requests the scheduler keeps pending.
	private static let maximumScheduled = 50

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Rebuilds the pending notifications from the local library.
	func refresh() async {
		let preferences = await MainActor.run {
			(isAllowed: UserSettings.airingRemindersAllowed, playsSound: UserSettings.notificationsSound)
		}

		guard preferences.isAllowed else {
			await self.cancelAll()
			return
		}

		guard let userSlug = User.current?.attributes.slug else {
			await self.cancelAll()
			return
		}

		guard await self.hasAuthorization() else {
			await self.cancelAll()
			return
		}

		let slots = await self.slots(forUserSlug: userSlug)
		await self.cancelAll()

		for slot in slots.prefix(Self.maximumScheduled) {
			await self.schedule(slot, playsSound: preferences.playsSound)
		}

		if slots.count > Self.maximumScheduled {
			airingLogger.info("Airing reminders truncated to \(Self.maximumScheduled, privacy: .public) of \(slots.count, privacy: .public)")
		}
	}

	/// Removes every pending notification the scheduler owns.
	func cancelAll() async {
		let center = UNUserNotificationCenter.current()
		let identifiers = await center.pendingNotificationRequests()
			.map { $0.identifier }
			.filter { $0.hasPrefix(Self.identifierPrefix) }

		center.removePendingNotificationRequests(withIdentifiers: identifiers)
	}

	/// Repeats the given reminder an hour from now.
	///
	/// - Parameter content: The reminder the user snoozed.
	func snooze(_ content: UNNotificationContent) async {
		guard let mutableContent = content.mutableCopy() as? UNMutableNotificationContent else { return }

		let request = UNNotificationRequest(
			identifier: "\(Self.identifierPrefix)snoozed-\(UUID().uuidString)",
			content: mutableContent,
			trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3600.0, repeats: false)
		)

		try? await UNUserNotificationCenter.current().add(request)
	}

	/// Whether the user has allowed notifications.
	///
	/// - Returns: `true` when notifications may be scheduled.
	private func hasAuthorization() async -> Bool {
		let settings = await UNUserNotificationCenter.current().notificationSettings()

		return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
	}

	/// The broadcasts the account is reminded of.
	///
	/// - Parameter userSlug: The user's account slug.
	///
	/// - Returns: The broadcasts, soonest first.
	private func slots(forUserSlug userSlug: String) async -> [AiringSlot] {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true

		return await context.perform {
			let request = LocalLibraryEntry.fetchRequest()
			request.predicate = NSPredicate(
				format: "userSlug == %@ AND kindRaw == %d AND isReminded == YES",
				userSlug,
				Int64(LibraryKind.shows.rawValue)
			)
			request.relationshipKeyPathsForPrefetching = ["trackable"]

			guard let entries = try? context.fetch(request) else { return [] }

			var trackables: [String: LocalTrackable] = [:]
			for entry in entries {
				guard let trackable = entry.trackable else { continue }
				trackables[trackable.trackableID] = trackable
			}

			guard !trackables.isEmpty else { return [] }

			let episodes = LocalEpisodeSnapshot.upcoming(forTrackableIDs: Set(trackables.keys), userSlug: userSlug, in: context)

			return episodes.compactMap { episode -> AiringSlot? in
				guard let trackable = trackables[episode.trackableID] else { return nil }
				guard let title = trackable.title else { return nil }
				guard let startedAt = episode.startedAt else { return nil }

				return AiringSlot(
					showID: trackable.trackableID,
					showTitle: title,
					episodeID: episode.episodeID,
					episodeNumber: Int(episode.number),
					episodeNumberTotal: Int(episode.numberTotal),
					artURLStrings: [episode.bannerURL, trackable.bannerURL, trackable.posterURL].compactMap(\.self),
					airingDate: startedAt
				)
			}
		}
	}

	/// Adds the notification for the given broadcast.
	///
	/// - Parameters:
	///    - slot: The broadcast to schedule.
	///    - playsSound: Whether the reminder plays a sound.
	private func schedule(_ slot: AiringSlot, playsSound: Bool) async {
		let content = UNMutableNotificationContent()
		content.title = slot.showTitle
		content.body = slot.body
		content.categoryIdentifier = Self.categoryIdentifier
		content.userInfo = slot.userInfo

		if playsSound {
			content.sound = .default
		}

		if let attachment = await LibraryArtStore.shared.notificationAttachment(forURLStrings: slot.artURLStrings) {
			content.attachments = [attachment]
		}

		let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: slot.airingDate)

		let request = UNNotificationRequest(
			identifier: slot.identifier,
			content: content,
			trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
		)

		do {
			try await UNUserNotificationCenter.current().add(request)
		} catch {
			airingLogger.error("Scheduling an airing reminder failed: \(error.localizedDescription, privacy: .public)")
		}
	}
}

// MARK: - Debug
#if DEBUG
extension AiringNotificationScheduler {
	/// Fires a reminder for the soonest reminded show a few seconds from now.
	///
	/// - Returns: The name of the show the reminder fires for.
	func fireTestReminder() async -> String? {
		let isAllowed = await MainActor.run { UserSettings.airingRemindersAllowed }
		guard isAllowed else { return nil }
		guard let userSlug = User.current?.attributes.slug else { return nil }
		guard let slot = await self.slots(forUserSlug: userSlug).first else { return nil }

		let content = UNMutableNotificationContent()
		content.title = slot.showTitle
		content.body = slot.body
		content.categoryIdentifier = Self.categoryIdentifier
		content.userInfo = slot.userInfo
		content.sound = .default

		if let attachment = await LibraryArtStore.shared.notificationAttachment(forURLStrings: slot.artURLStrings) {
			content.attachments = [attachment]
		} else {
			airingLogger.error("A test reminder has no art among \(slot.artURLStrings.count, privacy: .public) URLs")
		}

		let request = UNNotificationRequest(
			identifier: "\(Self.identifierPrefix)test",
			content: content,
			trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
		)

		do {
			try await UNUserNotificationCenter.current().add(request)
			return slot.showTitle
		} catch {
			airingLogger.error("Firing a test reminder failed: \(error.localizedDescription, privacy: .public)")
			return nil
		}
	}
}
#endif
