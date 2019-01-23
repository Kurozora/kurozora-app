//
//  VoteThread.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class VoteThread: JSONDecodable {
	let success: Bool?
	let action: Int?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.action = json["action"].intValue
	}
}
