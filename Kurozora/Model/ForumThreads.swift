//
//  ForumThreads.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ForumThreads: JSONDecodable {
	let success: Bool?
	let page: Int?
	let threads: [JSON]?

	required init(json: JSON) throws {
		success = json["success"].boolValue
		page = json["page"].intValue
		threads = json["threads"].arrayValue
	}
}