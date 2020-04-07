//
//  ForumsSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class ForumsSections: JSONDecodable {
    public let success: Bool?
    public let sections: [ForumsSectionsElement]?

    required public init(json: JSON) throws {
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

public class ForumsSectionsElement: JSONDecodable {
	public let id: Int?
	public let name: String?
	public let locked: Bool?

	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.locked = json["locked"].boolValue
	}
}
