//
//  CastElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/06/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single cast, such as the actor, and character in cast.
*/
public class CastElement: JSONDecodable {
	// MARK: - Properties
	/// The actor in the cast.
	public let actor: ActorElement?

	/// The character in the cast.
	public let character: CharacterElement?

	/// The role of the cast.
	public let role: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.actor = try? ActorElement(json: json["actor"])
		self.character = try? CharacterElement(json: json["character"])
		self.role = json["cast_role"].stringValue
	}
}
