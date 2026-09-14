//
//  LocalTrackable+CoreDataClass.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

@objc(LocalTrackable)
class LocalTrackable: NSManagedObject {
	// MARK: - Properties
	/// The library kind the trackable belongs to.
	var kind: LibraryKind {
		get { LibraryKind(rawValue: Int(self.kindRaw)) ?? .shows }
		set { self.kindRaw = Int64(newValue.rawValue) }
	}

	/// The source URLs of the trackable's stored art.
	var artURLStrings: [String] {
		return [self.posterURL, self.bannerURL].compactMap(\.self)
	}

	// MARK: - Functions
	/// Upserts the trackable a sync delta row describes.
	///
	/// - Parameters:
	///    - row: The sync delta row.
	///    - context: The managed object context.
	///
	/// - Returns: The upserted `LocalTrackable`.
	@discardableResult
	static func apply(_ row: LibrarySyncTrackable, in context: NSManagedObjectContext) -> LocalTrackable {
		let kind = LibraryKind(rawValue: row.kind) ?? .shows
		let trackable = Self.fetch(trackableID: row.id, kind: kind, in: context) ?? LocalTrackable(context: context)

		trackable.kindRaw = Int64(kind.rawValue)
		trackable.trackableID = row.id
		trackable.slug = row.slug
		trackable.title = row.title
		trackable.sortTitle = Self.normalizedSortKey(row.sortTitle ?? row.title)
		trackable.tagline = row.tagline
		trackable.posterURL = row.posterURL
		trackable.posterBackgroundColor = row.posterBackgroundColor
		trackable.bannerURL = row.bannerURL
		trackable.bannerBackgroundColor = row.bannerBackgroundColor
		trackable.genresLocalized = row.genresLocalized
		trackable.mediaTypeID = row.mediaTypeID.map { NSNumber(value: $0) }
		trackable.mediaTypeName = row.mediaTypeName
		trackable.statusID = row.statusID.map { NSNumber(value: $0) }
		trackable.statusName = row.statusName
		trackable.airingDate = row.airingDate.map { Date(timeIntervalSince1970: TimeInterval($0)) }
		trackable.durationCount = row.durationCount.map { NSNumber(value: $0) }
		trackable.popularityRank = row.popularityRank.map { NSNumber(value: $0) }
		trackable.publicRating = row.publicRating.map { NSNumber(value: $0) }
		trackable.tvRatingID = row.tvRatingID.map { NSNumber(value: $0) }
		trackable.sourceID = row.sourceID.map { NSNumber(value: $0) }
		trackable.countryOfOrigin = row.countryOfOrigin
		trackable.isNSFW = row.isNSFW.map { NSNumber(value: $0) }
		trackable.scheduleDay = row.scheduleDay.map { NSNumber(value: $0) }
		trackable.scheduleSeason = row.scheduleSeason.map { NSNumber(value: $0) }
		trackable.episodeCount = row.episodeCount.map { NSNumber(value: $0) }
		trackable.seasonCount = row.seasonCount.map { NSNumber(value: $0) }
		trackable.firstAired = row.firstAired.map { Date(timeIntervalSince1970: TimeInterval($0)) }
		trackable.lastAired = row.lastAired.map { Date(timeIntervalSince1970: TimeInterval($0)) }

		return trackable
	}

	/// Returns the trackable matching the given identity.
	///
	/// - Parameters:
	///    - trackableID: The server-side primary key of the trackable.
	///    - kind: The library kind of the trackable.
	///    - context: The managed object context.
	///
	/// - Returns: The matching `LocalTrackable`.
	static func fetch(trackableID: String, kind: LibraryKind, in context: NSManagedObjectContext) -> LocalTrackable? {
		let request = LocalTrackable.fetchRequest()
		request.predicate = NSPredicate(format: "kindRaw == %d AND trackableID == %@", Int64(kind.rawValue), trackableID)
		request.fetchLimit = 1

		return (try? context.fetch(request))?.first
	}

	/// Returns a sort key derived from the supplied title.
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
}
