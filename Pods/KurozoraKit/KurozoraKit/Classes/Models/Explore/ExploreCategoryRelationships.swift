//
//  ExploreCategoryRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

extension ExploreCategory {
	/// A root object that stores information about explore category relationships, such as the shows, genres, and characters that belong to it.
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The shows belonging to the explore category.
		public let shows: ShowIdentityResponse?

		/// The games belonging to the explore category.
		public let games: GameIdentityResponse?

		/// The literature belonging to the explore category.
		public let literatures: LiteratureIdentityResponse?

		/// The episodes belonging to the explore category.
		public let episodes: EpisodeIdentityResponse?

		/// The shows belonging to the explore category.
		public let showSongs: ShowSongResponse?

		/// The genres belonging to the explore category.
		public let genres: GenreIdentityResponse?

		/// The themes belonging to the explore category.
		public let themes: ThemeIdentityResponse?

		/// The characters belonging to the explore category.
		public let characters: CharacterIdentityResponse?

		/// The people belonging to the explore category.
		public let people: PersonIdentityResponse?

		/// The Re:CAP belonging to the explore category.
		public let recaps: RecapResponse?
	}
}
