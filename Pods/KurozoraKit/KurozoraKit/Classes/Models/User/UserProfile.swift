//
//  UserProfile.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about the user profile, such as the user's username, bio, and session.
*/
public class UserProfile: JSONDecodable {
	// MARK: - Properties
	/// The id of the user.
	public let id: Int?

	/// The role of the user.
	public let role: Int?

	/// The username of the user.
	public let username: String?

	/// The Kurozora ID (email address) of the user.
	public let kurozoraID: String?

	/// The activity status of the user.
	public let activityStatus: ActivityStatus?

	/// The URL to the profile image of the user.
	public let profileImageURL: String?

	/// The URL to the banner image of the user.
	public let bannerImageURL: String?

	/// The biography text of the user.
	public let biography: String?

	/// The collection of badges of the user.
	public let badges: [BadgeElement]?

	/// Whether the user has a pro badge.
	public let proBadge: Bool?

	/// The join date of the user.
	public let joinDate: String?

	/// The follower count of the user.
	public var followerCount: Int?

	/// The following count of the user.
	public var followingCount: Int?

	/// The reputation count of the user.
	public let reputationCount: Int?

	/// The posts count of the user.
	public let postCount: Int?

	/// Whether the user is followed by the current user.
	public var following: Bool?

	/// The rating of the show by the current user.
	public var currentRating: Double?

	/// The watched episodes count of the user.
	public var watchedEpisodes: Int?

	/// The library status of the show that belongs to the user.
	public var libraryStatus: String?

	/// The favorite status of the show that belongs to the user.
	public var isFavorite: Bool?

	/// The like action of the user.
	public let likeAction: Int?

	/// Whether the theme has been bought by the user.
	public let themeBought: Bool?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.role = json["role"].intValue

		self.username = json["username"].stringValue
		self.kurozoraID = json["email_address"].stringValue
		self.activityStatus = ActivityStatus(rawValue: json["activity_status"].stringValue)
		self.profileImageURL = json["avatar_url"].stringValue
		self.bannerImageURL = json["banner_url"].stringValue
		self.biography = json["biography"].stringValue
		var badges = [BadgeElement]()

		let badgesArray = json["badges"].arrayValue
		for badgeItem in badgesArray {
			if let badgeElement = try? BadgeElement(json: badgeItem) {
				badges.append(badgeElement)
			}
		}

		self.badges = badges
		self.proBadge = json["pro_badge"].boolValue
		self.joinDate = json["join_date"].stringValue

		self.followerCount = json["follower_count"].intValue
		self.followingCount = json["following_count"].intValue
		self.reputationCount = json["reputation_count"].intValue
		self.postCount = json["post_count"].intValue

		self.following = json["current_user", "following"].boolValue
		self.currentRating = json["given_rating"].doubleValue
		self.watchedEpisodes = json["watched_episodes"].intValue
		self.libraryStatus = json["library_status"].stringValue
		self.isFavorite = json["is_favorite"].boolValue

		self.likeAction = json["like_action"].intValue
		self.themeBought = json["theme_bought"].boolValue
	}
}
