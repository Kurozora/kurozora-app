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
class JSONError: ErrorSerializable {
	var success: Bool?
	var message: String?

	required init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) {
		if let data = data {
			if let jsonFromData = try? JSON(data: data) {
				self.success = jsonFromData["success"].boolValue
				self.message = jsonFromData["error_message"].stringValue
				return
			}
		}

		self.success = false
		self.message = "There was an error while connecting to the server. If this error persists, check out our Twitter account @KurozoraApp for more information!"
	}
}
