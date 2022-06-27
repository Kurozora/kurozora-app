//
//  ShowType.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/06/2021.
//

/// A root object that stores information about a show type resource.
public struct ShowType: Codable, Hashable {
	// MARK: - Properties
	/// The name of the show type.
	public let name: String

	/// The description of the show type.
	public let description: String

	// MARK: - Functions
	public static func == (lhs: ShowType, rhs: ShowType) -> Bool {
		return lhs.name == rhs.name
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.name)
	}
}

