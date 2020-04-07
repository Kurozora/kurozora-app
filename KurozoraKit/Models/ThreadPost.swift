//
//  ThreadPost.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class ThreadPost: JSONDecodable {
	public let success: Bool?
	public let threadID: Int?

	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.threadID = json["thread_id"].intValue
	}
}
