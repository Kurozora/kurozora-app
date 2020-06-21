//
//  Studios.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/06/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of studios.
*/
public class Studios: JSONDecodable {
	// MARK: - Properties
	/// The single studio object.
	public var studioElement: StudioElement?

	/// The collection of studios.
	public let studios: [StudioElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.studioElement = try? StudioElement(json: json["studio"])

		var studios = [StudioElement]()
		let studiosArray = json["studios"].arrayValue
		for studioItem in studiosArray {
			if let studioElement = try? StudioElement(json: studioItem) {
				studios.append(studioElement)
			}
		}
		self.studios = studios
	}
}
