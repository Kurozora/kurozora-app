//
//  ShowRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

extension Show {
	/**
		A root object that stores information about show relationships, such as the studios, and badges that belong to it.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The cast belonging to the show.
		public let cast: CastResponse?

		/// The characters belonging to the show.
		public let characters: CharacterResponse?

		/// The relationships belonging to the show.
		public let relatedShows: RelatedShowResponse?

		/// The seasons belonging to the show.
		public let seasons: SeasonResponse?

		/// The staff belonging to the show.
		public let staff: StaffResponse?

		/// The studios belonging to the show.
		public let studios: StudioResponse?
	}
}
