//
//  Schedule.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/12/2024.
//

/// A root object that stores information about a schedule resource.
public struct Schedule: Codable, Hashable, Sendable {
	// MARK: - Properties
	/// The type of the resource.
	public let type: String

	/// The attributes belonging to the schedule.
	public let attributes: Schedule.Attributes

	/// The relationships belonging to the schedule.
	public let relationships: Schedule.Relationships

	// MARK: - Functions
	public static func == (lhs: Schedule, rhs: Schedule) -> Bool {
		return lhs.type == rhs.type && lhs.attributes.date == rhs.attributes.date
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.type)
		hasher.combine(self.attributes.date)
	}
}
