//
//  UserNotificationAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/08/2020.
//

extension UserNotification {
	/// A root object that stores information about a single user notification, such as the notification's type, read status, and payload.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The type of the user notification.
		public let type: String

		/// Whether the user notification is read or not.
		fileprivate let isRead: Bool

		/// The read status of the user notification.
		fileprivate var _readStatus: ReadStatus?

		/// The payload of the user notification.
		public let payload: UserNotification.Payload

		/// The description of the user notification.
		public let description: String

		/// The creation date of the user notification.
		public let createdAt: Date
	}
}

// MARK: - Helpers
extension UserNotification.Attributes {
	// MARK: - Properties
	/// The read status of the user notification.
	public var readStatus: ReadStatus {
		get {
			return _readStatus ?? ReadStatus(from: isRead)
		}
		set {
			_readStatus = newValue
		}
	}
}
