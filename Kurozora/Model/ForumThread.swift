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
	let content: String?
	let replyPages: Int?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.content = json["content"].stringValue
		self.replyPages = json["reply_pages"].intValue
	}
}
