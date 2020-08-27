//
//  ActorRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 20/08/2020.
//

extension Actor {
	/**
		A root object that stores information about actor relationships, such as the shows, and characters that belong to it.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The shows belonging to the actor.
		public let shows: ShowResponse?

		/// The characters belonging to the actor.
		public let characters: CharacterResponse?
	}
}

