//
//  ThreadReplyRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/08/2020.
//

extension ThreadReply {
	/**
		A root object that stores information about thread reply relationships, such as the user it belongs to.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The user object the thread reply belongs to.
		public let users: UserResponse
	}
}

