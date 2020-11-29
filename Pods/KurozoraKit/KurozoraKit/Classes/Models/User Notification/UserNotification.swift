//
//  Notification.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/10/2018.
//

/**
	A root object that stores information about a user notification resource.
*/
public class UserNotification: Codable {
	// MARK: - Properties
	/// The id of the resource.
	public let id: String

	/// The type of the resource.
	public let type: String

	/// The relative link to where the resource is located.
	public let href: String

	/// The attributes belonging to the user notification.
	public var attributes: UserNotification.Attributes
}
