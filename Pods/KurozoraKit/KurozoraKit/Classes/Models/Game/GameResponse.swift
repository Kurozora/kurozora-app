//
//  GameResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/02/2023.
//

/// A root object that stores information about a collection of games.
public struct GameResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a game object request.
	public let data: [Game]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
