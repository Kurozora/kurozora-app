//
//  LibraryOutboxSeed.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

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
