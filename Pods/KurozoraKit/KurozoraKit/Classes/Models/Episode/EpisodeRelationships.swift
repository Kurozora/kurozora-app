//
//  EpisodeRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 19/07/2023.
//

extension Episode {
	/// A root object that stores information about episode relationships, such as the season, and show that belong to it.
	public struct Relationships: Codable, Sendable {
		// MARK: - Properties
		/// The seasons belonging to the episode.
		public let seasons: SeasonIdentityResponse?

		/// The shows belonging to the episode.
		public let shows: ShowIdentityResponse?

		/// The previous episodes belonging to the episode.
		public let previousEpisodes: EpisodeIdentityResponse?

		/// The next episodes belonging to the episode.
		public let nextEpisodes: EpisodeIdentityResponse?
	}
}
