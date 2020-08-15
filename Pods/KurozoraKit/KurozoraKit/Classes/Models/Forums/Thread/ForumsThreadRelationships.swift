//
//  ForumsThreadRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/08/2020.
//

extension ForumsThread {
	/**
		A root object that stores information about forums thread relationships, such as the user it belongs to.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The user object the forums thread belongs to.
		public let user: UserResponse
	}
}
