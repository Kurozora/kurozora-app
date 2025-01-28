//
//  SessionRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/08/2020.
//

extension Session {
	/// A root object that stores information about session relationships, such as the user it belongs to, and the platform it was created on.
	public struct Relationships: Codable, Sendable {
		// MARK: - Properties
		/// The platform object on which the session was created.
		public let platform: PlatformResponse

		/// The location object for where the session was created.
		public let location: LocationResponse
	}
}
