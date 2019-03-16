//
//  Actors.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Actors: JSONDecodable {
    let success: Bool?
    let totalActors: Int?
    let actors: [ActorsElement]?

    required init(json: JSON) throws {
        self.success = json["success"].boolValue
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

class ActorsElement: JSONDecodable {
	let name: String?
	let role: String?
	let image: String?

	required init(json: JSON) throws {
		self.name = json["name"].stringValue
		self.role = json["role"].stringValue
		self.image = json["image"].stringValue
	}
}
