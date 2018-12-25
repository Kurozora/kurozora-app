//
//  ThreadReplies.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ThreadReplies: JSONDecodable {
	let success: Bool?
	let replies: [JSON]?

	required init(json: JSON) throws {
		success = json["success"].boolValue
		replies = json["replies"].arrayValue
	}
}
