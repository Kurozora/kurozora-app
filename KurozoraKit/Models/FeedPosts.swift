//
//  FeedPosts.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class FeedPosts: JSONDecodable {
	public let success: Bool?
	public let page: Int?
	public let feedPages: Int?
	public let posts: [FeedPostElement]?

	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
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

public class FeedPostElement: JSONDecodable {
	public let id: Int?
	public let posterUserID: Int?
	public let posterUsername: String?
	public let content: String?
	public let profileImage: String?
	public let creationDate: String?
	public let replyCount: Int?
	public let shareCount: Int?
	public let heartsCount: Int?

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
