//
//  ForumsSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of forums sections.
*/
public class ForumsSections: JSONDecodable {
	// MARK: - Properties
	/// The collection of forums sections.
    public let sections: [ForumsSectionsElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
		var sections = [ForumsSectionsElement]()

		let forumsSectionsArray = json["sections"].arrayValue
		for forumsSection in forumsSectionsArray {
			let forumsSectionsElement = try ForumsSectionsElement(json: forumsSection)
			sections.append(forumsSectionsElement)
		}

        self.sections = sections
    }
}

/**
	A mutable object that stores information about a single feed section, such as the sections's name, and lock status.
*/
public class ForumsSectionsElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the forums section.
	public let id: Int?

	/// The name of the forums section.
	public let name: String?

	/// The lock status of the forums section.
	public let lockStatus: LockStatus?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.lockStatus = LockStatus(rawValue: json["locked"].intValue)
	}
}
