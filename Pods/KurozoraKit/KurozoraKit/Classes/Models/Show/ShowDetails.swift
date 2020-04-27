//
//  ShowDetails.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of shows.
*/
public class ShowDetails: JSONDecodable {
	// MARK: - Properties
	/// The single show details object.
	public var showDetailsElement: ShowDetailsElement?

	/// The collection view of show details.
	public let showDetailsElements: [ShowDetailsElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.showDetailsElement = try? ShowDetailsElement(json: json["anime"])

		var showDetailsElements = [ShowDetailsElement]()
		let showDetailsElementsArray = json["anime"].arrayValue
		for showDetailsElementItem in showDetailsElementsArray {
			if let showDetailsElement = try? ShowDetailsElement(json: showDetailsElementItem) {
				showDetailsElements.append(showDetailsElement)
			}
		}
		self.showDetailsElements = showDetailsElements
	}
}
