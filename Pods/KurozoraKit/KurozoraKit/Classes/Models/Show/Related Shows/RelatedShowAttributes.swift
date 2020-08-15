//
//  RelatedShowAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

extension RelatedShow {
	/**
		A root object that stores information about a single related show, such as the show's type.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The type of relation with the parent show.
		public let type: String
	}
}
