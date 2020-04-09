//
//  ThreadReplies.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class ThreadReplies: JSONDecodable {
	// MARK: - Properties
	internal let success: Bool?
	public let currentPage: Int?
	public let lastPage: Int?
	public let replyPages: Int?
	public let replies: [ThreadRepliesElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.currentPage = json["page"].intValue
		self.lastPage = json["last_page"].intValue
  		self.replyPages = json["reply_pages"].intValue

		var replies = [ThreadRepliesElement]()
		let repliesArray = json["replies"].arrayValue
		for repliesItem in repliesArray {
			if let threadRepliesElement = try? ThreadRepliesElement(json: repliesItem) {
				replies.append(threadRepliesElement)
			}
		}
		self.replies = replies
	}
}

public class ThreadRepliesElement: JSONDecodable {
	// MARK: - Properties
	public let id: Int?
	public let postedAt: String?
	public let userProfile: UserProfile?
	public let score: Int?
	public let content: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.postedAt = json["posted_at"].stringValue
		self.userProfile = try? UserProfile(json: json["poster"])
		self.score = json["score"].intValue
		self.content = json["content"].stringValue
	}
}
