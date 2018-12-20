//
//  ForumThread.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ForumThread: JSONDecodable {
	let success: Bool?
	let message: String?

	let threadId: Int?
	let content: String?

	required init(json: JSON) throws {
		success = json["success"].boolValue
		message = json["error_message"].stringValue

		threadId = json["thread"]["id"].intValue
		content = json["thread"]["content"].stringValue
	}
}
