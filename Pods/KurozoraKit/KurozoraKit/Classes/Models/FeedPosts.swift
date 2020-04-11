//
//  FeedPosts.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of feed posts, such as the feed's total pages count.
*/
public class FeedPosts: JSONDecodable {
	// MARK: - Properties
	/// The current page number of the feed.
	public let page: Int?

	/// The total page number of the feed.
	public let feedPages: Int?

	/// The collection of posts in the feed.
	public let posts: [FeedPostElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.page = json["page"].intValue
		self.feedPages = json["feed_pages"].intValue
		var posts = [FeedPostElement]()

		let postsArray = json["posts"].arrayValue
		for post in postsArray {
			if let postElement = try? FeedPostElement(json: post) {
				posts.append(postElement)
			}
		}

		self.posts = posts
	}
}

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
