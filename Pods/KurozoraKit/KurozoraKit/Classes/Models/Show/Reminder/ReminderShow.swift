//
//  ReminderShow.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 31/01/2020.
//

/// A root object that stores information about a reminder show resource.
public struct ReminderShow: Codable {
	// MARK: - Properties
	/// Whether the show is reminded.
	public let isReminded: Bool
}

// MARK: - Helpers
extension ReminderShow {
	// MARK: - Properties
	/// The reminder status of the show.
	public var reminderStatus: ReminderStatus {
		return ReminderStatus(self.isReminded)
	}
}
