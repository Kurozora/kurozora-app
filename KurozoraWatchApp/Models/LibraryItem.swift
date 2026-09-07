//
//  LibraryItem.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

/// A value snapshot of a `LocalLibraryEntry`, taken on the main thread for SwiftUI to render.
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
}
