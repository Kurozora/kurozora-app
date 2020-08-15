//
//  UserNotificationUpdateResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/08/2020.
//

/**
	A root object that stores information about a user notification update.
*/
public struct UserNotificationUpdateResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a user notification update object request.
	public let data: UserNotificationUpdate
}
