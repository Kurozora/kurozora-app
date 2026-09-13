//
//  DetailHeaderConfiguration.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// The values a detail header presents.
struct DetailHeaderConfiguration {
	// MARK: - Properties
	/// The library kind of the presented item.
	let libraryKind: LibraryKind

	/// The item's title.
	let title: String

	/// The line of tags shown below the title.
	let tags: String?

	/// The name of the item's airing or publishing status.
	let statusName: String?

	/// The color of the item's airing or publishing status.
	let statusColorHex: String?

	/// The item's overall rank.
	let rank: Int

	/// The source URL of the item's poster.
	let posterURLString: String

	/// The color behind the item's poster.
	let posterBackgroundColorHex: String?

	/// The source URL of the item's banner.
	let bannerURLString: String

	/// The color behind the item's banner.
	let bannerBackgroundColorHex: String?

	/// The URL of the item's trailer.
	let trailerURLString: String?

	/// The item's synopsis.
	let synopsis: String?

	// MARK: - Initializers
	/// Creates a configuration presenting the given show.
	///
	/// - Parameter show: The show to present.
	init(show: Show) {
		self.libraryKind = .shows
		self.title = show.attributes.title
		self.tags = show.attributes.informationString
		self.statusName = show.attributes.status.name
		self.statusColorHex = show.attributes.status.color
		self.rank = show.attributes.stats?.rankTotal ?? 0
		self.posterURLString = show.attributes.poster?.url ?? ""
		self.posterBackgroundColorHex = show.attributes.poster?.backgroundColor
		self.bannerURLString = show.attributes.banner?.url ?? show.attributes.poster?.url ?? ""
		self.bannerBackgroundColorHex = show.attributes.banner?.backgroundColor
		self.trailerURLString = show.attributes.videoUrl
		self.synopsis = show.attributes.synopsis
	}

	/// Creates a configuration presenting the given literature.
	///
	/// - Parameter literature: The literature to present.
	init(literature: Literature) {
		self.libraryKind = .literatures
		self.title = literature.attributes.title
		self.tags = literature.attributes.informationString
		self.statusName = literature.attributes.status.name
		self.statusColorHex = literature.attributes.status.color
		self.rank = literature.attributes.stats?.rankTotal ?? 0
		self.posterURLString = literature.attributes.poster?.url ?? ""
		self.posterBackgroundColorHex = literature.attributes.poster?.backgroundColor
		self.bannerURLString = literature.attributes.banner?.url ?? literature.attributes.poster?.url ?? ""
		self.bannerBackgroundColorHex = literature.attributes.banner?.backgroundColor
		self.trailerURLString = nil
		self.synopsis = literature.attributes.synopsis
	}

	/// Creates a configuration presenting the given game.
	///
	/// - Parameter game: The game to present.
	init(game: Game) {
		self.libraryKind = .games
		self.title = game.attributes.title
		self.tags = game.attributes.informationString
		self.statusName = game.attributes.status.name
		self.statusColorHex = game.attributes.status.color
		self.rank = game.attributes.stats?.rankTotal ?? 0
		self.posterURLString = game.attributes.poster?.url ?? ""
		self.posterBackgroundColorHex = game.attributes.poster?.backgroundColor
		self.bannerURLString = game.attributes.banner?.url ?? game.attributes.poster?.url ?? ""
		self.bannerBackgroundColorHex = game.attributes.banner?.backgroundColor
		self.trailerURLString = nil
		self.synopsis = game.attributes.synopsis
	}

	/// Creates a configuration presenting the given cached library entry.
	///
	/// - Parameter entry: The cached library entry to present.
	init(entry: LocalLibraryEntry) {
		let trackable = entry.trackable

		self.libraryKind = entry.kind
		self.title = trackable?.title ?? ""
		self.tags = entry.informationStringShort
		self.statusName = trackable?.statusName
		self.statusColorHex = AiringStatusStore.shared.colorHex(forStatusName: trackable?.statusName)
		self.rank = trackable?.popularityRank?.intValue ?? 0
		self.posterURLString = trackable?.posterURL ?? ""
		self.posterBackgroundColorHex = trackable?.posterBackgroundColor
		self.bannerURLString = trackable?.bannerURL ?? trackable?.posterURL ?? ""
		self.bannerBackgroundColorHex = trackable?.bannerBackgroundColor ?? trackable?.posterBackgroundColor
		self.trailerURLString = nil
		self.synopsis = nil
	}

}
