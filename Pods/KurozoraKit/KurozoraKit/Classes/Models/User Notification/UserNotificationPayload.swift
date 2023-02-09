//
//  UserNotificationData.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension UserNotification {
	/// A root object that stores information about user notification payload.
	public struct Payload: Codable {
		// MARK: - Properties
		// Session
		/// [Session] The ip address of a session.
		public let ip: String?

		/// [Session] The id of a session.
		public let sessionID: String?

		// Follower
		/// [Follower] The id of a follower.
		public let userID: String?

		/// [Follower] The username of a follower.
		public let username: String?

		/// [Follower] The profile image of the follower.
		public let profileImageURL: String?

		// Feed Message
		/// [FeedMessage] The id of a feed message.
		public let feedMessageID: String?
	}
}
