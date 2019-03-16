//
//  ThreadReplies.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ThreadReplies: JSONDecodable {
	let success: Bool?
	let page: Int?
	let replyPages: Int?
	let replies: [ThreadRepliesElement]?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.page = json["page"].intValue
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

class ThreadRepliesElement: JSONDecodable {
	let id: Int?
	let postedAt: String?
	let user: UserProfile?
	let score: Int?
	let content: String?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.postedAt = json["posted_at"].stringValue
		self.user = try? UserProfile(json: json["user"])
		self.score = json["score"].intValue
		self.content = json["content"].stringValue
	}
}
