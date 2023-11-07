//
//  CharacterFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public struct CharacterFilter {
	// MARK: - Properties
	public var age: Int?
	public var astrologicalSign: Int?
	public var birthDay: Int?
	public var birthMonth: Int?
	public var bust: String?
	public var height: String?
	public var hip: String?
	public var status: Int?
	public var waist: String?
	public var weight: String?

	// MARK: - Initializers
	public init(age: Int? = nil, astrologicalSign: Int? = nil, birthDay: Int? = nil, birthMonth: Int? = nil, bust: String? = nil, height: String? = nil, hip: String? = nil, status: Int? = nil, waist: String? = nil, weight: String? = nil) {
		self.age = age
		self.astrologicalSign = astrologicalSign
		self.birthDay = birthDay
		self.birthMonth = birthMonth
		self.bust = bust
		self.height = height
		self.hip = hip
		self.status = status
		self.waist = waist
		self.weight = weight
	}
}

// MARK: - Filterable
extension CharacterFilter: Filterable {
	func toFilterArray() -> [String: Any?] {
		return [
			"age": self.age,
			"astrological_sign": self.astrologicalSign,
			"birth_day": self.birthDay,
			"birth_month": self.birthMonth,
			"bust": self.bust,
			"height": self.height,
			"hip": self.hip,
			"status": self.status,
			"waist": self.waist,
			"weight": self.weight
		].filter { $0.value != nil }
	}
}
