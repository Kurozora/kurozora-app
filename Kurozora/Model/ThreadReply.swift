//
//  ThreadReply.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ThreadReply: JSONDecodable {
	let success: Bool?
	let replyId: Int?

	required init(json: JSON) throws {
		success = json["success"].boolValue
		replyId = json["reply_id"].intValue
	}
}
