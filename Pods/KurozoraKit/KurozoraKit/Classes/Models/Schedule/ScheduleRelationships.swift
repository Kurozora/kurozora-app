//
//  ScheduleRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/12/2024.
//

extension Schedule {
	/// A root object that stores information about schedule relationships, such as the shows, and games that belong to it.
	public struct Relationships: Codable, Sendable {
		// MARK: - Properties
		/// The shows related to the schedue.
		public let shows: ShowResponse?

		/// The games related to the schedule.
		public let games: GameResponse?

		/// The literatures related to the schedule.
		public let literatures: LiteratureResponse?
	}
}
