//
//  JSONError.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

// Throw json error
class JSONError: JSONDecodable {
	let success: Bool?
	let message: String?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.message = json["error_message"].stringValue
	}
}