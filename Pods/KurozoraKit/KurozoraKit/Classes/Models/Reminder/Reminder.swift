//
//  Reminder.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 31/01/2020.
//

/// A root object that stores information about a reminder show resource.
public struct Reminder: Codable {
	// MARK: - Properties
	/// Whether the show is reminded.
	internal let isReminded: Bool
}

// MARK: - Helpers
extension Reminder {
	// MARK: - Properties
	/// The reminder status of the show.
	public var reminderStatus: ReminderStatus {
		return ReminderStatus(self.isReminded)
	}
}
