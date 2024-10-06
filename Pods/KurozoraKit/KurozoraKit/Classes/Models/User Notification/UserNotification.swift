//
//  Notification.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/10/2018.
//

/// A root object that stores information about a user notification resource.
public class UserNotification: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the user notification.
	public var attributes: UserNotification.Attributes

	// MARK: - Functions
	public static func == (lhs: UserNotification, rhs: UserNotification) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
