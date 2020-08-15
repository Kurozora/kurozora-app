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
		/// The role of the cast.
		public let role: String
	}
}
