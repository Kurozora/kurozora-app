//
//  ThreadReplyElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

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
