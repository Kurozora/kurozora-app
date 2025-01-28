//
//  GameRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/02/2023.
//

extension Game {
	/// A root object that stores information about game relationships, such as the studios, and cast that belong to it.
	public struct Relationships: Codable, Sendable {
		// MARK: - Properties
		/// The cast belonging to the game.
		public let cast: CastIdentityResponse?

		/// The characters belonging to the game.
		public let characters: CharacterIdentityResponse?

		/// The people belonging to the game.
		public let people: PersonIdentityResponse?
		
		/// The shows related to the game.
		public let relatedShows: RelatedShowResponse?

		/// The games related to the game.
		public let relatedGames: RelatedGameResponse?

		/// The literatures related to the game.
		public let relatedLiteratures: RelatedLiteratureResponse?

		/// The songs belonging to the game.
		public let songs: SongIdentityResponse?

		/// The staff belonging to the game.
		public let staff: StaffIdentityResponse?

		/// The studios belonging to the game.
		public let studios: StudioIdentityResponse?
	}
}
