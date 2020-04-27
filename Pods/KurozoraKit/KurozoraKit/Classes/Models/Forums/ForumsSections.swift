//
//  ForumsSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of forums sections.
*/
public class ForumsSections: JSONDecodable {
	// MARK: - Properties
	/// The collection of forums sections.
    public let sections: [ForumsSectionElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
		var sections = [ForumsSectionElement]()

		let forumsSectionsArray = json["sections"].arrayValue
		for forumsSection in forumsSectionsArray {
			let forumsSectionElement = try ForumsSectionElement(json: forumsSection)
			sections.append(forumsSectionElement)
		}

        self.sections = sections
    }
}
