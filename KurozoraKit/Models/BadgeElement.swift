//
//  BadgeElement.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class BadgeElement: JSONDecodable {
	let id: Int?
	let text: String?
	let description: String?
	let textColor: String?
	let backgroundColor: String?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.text = json["text"].stringValue
		self.description = json["description"].stringValue
		self.textColor = json["textColor"].stringValue
		self.backgroundColor = json["backgroundColor"].stringValue
	}
}
