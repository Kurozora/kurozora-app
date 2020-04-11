//
//  FeedSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of feed sections.
*/
public class FeedSections: JSONDecodable {
	// MARK: - Properties
	/// The collection of feed sections.
	public let sections: [FeedSectionsElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		var sections = [FeedSectionsElement]()

		let feedSectionsArray = json["sections"].arrayValue
		for feedSection in feedSectionsArray {
			let feedSectionsElement = try FeedSectionsElement(json: feedSection)
			sections.append(feedSectionsElement)
		}

		self.sections = sections
	}
}

/**
	A mutable object that stores information about a single feed section, such as the section's name, and lock status.
*/
public class FeedSectionsElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the feed section.
	public let id: Int?

	/// The name of the feed section.
	public let name: String?

	/// The lock status of the feed section.
	public let lockStatus: LockStatus?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.lockStatus = LockStatus(rawValue: json["locked"].intValue)
	}
}
