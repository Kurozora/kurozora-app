//
//  FeedPostElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single feed post, such as the posts's content, creation date, and share count.
*/
public class FeedPostElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the post.
	public let id: Int?

	/// The post's poster's id.
	public let posterUserID: Int?

	/// The post's poster's username.
	public let posterUsername: String?

	/// The content of the post.
	public let content: String?

	/// The post's poster's profile image.
	public let profileImage: String?

	/// The creation date fo the post.
	public let creationDate: String?

	/// The reply count of the post.
	public let replyCount: Int?

	/// The share count of the post.
	public let shareCount: Int?

	/// The hearts count of the post.
	public let heartsCount: Int?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.posterUserID = json["poster_user_id"].intValue
		self.posterUsername = json["poster_username"].stringValue
		self.content = json["content_teaser"].stringValue
		self.profileImage = json["profile_image"].stringValue
		self.creationDate = json["creation_date"].stringValue
		self.replyCount = json["reply_count"].intValue
		self.shareCount = json["share_count"].intValue
		self.heartsCount = json["hearts_count"].intValue
	}
}
