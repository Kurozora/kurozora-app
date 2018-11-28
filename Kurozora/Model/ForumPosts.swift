//
//  ForumPosts.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

struct ForumPosts: JSONDecodable {
	let success: Bool?
	let message: String?
	let page: Int?
	let posts: [JSON]?

	init(json: JSON) throws {
		success = json["success"].boolValue
		message = json["error_message"].stringValue
		page = json["page"].intValue
		posts = json["posts"].arrayValue
	}
}

