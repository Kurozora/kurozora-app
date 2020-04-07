//
//  ForumsThread.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class ForumsThread: JSONDecodable {
	public let success: Bool?
	public let currentPage: Int?
	public let lastPage: Int?
	public let thread: ForumsThreadElement?
	public let threads: [ForumsThreadElement]?

	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.currentPage = json["page"].intValue
		self.lastPage = json["last_page"].intValue
		self.thread = try ForumsThreadElement(json: json["thread"])

		var threads = [ForumsThreadElement]()
		let threadsArray = json["threads"].arrayValue
		for thread in threadsArray {
			if let threadsElement = try? ForumsThreadElement(json: thread) {
				threads.append(threadsElement)
			}
		}
		self.threads = threads
	}
}

public class ForumsThreadElement: JSONDecodable {
	public let id: Int?
	public let title: String?
	public let content: String?
	public var locked: Bool?
	public let posterUserID: Int?
	public let posterUsername: String?
	public let creationDate: String?
	public let commentCount: Int?
	public let voteCount: Int?
	public let currentUser: UserProfile?

	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.title = json["title"].stringValue
		self.content = json["content"].stringValue
		self.locked = json["locked"].boolValue
		self.posterUserID = json["poster_user_id"].intValue
		self.posterUsername = json["poster_username"].stringValue
		self.creationDate = json["creation_date"].stringValue
		self.commentCount = json["reply_count"].intValue
		self.voteCount = json["score"].intValue
		self.currentUser = try UserProfile(json: json["current_user"])
	}
}
