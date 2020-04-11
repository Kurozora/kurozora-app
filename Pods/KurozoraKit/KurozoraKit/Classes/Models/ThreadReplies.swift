//
//  ThreadReplies.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of thread replies, such as the thread reply's current page, last page, and total pages count.
*/
public class ThreadReplies: JSONDecodable {
	// MARK: - Properties
	/// The current number page of the thread replies.
	public let currentPage: Int?

	/// The last page number of the thread replies.
	public let lastPage: Int?

	/// The total count of pages of the thread replies.
	public let replyPages: Int?

	/// The collection of thread replies.
	public let replies: [ThreadRepliesElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
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

/**
	A mutable object that stores information about a single thread reply, such as the reply's content, and score.
*/
public class ThreadRepliesElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the reply.
	public let id: Int?

	/// The content fo the reply.
	public let content: String?

	/// The score of the reply.
	public let score: Int?

	/// The date the reply was posted at.
	public let postedAt: String?

	/// The user information related to the reply.
	public let userProfile: UserProfile?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.postedAt = json["posted_at"].stringValue
		self.userProfile = try? UserProfile(json: json["poster"])
		self.score = json["score"].intValue
		self.content = json["content"].stringValue
	}
}
