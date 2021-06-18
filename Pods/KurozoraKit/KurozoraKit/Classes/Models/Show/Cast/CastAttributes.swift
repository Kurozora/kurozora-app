//
//  CastElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/06/2020.
//


extension Cast {
	/**
		A root object that stores information about a single cast, such as the role.
	*/
	public class Attributes: Codable {
		// MARK: - Properties
		/// The object containing the cast role information.
		public let role: CastRole

		/// The language in which the cast played.
		public let language: String?
	}
}
