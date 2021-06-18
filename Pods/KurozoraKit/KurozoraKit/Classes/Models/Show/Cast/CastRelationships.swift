//
//  CastRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 15/08/2020.
//

extension Cast {
	/**
		A root object that stores information about cast relationships, such as the people, and characters that belong to it.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The people belonging to the cast.
		public let people: PersonResponse

		/// The characters belonging to the cast.
		public let characters: CharacterResponse
	}
}
