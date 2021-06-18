//
//  PersonRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 20/08/2020.
//

extension Person {
	/**
		A root object that stores information about person relationships, such as the shows, and characters that belong to it.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The shows belonging to the person.
		public let shows: ShowResponse?

		/// The characters belonging to the person.
		public let characters: CharacterResponse?
	}
}

