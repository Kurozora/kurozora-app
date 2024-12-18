//
//  ScheduleAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/12/2024.
//

extension Schedule {
	/// A root object that stores information about a single schedule, such as the schedule's date.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The date of the schedule.
		public let date: Date
	}
}
