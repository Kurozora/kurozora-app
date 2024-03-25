//
//  ReviewRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/07/2023.
//

extension Review {
	/// A root object that stores information about review relationships, such as the user that belong to it.
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The shows belonging to the rating.
		public let shows: ShowIdentityResponse?

		/// The games belonging to the rating.
		public let games: GameIdentityResponse?

		/// The literature belonging to the rating.
		public let literatures: LiteratureIdentityResponse?

		/// The episodes belonging to the rating.
		public let episodes: EpisodeIdentityResponse?

		/// The songs belonging to the rating.
		public let songs: SongIdentityResponse?

		/// The characters belonging to the rating.
		public let characters: CharacterIdentityResponse?

		/// The people belonging to the rating.
		public let people: PersonIdentityResponse?

		/// The studios belonging to the rating.
		public let studios: StudioIdentityResponse?

		/// The users belonging to the review.
		public let users: UserResponse?
	}
}
