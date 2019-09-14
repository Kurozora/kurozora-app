//
//  ForumsSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ForumsSections: JSONDecodable {
    let success: Bool?
    let sections: [ForumsSectionsElement]?

    required init(json: JSON) throws {
        self.success = json["success"].boolValue
		var sections = [ForumsSectionsElement]()

		let forumsSectionsArray = json["sections"].arrayValue
		for forumsSection in forumsSectionsArray {
			let forumsSectionsElement = try ForumsSectionsElement(json: forumsSection)
			sections.append(forumsSectionsElement)
		}

        self.sections = sections
    }
}

class ForumsSectionsElement: JSONDecodable {
	let id: Int?
	let name: String?
	let locked: Bool?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.locked = json["locked"].boolValue
	}
}
