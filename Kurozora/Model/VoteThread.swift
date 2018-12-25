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

	required init(json: JSON) throws {
		success = json["success"].boolValue
	}
}
