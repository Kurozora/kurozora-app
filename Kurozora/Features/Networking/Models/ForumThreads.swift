//
//  ForumThreads.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ForumThreads: JSONDecodable {
	let success: Bool?
	let page: Int?
	let threadPages: Int?
	let threads: [ForumThreadsElement]?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.page = json["page"].intValue
		self.threadPages = json["thread_pages"].intValue
		var threads = [ForumThreadsElement]()

		let threadsArray = json["threads"].arrayValue
		for thread in threadsArray {
			if let threadsElement = try? ForumThreadsElement(json: thread) {
				threads.append(threadsElement)
			}
		}

		self.threads = threads
	}
}

class ForumThreadsElement: JSONDecodable {
	let id: Int?
	let title: String?
	let contentTeaser: String?
	var locked: Bool?
	let posterUserID: Int?
	let posterUsername: String?
	let creationDate: String?
	let replyCount: Int?
	let score: Int?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.title = json["title"].stringValue
		self.contentTeaser = json["content_teaser"].stringValue
		self.locked = json["locked"].boolValue
		self.posterUserID = json["poster_user_id"].intValue
		self.posterUsername = json["poster_username"].stringValue
		self.creationDate = json["creation_date"].stringValue
		self.replyCount = json["reply_count"].intValue
		self.score = json["score"].intValue
	}
}
