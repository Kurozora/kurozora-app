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
	/// The id of the actor.
	public let id: Int?

	/// The first name of the actor.
	public let firstName: String?

	/// The last name of the actor.
	public let lastName: String?

	/// The occupation of the actor.
	public let occupation: String?

	/// The link to an image of the actor.
	public let imageString: String?

	// MARK: - Initializers
	/// Initializes an empty instance of `ActorElement`.
	internal init() {
		self.id = nil
		self.firstName = nil
		self.lastName = nil
		self.occupation = nil
		self.imageString = nil
	}

	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.firstName = json["first_name"].stringValue
		self.lastName = json["last_name"].stringValue
		self.occupation = json["occupation"].stringValue
		self.imageString = json["image"].stringValue
	}
}

// MARK: - Helpers
extension ActorElement {
	/// The full name of the actor.
	public var fullName: String? {
		guard let lastName = self.lastName else { return nil }
		guard let firstName = self.firstName else { return nil }
		return lastName.isEmpty ? firstName : lastName + ", " + firstName
	}
}
