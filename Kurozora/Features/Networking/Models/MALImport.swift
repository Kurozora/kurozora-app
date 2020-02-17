//
//  MALImport.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

class MALImport: JSONDecodable {
	var success: Bool?
	var message: String?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.message = json["message"].stringValue
	}
}
