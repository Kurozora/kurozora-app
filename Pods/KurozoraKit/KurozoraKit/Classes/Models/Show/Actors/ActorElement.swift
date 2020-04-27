//
//  ActorElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single actor, such as the actor's name, role, and image.
*/
public class ActorElement: JSONDecodable {
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
