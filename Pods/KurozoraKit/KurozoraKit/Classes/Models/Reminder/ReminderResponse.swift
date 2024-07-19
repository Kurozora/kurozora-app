//
//  ReminderResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

/// A root object that stores information about a model's reminder status.
public struct ReminderResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a reminder model object request.
	public let data: Reminder
}
