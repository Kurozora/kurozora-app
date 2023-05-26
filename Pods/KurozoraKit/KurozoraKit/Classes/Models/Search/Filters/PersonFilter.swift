//
//  PersonFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public struct PersonFilter {
	// MARK: - Properties
	public let astrologicalSign: Int?
	public let birthDate: TimeInterval?
	public let deceasedDate: TimeInterval?

	// MARK: - Initializers
	public init(astrologicalSign: Int? = nil, birthDate: TimeInterval? = nil, deceasedDate: TimeInterval? = nil) {
		self.astrologicalSign = astrologicalSign
		self.birthDate = birthDate
		self.deceasedDate = deceasedDate
	}
}

// MARK: - Filterable
extension PersonFilter: Filterable {
	func toFilterArray() -> [String: Any?] {
		return [
			"astrological_sign": self.astrologicalSign,
			"birthdate": self.birthDate,
			"deceased_date": self.deceasedDate
		]
	}
}
