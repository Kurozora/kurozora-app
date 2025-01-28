//
//  SongRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

extension Song {
	/// A root object that stores information about song relationships, such as the shows that belong to it.
	public struct Relationships: Codable, Sendable {
		// MARK: - Properties
		/// The shows belonging to the song.
		public let shows: ShowIdentityResponse?

		/// The games belonging to the song.
		public let games: GameIdentityResponse?
	}
}
