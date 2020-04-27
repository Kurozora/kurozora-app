//
//  FeedSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of feed sections.
*/
public class FeedSections: JSONDecodable {
	// MARK: - Properties
	/// The collection of feed sections.
	public let sections: [FeedSectionElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		var sections = [FeedSectionElement]()

		let feedSectionsArray = json["sections"].arrayValue
		for feedSection in feedSectionsArray {
			let feedSectionElement = try FeedSectionElement(json: feedSection)
			sections.append(feedSectionElement)
		}

		self.sections = sections
	}
}
