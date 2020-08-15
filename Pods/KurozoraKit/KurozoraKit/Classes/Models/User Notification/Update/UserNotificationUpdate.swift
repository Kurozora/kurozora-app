//
//  UserNotificationUpdate.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/08/2020.
//

/**
	A root object that stores information about a user notification update resource.
*/
public struct UserNotificationUpdate: Codable {
	// MARK: - Properties
	/// Whether the user notification is read or not.
	fileprivate let isRead: Bool
}

// MARK: - Helpers
extension UserNotificationUpdate {
	// MARK: - Properties
	/// The read status of the user notification.
	public var readStatus: ReadStatus {
		return ReadStatus(from: isRead)
	}
}
