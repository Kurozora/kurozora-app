//
//  LiteratureRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2023.
//

extension Literature {
	/// A root object that stores information about literature relationships, such as the studios, and cast that belong to it.
	public struct Relationships: Codable, Sendable {
		// MARK: - Properties
		/// The cast belonging to the literature.
		public let cast: CastIdentityResponse?

		/// The characters belonging to the literature.
		public let characters: CharacterIdentityResponse?

		/// The people belonging to the literature.
		public let people: PersonIdentityResponse?

		/// The shows related to the literature.
		public let relatedShows: RelatedShowResponse?

		/// The games related to the literature.
		public let relatedGames: RelatedGameResponse?

		/// The literatures related to the literature.
		public let relatedLiteratures: RelatedLiteratureResponse?

		/// The staff belonging to the literature.
		public let staff: StaffIdentityResponse?

		/// The studios belonging to the literature.
		public let studios: StudioIdentityResponse?
	}
}
