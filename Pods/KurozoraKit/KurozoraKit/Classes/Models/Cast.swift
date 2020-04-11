//
//  Actors.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of actors, such as the total actor count, and a collection of actors.
*/
public class Actors: JSONDecodable {
	// MARK: - Properties
	/// The total count of actors associated with the show.
    public let totalActors: Int?

	/// The request collection of actors.
    public let actors: [ActorsElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
        self.totalActors = json["total_actors"].intValue
        var actors = [ActorsElement]()

		let actorsArray = json["actors"].arrayValue
		for actorItem in actorsArray {
			if let actorElement = try? ActorsElement(json: actorItem) {
				actors.append(actorElement)
			}
		}

		self.actors = actors
    }
}

/**
	A mutable object that stores information about a single actor, such as the actor's name, role, and image.
*/
public class ActorsElement: JSONDecodable {
	// MARK: - Properties
	/// The name of the actor.
	public let name: String?

	/// The role of the actor in the show.
	public let role: String?

	/// The link to an image of the actor.
	public let image: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.name = json["name"].stringValue
		self.role = json["role"].stringValue
		self.image = json["image"].stringValue
	}
}
