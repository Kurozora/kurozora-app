//
//  LibraryEntryDetails.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

/// The fields a detail screen shows that the local store does not carry, fetched from the server per kind.
struct LibraryEntryDetails: Sendable {
	// MARK: - Properties
	/// The abbreviated count line, such as "24 ep" or "12 ch · 3 vol".
	let countLine: String?

	/// The symbol shown beside the count line.
	let countSymbolName: String

	let statusName: String

	let genres: [String]?

	let synopsis: String?

	/// The snapshot used to seed a placeholder row when the entry is re-added while its row is gone.
	let seed: LibraryOutboxSeed?

	// MARK: - Initializers
	/// Takes the detail fields from a show.
	///
	/// - Parameter show: The show as the server returned it.
	init(show: Show) {
		let attributes = show.attributes

		self.countLine = attributes.episodeCount > 0 ? L10n.episodeCount(attributes.episodeCount) : nil
		self.countSymbolName = "film"
		self.statusName = attributes.status.name
		self.genres = attributes.genres
		self.synopsis = attributes.synopsis
		self.seed = LibraryOutboxSeed(show: show)
	}

	/// Takes the detail fields from a literature.
	///
	/// - Parameter literature: The literature as the server returned it.
	init(literature: Literature) {
		let attributes = literature.attributes
		var counts: [String] = []

		if attributes.chapterCount > 0 {
			counts.append(L10n.chapterCount(attributes.chapterCount))
		}

		if attributes.volumeCount > 0 {
			counts.append(L10n.volumeCount(attributes.volumeCount))
		}

		self.countLine = counts.isEmpty ? nil : counts.joined(separator: " · ")
		self.countSymbolName = "book"
		self.statusName = attributes.status.name
		self.genres = attributes.genres
		self.synopsis = attributes.synopsis
		self.seed = LibraryOutboxSeed(literature: literature)
	}

	/// Takes the detail fields from a game.
	///
	/// - Parameter game: The game as the server returned it.
	init(game: Game) {
		let attributes = game.attributes

		self.countLine = attributes.editionCount > 0 ? L10n.editionCount(attributes.editionCount) : nil
		self.countSymbolName = "gamecontroller"
		self.statusName = attributes.status.name
		self.genres = attributes.genres
		self.synopsis = attributes.synopsis
		// The game seed's publication date comes from a date parser that only the iOS app carries,
		// so the watch leaves the placeholder to the next sync instead of seeding a partial row.
		self.seed = nil
	}
}
