//
//  ForumsThreadElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

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
