//
//  Actors.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of actors, such as the total actor count, and a collection of actors.
*/
public class Actors: JSONDecodable {
	// MARK: - Properties
	/// The total count of actors associated with the show.
    public let totalActors: Int?

	/// The request collection of actors.
    public let actors: [ActorElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
        self.totalActors = json["total_actors"].intValue
        var actors = [ActorElement]()

		let actorsArray = json["actors"].arrayValue
		for actorItem in actorsArray {
			if let actorElement = try? ActorElement(json: actorItem) {
				actors.append(actorElement)
			}
		}

		self.actors = actors
    }
}
