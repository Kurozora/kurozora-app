//
//  LiteratureRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2023.
//

extension Literature {
	/// A root object that stores information about literature relationships, such as the studios, and badges that belong to it.
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The cast belonging to the literature.
		public let cast: CastIdentityResponse?

		/// The characters belonging to the literature.
		public let characters: CharacterResponse?

		/// The people belonging to the literature.
		public let people: PersonResponse?

		/// The related shows belonging to the literature.
		public let relatedShows: RelatedShowResponse?

		/// The related literature belonging to the literature.
		public let relatedLiterature: RelatedLiteratureResponse?

		/// The staff belonging to the literature.
		public let staff: StaffResponse?

		/// The studios belonging to the literature.
		public let studios: StudioResponse?
	}
}
