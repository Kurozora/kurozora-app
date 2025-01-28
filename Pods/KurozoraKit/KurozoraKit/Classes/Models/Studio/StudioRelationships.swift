//
//  StudioRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

extension Studio {
	/// A root object that stores information about studio relationships, such as the shows that belong to it.
	public struct Relationships: Codable, Sendable {
		// MARK: - Properties
		/// The studio' predecessors.
		public let predecessors: StudioIdentityResponse?

		/// The studio's successors.
		public let successors: StudioIdentityResponse?

		/// The shows created by the studio.
		public let shows: ShowIdentityResponse?

		/// The games created by the studio.
		public let games: GameIdentityResponse?

		/// The literatures created by the studio.
		public let literatures: LiteratureIdentityResponse?
	}
}
