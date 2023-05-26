//
//  GameFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public struct GameFilter {
	// MARK: - Properties
	public let publicationDay: Int?
	public let publicationSeason: Int?
	public let duration: Int?
	public let publishedAt: TimeInterval?
	public let isNSFW: Bool?
	public let mediaType: Int?
	public let source: Int?
	public let status: Int?
	public let tvRating: Int?
	public let editionCount: Int?

	// MARK: - Initializers
	public init(publicationDay: Int? = nil, publicationSeason: Int? = nil, duration: Int? = nil, publishedAt: TimeInterval? = nil, isNSFW: Bool? = nil, mediaType: Int? = nil, source: Int? = nil, status: Int? = nil, tvRating: Int? = nil, editionCount: Int? = nil) {
		self.publicationDay = publicationDay
		self.publicationSeason = publicationSeason
		self.duration = duration
		self.publishedAt = publishedAt
		self.isNSFW = isNSFW
		self.mediaType = mediaType
		self.source = source
		self.status = status
		self.tvRating = tvRating
		self.editionCount = editionCount
	}
}

// MARK: - Filterable
extension GameFilter: Filterable {
	func toFilterArray() -> [String: Any?] {
		return [
			"publication_day": self.publicationDay,
			"publication_season": self.publicationSeason,
			"duration": self.duration,
			"published_at": self.publishedAt,
			"is_nsfw": self.isNSFW,
			"media_type_id": self.mediaType,
			"source_id": self.source,
			"status_id": self.status,
			"tv_rating_id": self.tvRating,
			"edition_count": self.editionCount
		]
	}
}
