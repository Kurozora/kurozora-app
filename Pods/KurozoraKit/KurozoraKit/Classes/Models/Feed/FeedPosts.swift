//
//  FeedPosts.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

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
