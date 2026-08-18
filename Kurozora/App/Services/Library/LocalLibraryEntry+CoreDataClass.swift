//
//  LocalLibraryEntry+CoreDataClass.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

@objc(LocalLibraryEntry)
class LocalLibraryEntry: NSManagedObject {
	// MARK: - Properties
	/// The library kind this entry belongs to.
	var kind: LibraryKind {
		get { LibraryKind(rawValue: Int(self.kindRaw)) ?? .shows }
		set { self.kindRaw = Int64(newValue.rawValue) }
	}

	/// The library status assigned to the entry.
	var libraryStatus: LibraryStatus {
		get { LibraryStatus(rawValue: Int(self.status)) ?? .none }
		set { self.status = Int64(newValue.rawValue) }
	}

	/// The `remoteID` prefix marking a row created offline, ahead of the server assigning a real identifier.
	static let localRemoteIDPrefix = "local-"

	// MARK: - Functions
	/// Upserts an entry from a sync delta row into the given context.
	///
	/// - Parameters:
	///    - row: The sync delta row.
	///    - userSlug: The account slug owning the row.
	///    - kind: The library kind the row belongs to.
	///    - context: The managed object context.
	///
	/// - Returns: The upserted `LocalLibraryEntry`.
	@discardableResult
	static func apply(_ row: LibrarySyncEntry, userSlug: String, kind: LibraryKind, in context: NSManagedObjectContext) -> LocalLibraryEntry? {
		if row.deletedAt != nil {
			Self.delete(remoteID: row.id, userSlug: userSlug, kind: kind, in: context)
			return nil
		}

		let entry = Self.fetch(remoteID: row.id, userSlug: userSlug, kind: kind, in: context)
			?? LocalLibraryEntry(context: context)

		entry.userSlug = userSlug
		entry.kindRaw = Int64(kind.rawValue)
		entry.remoteID = row.id
		entry.trackableID = row.trackableID
		entry.status = Int64(row.status)
		entry.rewatchCount = Int64(row.rewatchCount)
		entry.isHidden = row.isHidden
		entry.startedAt = row.startedAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
		entry.endedAt = row.endedAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
		entry.createdAt = row.createdAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
		entry.updatedAt = row.updatedAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
		entry.deletedAt = nil

		entry.isFavorited = row.isFavorited
		entry.favoritedAt = row.favoritedAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
		entry.isReminded = row.isReminded
		entry.remindedAt = row.remindedAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }

		if let review = row.review {
			entry.reviewID = review.id
			entry.score = NSNumber(value: review.score)
			entry.reviewDescription = review.description
			entry.note = review.note
			entry.isSpoiler = NSNumber(value: review.isSpoiler)
			entry.reviewCreatedAt = review.createdAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
			entry.reviewUpdatedAt = review.updatedAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
		} else {
			entry.reviewID = nil
			entry.score = nil
			entry.reviewDescription = nil
			entry.note = nil
			entry.isSpoiler = nil
			entry.reviewCreatedAt = nil
			entry.reviewUpdatedAt = nil
		}

		entry.slug = row.slug
		entry.title = row.title
		entry.sortTitle = Self.normalizedSortKey(row.sortTitle ?? row.title)
		entry.tagline = row.tagline
		entry.posterURL = row.posterURL
		entry.posterBackgroundColor = row.posterBackgroundColor
		entry.bannerURL = row.bannerURL
		entry.bannerBackgroundColor = row.bannerBackgroundColor
		entry.genresLocalized = row.genresLocalized
		entry.statusName = row.statusName
		entry.airingDate = row.airingDate.map { Date(timeIntervalSince1970: TimeInterval($0)) }
		entry.durationCount = row.durationCount.map { NSNumber(value: $0) }
		entry.mediaTypeName = row.mediaTypeName
		entry.popularityRank = row.popularityRank.map { NSNumber(value: $0) }
		entry.publicRating = row.publicRating.map { NSNumber(value: $0) }

		Self.deleteLocalPlaceholder(userSlug: userSlug, kind: kind, trackableID: row.trackableID, excludingRemoteID: row.id, in: context)

		return entry
	}

	/// Removes an offline-add placeholder row once the server row for the same trackable has landed.
	private static func deleteLocalPlaceholder(userSlug: String, kind: LibraryKind, trackableID: String, excludingRemoteID: String, in context: NSManagedObjectContext) {
		let request = LocalLibraryEntry.fetchRequest()
		request.predicate = NSPredicate(
			format: "userSlug == %@ AND kindRaw == %d AND trackableID == %@ AND remoteID BEGINSWITH %@ AND remoteID != %@",
			userSlug,
			Int64(kind.rawValue),
			trackableID,
			LocalLibraryEntry.localRemoteIDPrefix,
			excludingRemoteID
		)
		guard let placeholders = try? context.fetch(request) else { return }
		for placeholder in placeholders {
			context.delete(placeholder)
		}
	}

	/// Removes the library entry matching the given remote identity, if present.
	///
	/// - Parameters:
	///    - remoteID: The server-side primary key of the entry.
	///    - userSlug: The account slug owning the entry.
	///    - kind: The library kind of the entry.
	///    - context: The managed object context.
	static func delete(remoteID: String, userSlug: String, kind: LibraryKind, in context: NSManagedObjectContext) {
		guard let existing = Self.fetch(remoteID: remoteID, userSlug: userSlug, kind: kind, in: context) else { return }
		context.delete(existing)
	}

	/// Returns a sort key derived from the supplied title, lowercased with the leading English article stripped.
	///
	/// - Parameter value: The candidate title or sort key from the server.
	///
	/// - Returns: A normalised sort key.
	static func normalizedSortKey(_ value: String?) -> String? {
		guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
		let lowered = trimmed.lowercased()
		for prefix in ["the ", "a ", "an "] where lowered.hasPrefix(prefix) {
			return String(lowered.dropFirst(prefix.count))
		}
		return lowered
	}

	/// Fetches the entry matching the given identity, if present.
	private static func fetch(remoteID: String, userSlug: String, kind: LibraryKind, in context: NSManagedObjectContext) -> LocalLibraryEntry? {
		let request = LocalLibraryEntry.fetchRequest()
		request.predicate = NSPredicate(
			format: "userSlug == %@ AND kindRaw == %d AND remoteID == %@",
			userSlug,
			Int64(kind.rawValue),
			remoteID
		)
		request.fetchLimit = 1
		return try? context.fetch(request).first
	}
}
