//
//  ExploreCategoryRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

extension ExploreCategory {
	/**
		A root object that stores information about explore category relationships, such as the shows, and genres that belong to it.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The shows belonging to the explore category.
		public let shows: ShowResponse?

		/// The genres belonging to the explore category.
		public let genres: GenreResponse?
	}
}
