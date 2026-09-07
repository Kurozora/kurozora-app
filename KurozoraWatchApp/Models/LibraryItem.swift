//
//  LibraryItem.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

/// A value snapshot of a library entry or catalog item, taken on the main thread for SwiftUI to render.
struct LibraryItem: Hashable, Identifiable, Sendable {
	// MARK: - Properties
	/// The identifier of the tracked show, literature, or game.
	let id: String

	let kind: LibraryKind

	let title: String

	let posterURL: String?

	/// The poster placeholder background color, as a hex string.
	let posterBackgroundColor: String?

	/// The localized media type label, such as "TV" or "Movie".
	let mediaTypeName: String?

	/// The localized airing status, such as "Currently Airing".
	let statusName: String?

	/// The next broadcast or publication date, used for the on-row countdown.
	let airingDate: Date?

	/// The duration in seconds.
	let durationCount: Int

	/// The score the user gave the entry.
	let userScore: Double?

	let libraryStatus: LibraryStatus

	let isFavorited: Bool

	let isReminded: Bool

	// MARK: - Initializers
	/// Snapshots the given entry.
	///
	/// - Parameter entry: The entry to snapshot, resolved on the main thread.
	init(entry: LocalLibraryEntry) {
		self.id = entry.trackableID
		self.kind = entry.kind
		self.title = entry.title ?? ""
		self.posterURL = entry.posterURL
		self.posterBackgroundColor = entry.posterBackgroundColor
		self.mediaTypeName = entry.mediaTypeName
		self.statusName = entry.statusName
		self.airingDate = entry.airingDate
		self.durationCount = entry.durationCount?.intValue ?? 0
		self.userScore = entry.review?.score?.doubleValue
		self.libraryStatus = entry.libraryStatus
		self.isFavorited = entry.isFavorited
		self.isReminded = entry.isReminded
	}

	/// Snapshots a catalog show, taking the library state from its local entry when one exists.
	///
	/// - Parameters:
	///    - show: The show as the server returned it.
	///    - entry: The local library entry tracking the show.
	init(show: Show, entry: LocalLibraryEntry?) {
		self.init(
			id: show.id.rawValue,
			kind: .shows,
			title: show.attributes.title,
			poster: show.attributes.poster,
			mediaTypeName: show.attributes.type.name,
			statusName: show.attributes.status.name,
			airingDate: show.attributes.nextBroadcastAt,
			durationCount: show.attributes.durationCount,
			entry: entry
		)
	}

	/// Snapshots a catalog literature, taking the library state from its local entry when one exists.
	///
	/// - Parameters:
	///    - literature: The literature as the server returned it.
	///    - entry: The local library entry tracking the literature.
	init(literature: Literature, entry: LocalLibraryEntry?) {
		self.init(
			id: literature.id.rawValue,
			kind: .literatures,
			title: literature.attributes.title,
			poster: literature.attributes.poster,
			mediaTypeName: literature.attributes.type.name,
			statusName: literature.attributes.status.name,
			airingDate: literature.attributes.nextPublicationAt,
			durationCount: literature.attributes.durationCount,
			entry: entry
		)
	}

	/// Snapshots a catalog game, taking the library state from its local entry when one exists.
	///
	/// - Parameters:
	///    - game: The game as the server returned it.
	///    - entry: The local library entry tracking the game.
	init(game: Game, entry: LocalLibraryEntry?) {
		self.init(
			id: game.id.rawValue,
			kind: .games,
			title: game.attributes.title,
			poster: game.attributes.poster,
			mediaTypeName: game.attributes.type.name,
			statusName: game.attributes.status.name,
			airingDate: nil,
			durationCount: game.attributes.durationCount,
			entry: entry
		)
	}

	private init(id: String, kind: LibraryKind, title: String, poster: Media?, mediaTypeName: String, statusName: String, airingDate: Date?, durationCount: Int, entry: LocalLibraryEntry?) {
		self.id = id
		self.kind = kind
		self.title = title
		self.posterURL = poster?.url
		self.posterBackgroundColor = poster?.backgroundColor
		self.mediaTypeName = mediaTypeName
		self.statusName = statusName
		self.airingDate = airingDate
		self.durationCount = durationCount
		self.userScore = entry?.review?.score?.doubleValue
		self.libraryStatus = entry?.libraryStatus ?? .none
		self.isFavorited = entry?.isFavorited ?? false
		self.isReminded = entry?.isReminded ?? false
	}
}
