//
//  ForumSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ForumSections: JSONDecodable {
    let success: Bool?
    let sections: [ForumSectionsElement]?

    required init(json: JSON) throws {
        self.success = json["success"].boolValue
		var sections = [ForumSectionsElement]()

		let forumSectionsArray = json["sections"].arrayValue
		for forumSection in forumSectionsArray {
			let forumSectionsElement = try ForumSectionsElement(json: forumSection)
			sections.append(forumSectionsElement)
		}

        self.sections = sections
    }
}

class ForumSectionsElement: JSONDecodable {
	let id: Int?
	let name: String?
	let locked: Bool?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.locked = json["locked"].boolValue
	}
}
