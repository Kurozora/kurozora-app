//
//  ShowFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public struct ShowFilter {
	// MARK: - Properties
	public let airDay: Int?
	public let airSeason: Int?
	public let airTime: String?
	public let countryOfOrigin: String?
	public let duration: Int?
	public let isNSFW: Bool?
	public let startedAt: TimeInterval?
	public let endedAt: TimeInterval?
	public let mediaType: Int?
	public let source: Int?
	public let status: Int?
	public let tvRating: Int?
	public let seasonCount: Int?
	public let episodeCount: Int?

	// MARK: - Initializers
	public init(
		airDay: Int? = nil,
		airSeason: Int? = nil,
		airTime: String? = nil,
		countryOfOrigin: String? = nil,
		duration: Int? = nil,
		isNSFW: Bool? = nil,
		startedAt: TimeInterval? = nil,
		endedAt: TimeInterval? = nil,
		mediaType: Int? = nil,
		source: Int? = nil,
		status: Int? = nil,
		tvRating: Int? = nil,
		seasonCount: Int? = nil,
		episodeCount: Int? = nil
	) {
		self.airDay = airDay
		self.airSeason = airSeason
		self.airTime = airTime
		self.countryOfOrigin = countryOfOrigin
		self.duration = duration
		self.isNSFW = isNSFW
		self.startedAt = startedAt
		self.endedAt = endedAt
		self.mediaType = mediaType
		self.source = source
		self.status = status
		self.tvRating = tvRating
		self.seasonCount = seasonCount
		self.episodeCount = episodeCount
	}
}

// MARK: - Filterable
extension ShowFilter: Filterable {
	func toFilterArray() -> [String: Any?] {
		return [
			"air_day": self.airDay,
			"air_season": self.airSeason,
			"air_time": self.airTime,
			"country_id": self.countryOfOrigin,
			"duration": self.duration,
			"started_at": self.startedAt,
			"is_nsfw": self.isNSFW,
			"ended_at": self.endedAt,
			"media_type_id": self.mediaType,
			"source_id": self.source,
			"status_id": self.status,
			"tv_rating_id": self.tvRating,
			"season_count": self.seasonCount,
			"episode_count": self.episodeCount
		]
	}
}
