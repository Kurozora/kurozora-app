//
//  UserNotificationResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/08/2020.
//

/// A root object that stores information about a collection of user notifications.
public struct UserNotificationResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a user notification object request.
	public let data: [UserNotification]
}
