//
//  Library.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/11/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Library: JSONDecodable {
	let success: Bool?
	let message: String?
	let library: [JSON]?

	required init(json: JSON) throws {
		success = json["success"].boolValue
		message = json["error_message"].stringValue
		library = json["library"].arrayValue
	}
}
