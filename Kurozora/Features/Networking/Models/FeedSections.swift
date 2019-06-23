//
//  FeedSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class FeedSections: JSONDecodable {
	let success: Bool?
	let sections: [FeedSectionsElement]?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		var sections = [FeedSectionsElement]()

		let feedSectionsArray = json["sections"].arrayValue
		for feedSection in feedSectionsArray {
			let feedSectionsElement = try FeedSectionsElement(json: feedSection)
			sections.append(feedSectionsElement)
		}

		self.sections = sections
	}
}

class FeedSectionsElement: JSONDecodable {
	let id: Int?
	let name: String?
	let locked: Bool?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.locked = json["locked"].boolValue
	}
}
