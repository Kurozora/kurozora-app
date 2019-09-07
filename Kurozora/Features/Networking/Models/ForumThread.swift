//
//  ForumThread.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ForumThread: JSONDecodable {
	let success: Bool?
	let thread: ForumThreadElement?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.thread = try? ForumThreadElement(json: json["thread"])
	}
}

class ForumThreadElement: JSONDecodable {
	let id: Int?
	let title: String?
	let content: String?
	var locked: Bool?
	let creationDate: String?
	let replyCount: Int?
	let score: Int?
	let user: UserProfile?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.title = json["title"].stringValue
		self.content = json["content"].stringValue
		self.locked = json["locked"].boolValue
		self.creationDate = json["creation_date"].stringValue
		self.replyCount = json["reply_count"].intValue
		self.score = json["score"].intValue
		self.user = try? UserProfile(json: json["user"])
	}
}
