//
//  ThreadReply.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single thread reply.
*/
public class ThreadReply: JSONDecodable {
	// MARK: - Properties
	/// The id of the thread reply.
	public let id: Int?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["reply_id"].intValue
	}
}
