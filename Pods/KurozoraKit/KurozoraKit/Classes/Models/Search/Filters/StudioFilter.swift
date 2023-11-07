//
//  StudioFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public struct StudioFilter {
	// MARK: - Properties
	public let address: String?
	public let founded: TimeInterval?
	public let isNSFW: Bool?
	public let type: Int?

	// MARK: - Initializers
	public init(address: String? = nil, founded: TimeInterval? = nil, isNSFW: Bool? = nil, type: Int? = nil) {
		self.address = address
		self.founded = founded
		self.isNSFW = isNSFW
		self.type = type
	}
}

// MARK: - Filterable
extension StudioFilter: Filterable {
	func toFilterArray() -> [String: Any?] {
		return [
			"address": self.address,
			"founded": self.founded,
			"is_nsfw": self.isNSFW,
			"type": self.type
		]
	}
}
