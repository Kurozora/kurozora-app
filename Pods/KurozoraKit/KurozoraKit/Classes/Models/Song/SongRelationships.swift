//
//  ShowRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

extension Song {
	/**
		A root object that stores information about show relationships, such as the people that belong to it.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The people belonging to the show.
		public let characters: PersonResponse?
	}
}
