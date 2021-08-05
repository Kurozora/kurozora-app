//
//  StudioRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

extension Studio {
	/**
		A root object that stores information about studio relationships, such as the shows that belong to it.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The shows created by the studio.
		public let shows: ShowIdentityResponse?
	}
}
