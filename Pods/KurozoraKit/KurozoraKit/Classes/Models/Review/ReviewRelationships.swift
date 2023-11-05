//
//  ReviewRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/07/2023.
//

extension Review {
	/// A root object that stores information about review relationships, such as the user that belong to it.
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The users belonging to the review.
		public let users: UserResponse?
	}
}
