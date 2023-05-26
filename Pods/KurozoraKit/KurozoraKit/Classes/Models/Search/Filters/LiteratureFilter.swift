//
//  LiteratureFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public struct LiteratureFilter {
	// MARK: - Properties
	public let publicationDay: Int?
	public let publicationSeason: Int?
	public let publicationTime: String?
	public let duration: Int?
	public let startedAt: TimeInterval?
	public let endedAt: TimeInterval?
	public let isNSFW: Bool?
	public let mediaType: Int?
	public let source: Int?
	public let status: Int?
	public let tvRating: Int?
	public let volumeCount: Int?
	public let chapterCount: Int?
	public let pageCount: Int?

	// MARK: - Initializers
	public init(publicationDay: Int? = nil, publicationSeason: Int? = nil, publicationTime: String? = nil, duration: Int? = nil, startedAt: TimeInterval? = nil, endedAt: TimeInterval? = nil, isNSFW: Bool? = nil, mediaType: Int? = nil, source: Int? = nil, status: Int? = nil, tvRating: Int? = nil, volumeCount: Int? = nil, chapterCount: Int? = nil, pageCount: Int? = nil) {
		self.publicationDay = publicationDay
		self.publicationSeason = publicationSeason
		self.publicationTime = publicationTime
		self.duration = duration
		self.startedAt = startedAt
		self.endedAt = endedAt
		self.isNSFW = isNSFW
		self.mediaType = mediaType
		self.source = source
		self.status = status
		self.tvRating = tvRating
		self.volumeCount = volumeCount
		self.chapterCount = chapterCount
		self.pageCount = pageCount
	}
}

// MARK: - Filterable
extension LiteratureFilter: Filterable {
	func toFilterArray() -> [String: Any?] {
		return [
			"publication_day": self.publicationDay,
			"publication_season": self.publicationSeason,
			"publication_time": self.publicationTime,
			"duration": self.duration,
			"started_at": self.startedAt,
			"ended_at": self.endedAt,
			"is_nsfw": self.isNSFW,
			"media_type_id": self.mediaType,
			"source_id": self.source,
			"status_id": self.status,
			"tv_rating_id": self.tvRating,
			"volume_count": self.volumeCount,
			"chapter_count": self.chapterCount,
			"page_count": self.pageCount
		]
	}
}
