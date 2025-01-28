//
//  AccessTokenRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/08/2020.
//

extension AccessToken {
	/// A root object that stores information about access token relationships, such as the user it belongs to, and the platform it was created on.
	public struct Relationships: Codable, Sendable {
		// MARK: - Properties
		/// The platform object on which the access token was created.
		public let platform: PlatformResponse

		/// The location object for where the access token was created.
		public let location: LocationResponse
	}
}
