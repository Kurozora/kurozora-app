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
	let message: String?
	let threadId: Int?

	required init(json: JSON) throws {
		success = json["success"].boolValue
		message = json["error_message"].stringValue
		threadId = json["thread_id"].intValue
	}
}

