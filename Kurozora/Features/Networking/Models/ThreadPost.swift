//
//  ThreadPost.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ThreadPost: JSONDecodable {
	let success: Bool?
	let threadID: Int?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.threadID = json["thread_id"].intValue
	}
}
