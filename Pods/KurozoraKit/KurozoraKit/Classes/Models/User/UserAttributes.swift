//
//  UserAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension User {
	/**
		A root object that stores information about a single user, such as the user's username, bio, and profile image.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
//		/// The role of the user.
//		public let role: Int?

		/// The username of the user.
		public let username: String

		/// The Kurozora ID (email address) of the user.
		///
		/// Included only for the currently signed in user.
		public let email: String?

		/// The biography text of the user.
		public var biography: String?

		/// The activity status of the user.
		public let activityStatus: ActivityStatus

		/// The URL to the profile image of the user.
		public var profileImageURL: String?

		/// The URL to the banner image of the user.
		public var bannerImageURL: String?

//		/// Whether the user has a pro badge.
//		public let proBadge: Bool?

		/// The join date of the user.
		public let joinDate: String

		/// The follower count of the user.
		public var followerCount: Int

		/// The following count of the user.
		public var followingCount: Int

		/// The reputation count of the user.
		public let reputationCount: Int

		/// Whether the user is followed by the current user.
		fileprivate var isFollowed: Bool?

		/// The follow status of the user.
		fileprivate var _followStatus: FollowStatus?

//		/// Whether the theme has been bought by the user.
//		public let themeBought: Bool?
	}
}

// MARK: - Helpers
extension User.Attributes {
	// MARK: - Properties
	/// The follow status of the user.
	public var followStatus: FollowStatus {
		get {
			return self._followStatus ?? FollowStatus(self.isFollowed)
		}
		set {
			self._followStatus = newValue
		}
	}

	// MARK: - Functions
	/**
		Updates the attributes with the given `FollowUpdate` object.

		- Parameter followUpdate: The `FollowUpdate` object used to update the attributes.
	*/
	public mutating func update(using followUpdate: FollowUpdate) {
		self.followStatus = followUpdate.followStatus
	}

	/**
		Returns a copy of the object with the updated attributes from the given `FollowUpdate` object.

		- Parameter followUpdate: The `FollowUpdate` object used to update the attributes.

		- Returns: a copy of the object with the updated attributes from the given `followUpdate` object.
	*/
	public mutating func updated(using followUpdate: FollowUpdate) -> Self {
		var userAttributes = self
		userAttributes.followStatus = followUpdate.followStatus
		return userAttributes
	}

	/**
		Updates the attributes with the given `UserUpdate` object.

		- Parameter userUpdate: The `UserUpdate` object used to update the attributes.
	*/
	public mutating func update(using userUpdate: UserUpdate) {
		self.biography = userUpdate.biography
		self.profileImageURL = userUpdate.profileImageURL
		self.bannerImageURL = userUpdate.bannerImageURL
	}

	/**
		Returns a copy of the object with the updated attributes from the given `UserUpdate` object.

		- Parameter userUpdate: The `UserUpdate` object used to update the attributes.

		- Returns: a copy of the object with the updated attributes from the given `userUpdate` object.
	*/
	public mutating func updated(using userUpdate: UserUpdate) -> Self {
		var userAttributes = self
		userAttributes.biography = userUpdate.biography
		userAttributes.profileImageURL = userUpdate.profileImageURL
		userAttributes.bannerImageURL = userUpdate.bannerImageURL
		return userAttributes
	}
}
