//
//  ThreadPost.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON


/**
	A mutable object that stores information about a single thread post.
*/
public class ThreadPost: JSONDecodable {
	// MARK: - Properties
	/// The id of the thread post.
	public let threadID: Int?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.threadID = json["thread_id"].intValue
	}
}
