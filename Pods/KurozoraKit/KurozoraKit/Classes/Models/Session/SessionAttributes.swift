//
//  SessionAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension Session {
	/**
		A root object that stores information about a single session, such as the session's ip address, last validated date, and platform.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The ip address form where the session was created.
		public let ip: String

		/// The last time the session has been validated.
		public let lastValidatedAt: String
	}
}
