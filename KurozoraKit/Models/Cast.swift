//
//  Actors.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class Actors: JSONDecodable {
	// MARK: - Properties
    internal let success: Bool?
    public let totalActors: Int?
    public let actors: [ActorsElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
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

public class ActorsElement: JSONDecodable {
	// MARK: - Properties
	public let name: String?
	public let role: String?
	public let image: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.name = json["name"].stringValue
		self.role = json["role"].stringValue
		self.image = json["image"].stringValue
	}
}
