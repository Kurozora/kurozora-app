//
//  Cast.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/06/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of cast members.
*/
public class Cast: JSONDecodable {
	// MARK: - Properties
	/// The collection of cast.
	public let cast: [CastElement]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		var cast = [CastElement]()

		let castArray = json["cast"].arrayValue
		for castItem in castArray {
			if let castElement = try? CastElement(json: castItem) {
				cast.append(castElement)
			}
		}

		self.cast = cast
	}
}
