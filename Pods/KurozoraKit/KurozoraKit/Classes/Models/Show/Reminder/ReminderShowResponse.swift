//
//  ReminderShowResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

/// A root object that stores information about a show's reminder status.
public struct ReminderShowResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a reminder show object request.
	public let data: ReminderShow
}
