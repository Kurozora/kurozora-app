//
//  FeedSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class FeedSections: JSONDecodable {
	// MARK: - Properties
	internal let success: Bool?
	public let sections: [FeedSectionsElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
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

public class FeedSectionsElement: JSONDecodable {
	// MARK: - Properties
	public let id: Int?
	public let name: String?
	public let locked: Bool?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.name = json["name"].stringValue
		self.locked = json["locked"].boolValue
	}
}
