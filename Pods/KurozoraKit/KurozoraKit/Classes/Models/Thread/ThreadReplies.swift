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
	A mutable object that stores information about a collection of thread replies, such as the thread reply's next page url, and collection of replies it contains.
*/
public class ThreadReplies: JSONDecodable {
	// MARK: - Properties
	/// The URL to the next page in the paginated response.
	public let nextPageURL: String?

	/// The collection of thread replies.
	public let replies: [ThreadRepliesElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.nextPageURL = json["next"].stringValue

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
