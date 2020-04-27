//
//  Seasons.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of seasons.
*/
public class Seasons: JSONDecodable {
	// MARK: - Properties
	/// The collection of seasons.
    public let seasons: [SeasonElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
		var seasons = [SeasonElement]()

		let seasonsArray = json["seasons"].arrayValue
		for seasonItem in seasonsArray {
			if let seasonElement = try? SeasonElement(json: seasonItem) {
				seasons.append(seasonElement)
			}
		}
        self.seasons = seasons
    }
}
