//
//  UserAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension User {
	/// A root object that stores information about a single user, such as the user's username, bio, and profile image.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The role of the user.
		public let role: Int?

		/// The slug of the user.
		public var slug: String

		/// The username of the user.
		public var username: String

		/// The Kurozora ID (email address) of the user.
		///
		/// Included only for the currently signed in user.
		public let email: String?

		/// Whether the user has Sign in with Apple enabled.
		///
		/// Included only for the currently signed in user.
		public let siwaIsEnabled: Bool?

		/// The biography text of the user.
		public var biography: String?

		/// The biography HTML text of the user.
		public var biographyHTML: String?

		/// The biography Markdown text of the user.
		public var biographyMarkdown: String?

		/// The activity status of the user.
		public let activityStatus: ActivityStatus

		/// The profile image of the user.
		public var profile: Media?

		/// The banner image of the user.
		public var banner: Media?

		/// Whether the user is a developer.
		public var isDeveloper: Bool

		/// Whether the user is a staff member.
		public var isStaff: Bool

		/// Whether the user is an early supporter.
		public var isEarlySupporter: Bool

		/// Whether the user has a valid pro account.
		public var isPro: Bool

		/// Whether the user has a valid subscription.
		public var isSubscribed: Bool

		/// Whether the user is verified.
		public var isVerified: Bool

		/// The join date of the user.
		public let joinedAt: Date

		/// The subscription date of the user.
		public let subscribedAt: Date?

		/// The follower count of the user.
		public var followerCount: Int

		/// The following count of the user.
		public var followingCount: Int

		/// The reputation count of the user.
		public let reputationCount: Int

		/// The preferred language of the user.
		public var preferredLanguage: String?

		/// The preferred TV rating of the user.
		public var preferredTVRating: Int?

		/// The preferred timezone of the user.
		public var preferredTimezone: String?

		/// Whether the user can change their username.
		public let canChangeUsername: Bool?

		/// Whether the user is followed by the current user.
		fileprivate var isFollowed: Bool?

		/// The follow status of the user.
		fileprivate var _followStatus: FollowStatus?
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
	/// Updates the attributes with the given `FollowUpdate` object.
	///
	/// - Parameter followUpdate: The `FollowUpdate` object used to update the attributes.
	public mutating func update(using followUpdate: FollowUpdate) {
		self.followStatus = followUpdate.followStatus
	}

	/// Returns a copy of the object with the updated attributes from the given `FollowUpdate` object.
	///
	/// - Parameter followUpdate: The `FollowUpdate` object used to update the attributes.
	///
	/// - Returns: a copy of the object with the updated attributes from the given `followUpdate` object.
	public mutating func updated(using followUpdate: FollowUpdate) -> Self {
		var userAttributes = self
		userAttributes.followStatus = followUpdate.followStatus
		return userAttributes
	}

	/// Updates the attributes with the given `UserUpdate` object.
	///
	/// - Parameter userUpdate: The `UserUpdate` object used to update the attributes.
	public mutating func update(using userUpdate: UserUpdate) {
		self.slug = userUpdate.username
		self.username = userUpdate.nickname
		self.biography = userUpdate.biography
		self.profile = userUpdate.profile
		self.banner = userUpdate.banner
		self.preferredLanguage = userUpdate.preferredLanguage
		self.preferredTVRating = userUpdate.preferredTVRating
		self.preferredTimezone = userUpdate.preferredTimezone
	}

	/// Returns a copy of the object with the updated attributes from the given `UserUpdate` object.
	///
	/// - Parameter userUpdate: The `UserUpdate` object used to update the attributes.
	///
	/// - Returns: a copy of the object with the updated attributes from the given `userUpdate` object.
	public mutating func updated(using userUpdate: UserUpdate) -> Self {
		var userAttributes = self
		userAttributes.slug = userUpdate.username
		userAttributes.username = userUpdate.nickname
		userAttributes.biography = userUpdate.biography
		userAttributes.profile = userUpdate.profile
		userAttributes.banner = userUpdate.banner
		userAttributes.preferredLanguage = userUpdate.preferredLanguage
		userAttributes.preferredTVRating = userUpdate.preferredTVRating
		userAttributes.preferredTimezone = userUpdate.preferredTimezone
		return userAttributes
	}

	/// Updates the subscription status of the user.
	///
	/// - Parameter receipt: The `Receipt` object used to update the subscription status.
	public mutating func updateSubscription(from receipt: Receipt) {
		self.isSubscribed = receipt.attributes.isValid
		self.isPro = receipt.attributes.isValid
	}
}
