//
//  UserRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/08/2020.
//

extension User {
	/// A root object that stores information about user relationships, such as the sessions, and badges that belong to it.
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The access tokens belonging to the user.
		public let accessTokens: AccessTokenResponse?

		/// The badges belonging to the user.
		public let badges: BadgeResponse?
	}
}
