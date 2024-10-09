//
//  StudioFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public struct StudioFilter {
	// MARK: - Properties
	public let type: Int?
	public let tvRating: Int?
	public let address: String?
	public let foundedAt: TimeInterval?
	public let defunctAt: TimeInterval?
	public let isNSFW: Bool?

	// MARK: - Initializers
	public init(
		type: Int? = nil,
		tvRating: Int? = nil,
		address: String? = nil,
		foundedAt: TimeInterval? = nil,
		defunctAt: TimeInterval? = nil,
		isNSFW: Bool? = nil
	) {
		self.type = type
		self.tvRating = tvRating
		self.address = address
		self.foundedAt = foundedAt
		self.defunctAt = defunctAt
		self.isNSFW = isNSFW
	}
}

// MARK: - Filterable
extension StudioFilter: Filterable {
	func toFilterArray() -> [String: Any?] {
		return [
			"type": self.type,
			"tv_rating_id": self.tvRating,
			"address": self.address,
			"founded_at": self.foundedAt,
			"defunct_at": self.defunctAt,
			"is_nsfw": self.isNSFW
		]
	}
}
