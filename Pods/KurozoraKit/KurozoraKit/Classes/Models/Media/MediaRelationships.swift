//
//  MediaRelationships.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/10/2024.
//

extension Media {
	/// A root object that stores information about media relationships, such as the episodes, and games that belong to it.
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The episodes belonging to the media.
		public let episodes: EpisodeIdentityResponse?

		/// The games belonging to the mdeia.
		public let games: GameIdentityResponse?

		/// The literatures belonging to the mdeia.
		public let literatures: LiteratureIdentityResponse?

		/// The shows belonging to the mdeia.
		public let shows: ShowIdentityResponse?
	}
}
