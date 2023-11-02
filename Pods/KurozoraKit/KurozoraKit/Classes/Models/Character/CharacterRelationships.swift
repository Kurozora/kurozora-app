//
//  CharacterRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 20/08/2020.
//

extension Character {
	/// A root object that stores information about character relationships, such as the shows, and people that belong to it.
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The people that played the character.
		public let people: PersonIdentityResponse?

		/// The shows in which the character showed up.
		public let shows: ShowIdentityResponse?

		/// The games in which the character showed up.
		public let games: GameIdentityResponse?

		/// The literatures in which the character showed up.
		public let literatures: LiteratureIdentityResponse?
	}
}
