//
//  Country.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 21/09/2024.
//

/// A root object that stores information about a country resource.
public struct Country: Codable, Hashable {
	// MARK: - Properties
	/// The country's name.
	public let name: String

	/// The country's ISO 3166-1 alpha-2 code.
	public let code: String

	/// The country's ISO 3166-1 alpha-3 code.
	public let iso31663: String

	// MARK: - Functions
	public static func == (lhs: Country, rhs: Country) -> Bool {
		return lhs.code == rhs.code
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.code)
	}
}
