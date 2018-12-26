//
//  UserSearch.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class UserSearch: JSONDecodable {
	let success: Bool?
	let results: [JSON]?

	required init(json: JSON) throws {
		success = json["success"].boolValue
		results = json["results"].arrayValue
	}
}
