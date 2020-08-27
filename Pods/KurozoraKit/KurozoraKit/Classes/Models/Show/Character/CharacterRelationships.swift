//
//  CharacterRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 20/08/2020.
//

extension Character {
	/**
		A root object that stores information about character relationships, such as the shows, and actors that belong to it.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The shows belonging to the character.
		public let shows: ShowResponse?

		/// The actors belonging to the character.
		public let actors: ActorResponse?
	}
}
