//
//  ThreadReplies.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

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
