//
//  Explore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of explore categories.
*/
public class Explore: JSONDecodable {
	// MARK: - Properties
	/// The collection of categories.
	public let categories: [ExploreCategory]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
		var categories = [ExploreCategory]()
		let categoriesArray = json["categories"].arrayValue
		for categoriesItem in categoriesArray {
			if let exploreCategory = try? ExploreCategory(json: categoriesItem) {
				categories.append(exploreCategory)
			}
		}
		self.categories = categories
    }
}
