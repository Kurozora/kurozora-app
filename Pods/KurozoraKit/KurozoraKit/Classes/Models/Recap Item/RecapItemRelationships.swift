//
//  RecapItemRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/01/2024.
//

extension RecapItem {
	/// A root object that stores information about recap item relationships, such as the shows, genres, and characters that belong to it.
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The shows belonging to the recap.
		public let shows: ShowIdentityResponse?

		/// The games belonging to the recap.
		public let games: GameIdentityResponse?

		/// The literature belonging to the recap.
		public let literatures: LiteratureIdentityResponse?

		/// The episodes belonging to the recap.
		public let episodes: EpisodeIdentityResponse?

		/// The shows belonging to the recap.
		public let showSongs: ShowSongResponse?

		/// The genres belonging to the recap.
		public let genres: GenreIdentityResponse?

		/// The themes belonging to the recap.
		public let themes: ThemeIdentityResponse?

		/// The characters belonging to the recap.
		public let characters: CharacterIdentityResponse?

		/// The people belonging to the recap.
		public let people: PersonIdentityResponse?
	}
}
