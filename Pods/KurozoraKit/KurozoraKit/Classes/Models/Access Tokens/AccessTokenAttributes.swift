//
//  AccessTokenAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension AccessToken {
	/**
		A root object that stores information about a single access token, such as the token's ip address, and last validated date.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The ip address form where the access token was created.
		public let ipAddress: String

		/// The last time the access token has been validated.
		public let lastValidatedAt: String?
	}
}
