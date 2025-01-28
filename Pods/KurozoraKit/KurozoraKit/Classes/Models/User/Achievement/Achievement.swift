//
//  Achievement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 23/08/2019.
//

/// A root object that stores information about a achievement resource.
public struct Achievement: Codable, Hashable, Sendable {
	// MARK: - Properties
	/// The id of the resource.
	public let id: String

	/// The type of the resource.
	public let type: String

	/// The attributes belonging to the achievement.
	public var attributes: Achievement.Attributes

	// MARK: - Functions
	public static func == (lhs: Achievement, rhs: Achievement) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
