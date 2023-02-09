//
//  GameRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/02/2023.
//

extension Game {
	/// A root object that stores information about game relationships, such as the studios, and badges that belong to it.
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The cast belonging to the game.
		public let cast: CastIdentityResponse?

		/// The characters belonging to the game.
		public let characters: CharacterResponse?

		/// The people belonging to the game.
		public let people: PersonResponse?

		/// The related shows belonging to the game.
		public let relatedShows: RelatedShowResponse?

		/// The related literature belonging to the game.
		public let relatedLiterature: RelatedLiteratureResponse?

		/// The staff belonging to the game.
		public let staff: StaffResponse?

		/// The studios belonging to the game.
		public let studios: StudioResponse?
	}
}
