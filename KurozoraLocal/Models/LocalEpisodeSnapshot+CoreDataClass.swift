//
//  LocalEpisodeSnapshot+CoreDataClass.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

@objc(LocalEpisodeSnapshot)
class LocalEpisodeSnapshot: NSManagedObject {
	// MARK: - Functions
	/// Replaces the account's stored episodes with the given window.
	///
	/// - Parameters:
	///    - window: The episodes the server returned.
	///    - userSlug: The user's account slug.
	///    - context: The context to write into.
	static func replace(with window: [LibrarySyncEpisode], userSlug: String, in context: NSManagedObjectContext) {
		let keptIDs = Set(window.map { $0.id })

		let staleRequest = LocalEpisodeSnapshot.fetchRequest()
		staleRequest.predicate = NSPredicate(format: "userSlug == %@ AND NOT (episodeID IN %@)", userSlug, keptIDs)

		for snapshot in (try? context.fetch(staleRequest)) ?? [] {
			context.delete(snapshot)
		}

		for row in window {
			let snapshot = Self.upsert(forEpisodeID: row.id, userSlug: userSlug, in: context)
			snapshot.trackableID = row.trackableID
			snapshot.number = Int64(row.number)
			snapshot.numberTotal = Int64(row.numberTotal)
			snapshot.seasonNumber = Int64(row.seasonNumber)
			snapshot.startedAt = row.startedAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
			snapshot.bannerURL = row.bannerURL
		}
	}

	/// Fetches or creates the snapshot for the given episode.
	///
	/// - Parameters:
	///    - episodeID: The identifier of the episode.
	///    - userSlug: The user's account slug.
	///    - context: The context to read from.
	///
	/// - Returns: The snapshot the episode is written into.
	private static func upsert(forEpisodeID episodeID: String, userSlug: String, in context: NSManagedObjectContext) -> LocalEpisodeSnapshot {
		if let existing = Self.fetch(forEpisodeID: episodeID, userSlug: userSlug, in: context) {
			return existing
		}

		let snapshot = LocalEpisodeSnapshot(context: context)
		snapshot.episodeID = episodeID
		snapshot.userSlug = userSlug
		return snapshot
	}

	/// Fetches the snapshot matching the given identity.
	///
	/// - Parameters:
	///    - episodeID: The identifier of the episode.
	///    - userSlug: The user's account slug.
	///    - context: The context to read from.
	///
	/// - Returns: The matching snapshot.
	static func fetch(forEpisodeID episodeID: String, userSlug: String, in context: NSManagedObjectContext) -> LocalEpisodeSnapshot? {
		let request = LocalEpisodeSnapshot.fetchRequest()
		request.predicate = NSPredicate(format: "userSlug == %@ AND episodeID == %@", userSlug, episodeID)
		request.fetchLimit = 1
		return try? context.fetch(request).first
	}

	/// The episodes the given shows have yet to air.
	///
	/// - Parameters:
	///    - trackableIDs: The identifiers of the shows.
	///    - userSlug: The user's account slug.
	///    - context: The context to read from.
	///
	/// - Returns: The episodes, soonest first.
	static func upcoming(forTrackableIDs trackableIDs: Set<String>, userSlug: String, in context: NSManagedObjectContext) -> [LocalEpisodeSnapshot] {
		let request = LocalEpisodeSnapshot.fetchRequest()
		request.predicate = NSPredicate(
			format: "userSlug == %@ AND trackableID IN %@ AND startedAt > %@",
			userSlug,
			trackableIDs,
			Date() as NSDate
		)
		request.sortDescriptors = [NSSortDescriptor(key: "startedAt", ascending: true)]
		return (try? context.fetch(request)) ?? []
	}

	/// Removes every stored episode belonging to the given account.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - context: The context to write into.
	static func deleteAll(forUserSlug userSlug: String, in context: NSManagedObjectContext) {
		let request = LocalEpisodeSnapshot.fetchRequest()
		request.predicate = NSPredicate(format: "userSlug == %@", userSlug)

		for snapshot in (try? context.fetch(request)) ?? [] {
			context.delete(snapshot)
		}
	}
}
