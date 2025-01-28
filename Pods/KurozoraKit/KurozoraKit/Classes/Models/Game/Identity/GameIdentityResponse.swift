//
//  GameIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/02/2023.
//

/// A root object that stores information about a collection of game identities.
public struct GameIdentityResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a game identity object request.
	public let data: [GameIdentity]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
