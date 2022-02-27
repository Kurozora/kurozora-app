//
//  ExploreCategoryRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

extension ExploreCategory {
	/**
		A root object that stores information about explore category relationships, such as the shows, genres, and characters that belong to it.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The shows belonging to the explore category.
		public let shows: ShowResponse?

		/// The shows belonging to the explore category.
		public let showSongs: ShowSongResponse?

		/// The genres belonging to the explore category.
		public let genres: GenreResponse?

		/// The themes belonging to the explore category.
		public let themes: ThemeResponse?

		/// The characters belonging to the explore category.
		public let characters: CharacterResponse?

		/// The people belonging to the explore category.
		public let people: PersonResponse?
	}
}
