//
//  LibraryOutboxSeed.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

/// A denormalized display snapshot used to seed a placeholder `LocalLibraryEntry` created offline.
struct LibraryOutboxSeed: Codable, Sendable {
	var title: String?
	var sortTitle: String?
	var tagline: String?
	var posterURL: String?
	var posterBackgroundColor: String?
	var bannerURL: String?
	var bannerBackgroundColor: String?
	var genresLocalized: String?
	var statusName: String?
	var airingDate: Date?
	var durationCount: Int?
	var mediaTypeName: String?
	var popularityRank: Int?
	var publicRating: Double?
	var slug: String?
}

// MARK: - Show
extension LibraryOutboxSeed {
	/// Builds the display snapshot for a show being added to the library.
	///
	/// - Parameter show: The show the snapshot describes.
	init(show: Show) {
		self.init(
			title: show.attributes.title,
			sortTitle: LocalLibraryEntry.normalizedSortKey(show.attributes.title),
			tagline: show.attributes.tagline,
			posterURL: show.attributes.poster?.url,
			posterBackgroundColor: show.attributes.poster?.backgroundColor,
			bannerURL: show.attributes.banner?.url,
			bannerBackgroundColor: show.attributes.banner?.backgroundColor,
			genresLocalized: show.attributes.genres?.joined(separator: ", "),
			statusName: show.attributes.status.name,
			airingDate: show.attributes.nextBroadcastAt,
			durationCount: show.attributes.durationCount,
			mediaTypeName: show.attributes.type.name,
			popularityRank: show.attributes.stats?.rankTotal,
			publicRating: show.attributes.stats?.ratingAverage,
			slug: show.attributes.slug
		)
	}
}

// MARK: - Literature
extension LibraryOutboxSeed {
	/// Builds the display snapshot for a literature being added to the library.
	///
	/// - Parameter literature: The literature the snapshot describes.
	init(literature: Literature) {
		self.init(
			title: literature.attributes.title,
			sortTitle: LocalLibraryEntry.normalizedSortKey(literature.attributes.title),
			tagline: literature.attributes.tagline,
			posterURL: literature.attributes.poster?.url,
			posterBackgroundColor: literature.attributes.poster?.backgroundColor,
			bannerURL: literature.attributes.banner?.url,
			bannerBackgroundColor: literature.attributes.banner?.backgroundColor,
			genresLocalized: literature.attributes.genres?.joined(separator: ", "),
			statusName: literature.attributes.status.name,
			airingDate: literature.attributes.nextPublicationAt,
			durationCount: literature.attributes.durationCount,
			mediaTypeName: literature.attributes.type.name,
			popularityRank: literature.attributes.stats?.rankTotal,
			publicRating: literature.attributes.stats?.ratingAverage,
			slug: literature.attributes.slug
		)
	}
}
