//
//  LibraryStore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit
import os.log

private let storeLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibraryStore")

/// Manages CRUD operations for the locally-cached library.
@MainActor
final class LibraryStore {
	// MARK: - Properties
	/// Returns the singleton `LibraryStore` instance.
	static let shared = LibraryStore()

	private var viewContext: NSManagedObjectContext {
		return PersistenceController.shared.viewContext
	}

	/// Main-thread snapshot of every entry's `LibraryAttributes`, keyed by
	/// `"{userSlug}::{kindRaw}::{trackableID}"`.
	private var overlayCache: [String: LibraryAttributes] = [:]
	private var overlayCacheToken: NSObjectProtocol?
	private var hydratedUserSlugs: Set<String> = []

	// MARK: - Initializers
	private init() {
		let viewContextID = ObjectIdentifier(PersistenceController.shared.viewContext)

		// The token is never removed because the singleton lives for the process.
		self.overlayCacheToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { notification in
			// Deleted rows lose their values once the saving thread moves on, so their identities are read here before hopping to the main actor.
			guard let change = LibraryEntrySaveChange(notification: notification, viewContextID: viewContextID) else { return }

			Task { @MainActor in
				LibraryStore.shared.refreshOverlayCache(with: change)
			}
		}
	}

	// MARK: - Read
	/// Returns every live (non-tombstone) library entry for the given account and kind,
	/// sorted by most recently touched.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - kind: The library kind to fetch.
	///
	/// - Returns: An array of `LocalLibraryEntry` sorted by `updatedAt` descending.
	func entries(forUserSlug userSlug: String, kind: LibraryKind) -> [LocalLibraryEntry] {
		let request = LocalLibraryEntry.fetchRequest()
		request.predicate = NSPredicate(
			format: "userSlug == %@ AND kindRaw == %d",
			userSlug,
			Int64(kind.rawValue)
		)
		request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

		do {
			return try self.viewContext.fetch(request)
		} catch {
			storeLogger.error("Fetch failed: \(error.localizedDescription)")
			return []
		}
	}

	/// Returns a paginated slice of library entries filtered by status and sorted by the
	/// given criteria.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - kind: The library kind to fetch.
	///    - status: The status to filter by, or `.none` to include every status.
	///    - sortType: The local-supportable sort dimension. See ``sortDescriptor(for:option:)``.
	///    - sortOption: The sort direction.
	///    - offset: The number of entries to skip.
	///    - limit: The maximum number of entries to return.
	///
	/// - Returns: The matching `LocalLibraryEntry` slice.
	func entries(forUserSlug userSlug: String, kind: LibraryKind, status: LibraryStatus, sortType: LibrarySortType, sortOption: LibrarySortOption, offset: Int, limit: Int) -> [LocalLibraryEntry] {
		let request = LocalLibraryEntry.fetchRequest()
		request.predicate = Self.predicate(forUserSlug: userSlug, kind: kind, status: status)
		request.sortDescriptors = Self.sortDescriptors(for: sortType, option: sortOption)
		request.fetchOffset = offset
		request.fetchLimit = limit

		do {
			return try self.viewContext.fetch(request)
		} catch {
			storeLogger.error("Paginated fetch failed: \(error.localizedDescription)")
			return []
		}
	}

	/// Returns a paginated slice of library entries matching the given query.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - kind: The library kind to fetch.
	///    - query: The user's typed query.
	///    - status: The status to filter by, or `.none` for every status.
	///    - sortType: Unused.
	///    - sortOption: Unused.
	///    - offset: The number of matches to skip after ranking.
	///    - limit: The maximum number of matches to return after ranking.
	///
	/// - Returns: Matching `LocalLibraryEntry` rows in relevance-descending order.
	func search(forUserSlug userSlug: String, kind: LibraryKind, query: String, status: LibraryStatus = .none, sortType: LibrarySortType = .none, sortOption: LibrarySortOption = .none, offset: Int = 0, limit: Int = 100, filter: SearchFilter? = nil) -> [LocalLibraryEntry] {
		let matches = LibrarySearchIndex.shared.search(query, forUserSlug: userSlug, kind: kind, status: status, filter: filter)

		return Array(matches.dropFirst(offset).prefix(limit))
	}

	/// Returns the total number of live entries for the given identity and status.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - kind: The library kind.
	///    - status: The status to filter by, or `.none` to count every status.
	///
	/// - Returns: The count, or `0` if the count query fails.
	func count(forUserSlug userSlug: String, kind: LibraryKind, status: LibraryStatus) -> Int {
		let request = LocalLibraryEntry.fetchRequest()
		request.predicate = Self.predicate(forUserSlug: userSlug, kind: kind, status: status)

		do {
			return try self.viewContext.count(for: request)
		} catch {
			storeLogger.error("Count failed: \(error.localizedDescription)")
			return 0
		}
	}

	/// The entry count per media type.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - kind: The library kind.
	///    - status: The status to filter by, or `.none` to count every status.
	///
	/// - Returns: The counts keyed by localized media type name.
	func mediaTypeCounts(forUserSlug userSlug: String, kind: LibraryKind, status: LibraryStatus) -> [String: Int] {
		let request = LocalLibraryEntry.fetchRequest()
		request.predicate = Self.predicate(forUserSlug: userSlug, kind: kind, status: status)
		request.relationshipKeyPathsForPrefetching = ["trackable"]

		do {
			let entries = try self.viewContext.fetch(request)
			return entries.reduce(into: [:]) { counts, entry in
				guard let name = entry.trackable?.mediaTypeName, !name.isEmpty else { return }
				counts[name, default: 0] += 1
			}
		} catch {
			storeLogger.error("Media type count failed: \(error.localizedDescription)")
			return [:]
		}
	}

	private static func predicate(forUserSlug userSlug: String, kind: LibraryKind, status: LibraryStatus) -> NSPredicate {
		if status == .none {
			return NSPredicate(
				format: "userSlug == %@ AND kindRaw == %d",
				userSlug,
				Int64(kind.rawValue)
			)
		}
		return NSPredicate(
			format: "userSlug == %@ AND kindRaw == %d AND status == %d",
			userSlug,
			Int64(kind.rawValue),
			Int64(status.rawValue)
		)
	}

	private static func sortDescriptors(for sortType: LibrarySortType, option: LibrarySortOption) -> [NSSortDescriptor] {
		switch sortType {
		case .none:
			return [NSSortDescriptor(key: "updatedAt", ascending: false)]
		case .alphabetically:
			return [NSSortDescriptor(key: "trackable.sortTitle", ascending: option != .descending, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
		case .popularity:
			// Lower rank is more popular.
			return [NSSortDescriptor(key: "trackable.popularityRank", ascending: option != .least)]
		case .date:
			return [NSSortDescriptor(key: "createdAt", ascending: option == .oldest)]
		case .rating:
			return [NSSortDescriptor(key: "trackable.publicRating", ascending: option == .worst)]
		case .myRating:
			return [NSSortDescriptor(key: "review.score", ascending: option == .worst)]
		}
	}

	/// Returns the entry for the given trackable identifier, if present.
	///
	/// - Parameters:
	///    - trackableID: The identifier of the anime/manga/game model.
	///    - userSlug: The user's account slug.
	///    - kind: The library kind to look up in.
	///
	/// - Returns: The matching `LocalLibraryEntry`.
	func entry(forTrackableID trackableID: String, userSlug: String, kind: LibraryKind) -> LocalLibraryEntry? {
		let request = LocalLibraryEntry.fetchRequest()
		request.predicate = NSPredicate(
			format: "userSlug == %@ AND kindRaw == %d AND trackableID == %@",
			userSlug,
			Int64(kind.rawValue),
			trackableID
		)
		request.fetchLimit = 1
		return try? self.viewContext.fetch(request).first
	}

	/// Returns the entry registered in the view context under the given object identifier.
	///
	/// - Parameter objectID: The Core Data identifier of the entry.
	///
	/// - Returns: The matching `LocalLibraryEntry`.
	func entry(for objectID: NSManagedObjectID) -> LocalLibraryEntry? {
		return try? self.viewContext.existingObject(with: objectID) as? LocalLibraryEntry
	}

	/// Returns the trackable's library attributes from the local store.
	///
	/// - Parameters:
	///    - trackableID: The identifier of the anime/manga/game model.
	///    - kind: The library kind to look up in.
	///
	/// - Returns: The attributes.
	func effectiveLibrary(forTrackableID trackableID: String, kind: LibraryKind) -> LibraryAttributes? {
		guard let slug = User.current?.attributes.slug else { return nil }
		self.hydrateOverlayCacheIfNeeded(forUserSlug: slug)
		let key = Self.overlayCacheKey(userSlug: slug, kind: kind, trackableID: trackableID)
		return self.overlayCache[key]
	}

	// MARK: - Overlay cache
	/// Builds the cache key for a `(userSlug, kind, trackableID)` triple.
	private static func overlayCacheKey(userSlug: String, kind: LibraryKind, trackableID: String) -> String {
		return "\(userSlug)::\(kind.rawValue)::\(trackableID)"
	}

	/// Builds a `LibraryAttributes` snapshot from a `LocalLibraryEntry`.
	///
	/// - Note: Safe to call from any thread holding a valid reference to the entry's properties.
	private nonisolated static func snapshotAttributes(from entry: LocalLibraryEntry) -> LibraryAttributes {
		var attributes = LibraryAttributes()
		attributes.isFavorited = entry.isFavorited
		attributes.isReminded = entry.isReminded
		attributes.isHidden = entry.isHidden
		attributes.status = entry.libraryStatus
		attributes.rewatchCount = Int(entry.rewatchCount)
		attributes.rating = entry.review?.score?.doubleValue
		attributes.review = entry.review?.text
		attributes.isSpoiler = entry.review?.isSpoiler?.boolValue
		attributes.recommendation = entry.review?.reviewRecommendation
		return attributes
	}

	/// Hydrates the overlay cache from a background context on first access for a user.
	private func hydrateOverlayCacheIfNeeded(forUserSlug userSlug: String) {
		guard !self.hydratedUserSlugs.contains(userSlug) else { return }
		self.hydratedUserSlugs.insert(userSlug)

		Task.detached(priority: .utility) {
			let context = PersistenceController.shared.container.newBackgroundContext()
			let snapshot: [(String, LibraryAttributes)] = await context.perform {
				let request = LocalLibraryEntry.fetchRequest()
				request.predicate = NSPredicate(format: "userSlug == %@", userSlug)
				guard let rows = try? context.fetch(request) else { return [] }
				return rows.map { entry in
					let key = "\(entry.userSlug)::\(entry.kindRaw)::\(entry.trackableID)"
					return (key, Self.snapshotAttributes(from: entry))
				}
			}

			await MainActor.run {
				for (key, attributes) in snapshot {
					LibraryStore.shared.overlayCache[key] = attributes
				}
				NotificationCenter.default.post(name: .KLibraryStoreDidHydrate, object: nil)
			}
		}
	}

	/// Merges a save into the view context and applies its changes onto the overlay cache.
	///
	/// - Parameter change: The save to apply.
	func refreshOverlayCache(with change: LibraryEntrySaveChange) {
		change.merge(into: self.viewContext)
		LibrarySearchIndex.shared.apply(change)

		for objectID in change.changedEntryObjectIDs {
			guard let entry = self.entry(for: objectID) else { continue }
			let key = Self.overlayCacheKey(userSlug: entry.userSlug, kind: entry.kind, trackableID: entry.trackableID)
			self.overlayCache[key] = Self.snapshotAttributes(from: entry)
		}

		for removed in change.removedEntries {
			// The sync replaces an outbox row with the server's own, so the deleted row may share
			// its key with a surviving entry that must stay cached.
			let key = Self.overlayCacheKey(userSlug: removed.userSlug, kind: removed.kind, trackableID: removed.trackableID)
			if let survivor = self.entry(forTrackableID: removed.trackableID, userSlug: removed.userSlug, kind: removed.kind) {
				self.overlayCache[key] = Self.snapshotAttributes(from: survivor)
			} else {
				self.overlayCache.removeValue(forKey: key)
			}
		}
	}

	/// Builds a `LibraryAttributes` value from the matching local entry.
	///
	/// - Parameters:
	///    - trackableID: The identifier of the anime/manga/game model.
	///    - userSlug: The user's account slug.
	///    - kind: The library kind to look up in.
	///
	/// - Returns: The overlay attributes.
	func overlay(forTrackableID trackableID: String, userSlug: String, kind: LibraryKind) -> LibraryAttributes? {
		guard let entry = self.entry(forTrackableID: trackableID, userSlug: userSlug, kind: kind) else { return nil }

		var attributes = LibraryAttributes()
		attributes.isFavorited = entry.isFavorited
		attributes.isReminded = entry.isReminded
		attributes.isHidden = entry.isHidden
		attributes.status = entry.libraryStatus
		attributes.rewatchCount = Int(entry.rewatchCount)
		attributes.rating = entry.review?.score?.doubleValue
		attributes.review = entry.review?.text
		attributes.isSpoiler = entry.review?.isSpoiler?.boolValue
		attributes.recommendation = entry.review?.reviewRecommendation
		return attributes
	}

	/// Indicates whether the local store has any entries for the given account and kind.
	///
	/// - Parameters:
	///    - userSlug: The user's account slug.
	///    - kind: The library kind to check.
	///
	/// - Returns: `true` when the store has no entries for `(userSlug, kind)`.
	func isEmpty(forUserSlug userSlug: String, kind: LibraryKind) -> Bool {
		let request = LocalLibraryEntry.fetchRequest()
		request.predicate = NSPredicate(
			format: "userSlug == %@ AND kindRaw == %d",
			userSlug,
			Int64(kind.rawValue)
		)
		request.fetchLimit = 1

		do {
			return try self.viewContext.count(for: request) == 0
		} catch {
			storeLogger.error("Count failed: \(error.localizedDescription)")
			return true
		}
	}

	// MARK: - Write
	/// Applies a sync batch and saves, upserting non-tombstones and removing tombstones.
	///
	/// - Parameters:
	///    - entries: The rows from a `LibrarySyncResponse.relationships.libraries` batch.
	///    - userSlug: The user's account slug.
	///    - kind: The library kind the batch belongs to.
	func apply(_ entries: [LibrarySyncEntry], forUserSlug userSlug: String, kind: LibraryKind) {
		for row in entries {
			LocalLibraryEntry.apply(row, userSlug: userSlug, kind: kind, in: self.viewContext)
		}
		PersistenceController.shared.save(self.viewContext)
	}

	// MARK: - Optimistic Writes
	/// Updates the local entry's favorite state immediately after a successful server toggle.
	func applyFavorite(_ isFavorited: Bool, forTrackableID trackableID: String, userSlug: String, kind: LibraryKind) {
		guard let entry = self.entry(forTrackableID: trackableID, userSlug: userSlug, kind: kind) else { return }
		let now = Date()
		entry.isFavorited = isFavorited
		entry.favoritedAt = isFavorited ? (entry.favoritedAt ?? now) : nil
		entry.updatedAt = now
		PersistenceController.shared.save(self.viewContext)
	}

	/// Updates the local entry's reminder state immediately after a successful server toggle.
	func applyReminder(_ isReminded: Bool, forTrackableID trackableID: String, userSlug: String, kind: LibraryKind) {
		guard let entry = self.entry(forTrackableID: trackableID, userSlug: userSlug, kind: kind) else { return }
		let now = Date()
		entry.isReminded = isReminded
		entry.remindedAt = isReminded ? (entry.remindedAt ?? now) : nil
		entry.updatedAt = now
		PersistenceController.shared.save(self.viewContext)
	}

	func applyRating(score: Double?, description: String?, isSpoiler: Bool?, recommendation: ReviewRecommendation?, forTrackableID trackableID: String, userSlug: String, kind: LibraryKind) {
		guard let entry = self.entry(forTrackableID: trackableID, userSlug: userSlug, kind: kind) else { return }
		let now = Date()
		let review = entry.review ?? LocalReview(context: self.viewContext)
		review.entry = entry
		review.score = score.map { NSNumber(value: $0) }
		if description != nil {
			review.text = description
		}
		if let isSpoiler {
			review.isSpoiler = NSNumber(value: isSpoiler)
		}
		if let recommendation {
			review.reviewRecommendation = recommendation
		}
		review.updatedAt = now
		if review.createdAt == nil, score != nil {
			review.createdAt = now
		}
		entry.updatedAt = now
		PersistenceController.shared.save(self.viewContext)
	}

	func applyRatingRemoved(forTrackableID trackableID: String, userSlug: String, kind: LibraryKind) {
		guard let entry = self.entry(forTrackableID: trackableID, userSlug: userSlug, kind: kind) else { return }
		if let review = entry.review {
			self.viewContext.delete(review)
		}
		entry.updatedAt = Date()
		PersistenceController.shared.save(self.viewContext)
	}

	/// Updates the local entry's library status.
	///
	/// - Parameters:
	///    - status: The library status to assign.
	///    - trackableID: The identifier of the anime/manga/game model.
	///    - userSlug: The user's account slug.
	///    - kind: The library kind to update.
	///    - seed: The display snapshot for creating the entry when none exists.
	///
	/// - Returns: `true` when the entry was updated or created.
	@discardableResult
	func applyStatus(_ status: LibraryStatus, forTrackableID trackableID: String, userSlug: String, kind: LibraryKind, seed: LibraryOutboxSeed? = nil) -> Bool {
		if let entry = self.entry(forTrackableID: trackableID, userSlug: userSlug, kind: kind) {
			entry.libraryStatus = status
			entry.updatedAt = Date()
			PersistenceController.shared.save(self.viewContext)
			return true
		}

		guard let seed else { return false }

		let now = Date()
		let entry = LocalLibraryEntry(context: self.viewContext)
		entry.userSlug = userSlug
		entry.kindRaw = Int64(kind.rawValue)
		entry.remoteID = LocalLibraryEntry.localRemoteIDPrefix + UUID().uuidString
		entry.trackableID = trackableID
		entry.libraryStatus = status
		entry.createdAt = now
		entry.updatedAt = now
		let trackable = LocalTrackable.fetch(trackableID: trackableID, kind: kind, in: self.viewContext) ?? LocalTrackable(context: self.viewContext)
		trackable.kindRaw = Int64(kind.rawValue)
		trackable.trackableID = trackableID
		trackable.title = seed.title
		trackable.sortTitle = seed.sortTitle
		trackable.tagline = seed.tagline
		trackable.posterURL = seed.posterURL
		trackable.posterBackgroundColor = seed.posterBackgroundColor
		trackable.bannerURL = seed.bannerURL
		trackable.bannerBackgroundColor = seed.bannerBackgroundColor
		trackable.genresLocalized = seed.genresLocalized
		trackable.statusName = seed.statusName
		trackable.airingDate = seed.airingDate
		trackable.durationCount = seed.durationCount.map { NSNumber(value: $0) }
		trackable.mediaTypeName = seed.mediaTypeName
		trackable.popularityRank = seed.popularityRank.map { NSNumber(value: $0) }
		trackable.publicRating = seed.publicRating.map { NSNumber(value: $0) }
		trackable.slug = seed.slug
		entry.trackable = trackable

		PersistenceController.shared.save(self.viewContext)
		return true
	}

	/// Updates the local entry's hidden state immediately after a successful server update.
	func applyHidden(_ isHidden: Bool, forTrackableID trackableID: String, userSlug: String, kind: LibraryKind) {
		guard let entry = self.entry(forTrackableID: trackableID, userSlug: userSlug, kind: kind) else { return }
		entry.isHidden = isHidden
		entry.updatedAt = Date()
		PersistenceController.shared.save(self.viewContext)
	}

	/// Updates the local entry's rewatch count immediately after a successful server update.
	func applyRewatchCount(_ count: Int, forTrackableID trackableID: String, userSlug: String, kind: LibraryKind) {
		guard let entry = self.entry(forTrackableID: trackableID, userSlug: userSlug, kind: kind) else { return }
		entry.rewatchCount = Int64(count)
		entry.updatedAt = Date()
		PersistenceController.shared.save(self.viewContext)
	}

	/// Removes the local entry for the trackable immediately after a successful server delete.
	func applyRemoved(forTrackableID trackableID: String, userSlug: String, kind: LibraryKind) {
		guard let entry = self.entry(forTrackableID: trackableID, userSlug: userSlug, kind: kind) else { return }
		let artURLStrings = entry.artURLStrings

		self.viewContext.delete(entry)
		PersistenceController.shared.save(self.viewContext)
		LocalLibraryEntry.purgeUnreferencedArt(artURLStrings, in: self.viewContext)
	}

	// MARK: - Delete
	/// Removes every cached library entry and sync cursor for the given account.
	///
	/// - Parameter userSlug: The user's account slug.
	func clear(forUserSlug userSlug: String) {
		let entryRequest = LocalLibraryEntry.fetchRequest()
		entryRequest.predicate = NSPredicate(format: "userSlug == %@", userSlug)
		let cursorRequest = LocalSyncCursor.fetchRequest()
		cursorRequest.predicate = NSPredicate(format: "userSlug == %@", userSlug)

		do {
			for entry in try self.viewContext.fetch(entryRequest) {
				self.viewContext.delete(entry)
			}
			for cursor in try self.viewContext.fetch(cursorRequest) {
				self.viewContext.delete(cursor)
			}
			self.deleteOrphanedTrackables()
			PersistenceController.shared.save(self.viewContext)
		} catch {
			storeLogger.error("Clear failed: \(error.localizedDescription)")
		}

		// Drop the hydration marker so a fresh sign-in re-pulls the snapshot.
		self.hydratedUserSlugs.remove(userSlug)
		let prefix = "\(userSlug)::"
		self.overlayCache = self.overlayCache.filter { !$0.key.hasPrefix(prefix) }

		LibrarySearchIndex.shared.clear(forUserSlug: userSlug)
	}

	/// Removes the trackables no account keeps an entry for.
	private func deleteOrphanedTrackables() {
		let request = LocalTrackable.fetchRequest()
		request.predicate = NSPredicate(format: "entries.@count == 0")

		guard let orphaned = try? self.viewContext.fetch(request) else { return }

		for trackable in orphaned {
			self.viewContext.delete(trackable)
		}
	}
}
