//
//  ActorAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Actor {
	/**
		A root object that stores information about a single actor, such as the actor's name, role, and image.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The first name of the actor.
		public let firstName: String

		/// The last name of the actor.
		public let lastName: String

		/// The biogrpahy of the actor.
		public let about: String?

		/// The occupation of the actor.
		public let occupation: String?

		/// The link to an image of the actor.
		public let imageURL: String?
	}
}
