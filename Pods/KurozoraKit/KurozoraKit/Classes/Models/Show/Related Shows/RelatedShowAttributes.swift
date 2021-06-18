//
//  RelatedShowAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

extension RelatedShow {
	/**
		A root object that stores information about a single related show, such as the relation between the shows.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The relation between the shows.
		public let relation: MediaRelation
	}
}
