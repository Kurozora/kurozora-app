//
//  UserFollow.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class UserFollow: JSONDecodable {
	let success: Bool?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
	}
}
