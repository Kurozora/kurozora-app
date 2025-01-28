//
//  ShowRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

extension Show {
	/// A root object that stores information about show relationships, such as the studios, and cast that belong to it.
	public struct Relationships: Codable, Sendable {
		// MARK: - Properties
		/// The cast belonging to the show.
		public let cast: CastIdentityResponse?

		/// The characters belonging to the show.
		public let characters: CharacterIdentityResponse?

		/// The people belonging to the show.
		public let people: PersonIdentityResponse?

		/// The shows related to the show.
		public let relatedShows: RelatedShowResponse?

		/// The games related to the show.
		public let relatedGames: RelatedGameResponse?

		/// The literatures related to the show.
		public let relatedLiteratures: RelatedLiteratureResponse?

		/// The seasons belonging to the show.
		public let seasons: SeasonIdentityResponse?

		/// The relationships belonging to the show.
		public let showSongs: ShowSongResponse?

		/// The songs belonging to the game.
		public let songs: SongIdentityResponse?

		/// The staff belonging to the show.
		public let staff: StaffIdentityResponse?

		/// The studios belonging to the show.
		public let studios: StudioIdentityResponse?
	}
}
