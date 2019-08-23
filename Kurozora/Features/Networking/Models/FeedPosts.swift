//
//  FeedPosts.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class FeedPosts: JSONDecodable {
	let success: Bool?
	let page: Int?
	let feedPages: Int?
	let posts: [FeedPostElement]?

	required init(json: JSON) throws {
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

class FeedPostElement: JSONDecodable {
	let id: Int?
	let posterUserID: Int?
	let posterUsername: String?
	let content: String?
	let profileImage: String?
	let creationDate: String?
	let replyCount: Int?
	let shareCount: Int?
	let heartsCount: Int?

	required init(json: JSON) throws {
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
