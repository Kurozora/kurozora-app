//
//  EpisodeFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public struct EpisodeFilter {
	// MARK: - Properties
	public let duration: Int?
	public let isFiller: Bool?
	public let isNSFW: Bool?
	public let isSpecial: Bool?
	public let isPremiere: Bool?
	public let isFinale: Bool?
	public let number: Int?
	public let numberTotal: Int?
	public let season: Int?
	public let tvRating: Int?
	public let startedAt: TimeInterval?
	public let endedAt: TimeInterval?

	// MARK: - Initializers
	public init(duration: Int? = nil, isFiller: Bool? = nil, isNSFW: Bool? = nil, isSpecial: Bool? = nil, isPremiere: Bool? = nil, isFinale: Bool? = nil, number: Int? = nil, numberTotal: Int? = nil, season: Int? = nil, tvRating: Int? = nil, startedAt: TimeInterval? = nil, endedAt: TimeInterval? = nil) {
		self.duration = duration
		self.isFiller = isFiller
		self.isNSFW = isNSFW
		self.isSpecial = isSpecial
		self.isPremiere = isPremiere
		self.isFinale = isFinale
		self.number = number
		self.numberTotal = numberTotal
		self.season = season
		self.tvRating = tvRating
		self.startedAt = startedAt
		self.endedAt = endedAt
	}
}

// MARK: - Filterable
extension EpisodeFilter: Filterable {
	func toFilterArray() -> [String: Any?] {
		return [
			"duration": self.duration,
			"is_filler": self.isFiller,
			"is_nsfw": self.isNSFW,
			"is_special": self.isSpecial,
			"is_premiere": self.isPremiere,
			"is_finale": self.isFinale,
			"number": self.number,
			"number_total": self.numberTotal,
			"season_id": self.season,
			"tv_rating_id": self.tvRating,
			"started_at": self.startedAt,
			"ended_at": self.endedAt
		]
	}
}
