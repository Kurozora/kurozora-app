//
//  ForumsThread.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a single forums thread, such as the thred's last page number, and collection of threads it contains.
*/
public class ForumsThread: JSONDecodable {
	// MARK: - Properties
	/// The current page number of the forums thread.
	public let currentPage: Int?

	/// The last page of the forums thread.
	public let lastPage: Int?

	/// The thread object.
	public let thread: ForumsThreadElement?

	/// The collection of threads in the forums thread.
	public let threads: [ForumsThreadElement]?

	// MARK: - Initializers
	/// Initialize an empty instance of `ForumThreads`.
	internal init() {
		self.currentPage = nil
		self.lastPage = nil
		self.thread = nil
		self.threads = nil
	}

	required public init(json: JSON) throws {
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

/**
	A mutable object that stores information about a single forums thread, such as the thread's title, content, and lock status.
*/
public class ForumsThreadElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the forums thread.
	public let id: Int?

	/// The title of the forums thread.
	public let title: String?

	/// The content of the forums thread.
	public let content: String?

	/// The lock status of the forums thread.
	public var locked: LockStatus?

	/// The thread poster's id.
	public let posterUserID: Int?

	/// The thread poster's username.
	public let posterUsername: String?

	/// The creation date of the forums thread.
	public let creationDate: String?

	/// The comment count of the forums thread.
	public let commentCount: Int?

	/// The vote count of the forums thread.
	public let voteCount: Int?

	/// The current user's data related to the forums thread.
	public let currentUser: UserProfile?

	// MARK: - Initializers
	/// Initialize an empty instance of `ForumsThreadElement`.
	internal init() {
		self.id = nil
		self.title = nil
		self.content = nil
		self.locked = nil
		self.posterUserID = nil
		self.posterUsername = nil
		self.creationDate = nil
		self.commentCount = nil
		self.voteCount = nil
		self.currentUser = nil
	}

	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.title = json["title"].stringValue
		self.content = json["content"].stringValue
		self.locked = json["locked"].boolValue ? .locked : .unlocked
		self.posterUserID = json["poster_user_id"].intValue
		self.posterUsername = json["poster_username"].stringValue
		self.creationDate = json["creation_date"].stringValue
		self.commentCount = json["reply_count"].intValue
		self.voteCount = json["score"].intValue
		self.currentUser = try UserProfile(json: json["current_user"])
	}
}
