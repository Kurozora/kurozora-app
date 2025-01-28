//
//  FavoriteLibrary.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 16/11/2023.
//

/// A root object that stores information about a favorite library resource.
public struct FavoriteLibrary: Codable, Sendable {
	// MARK: - Properties
	/// A collection of games.
	public let games: [Game]?

	/// A collection of literatures.
	public let literatures: [Literature]?

	/// A collection of shows.
	public let shows: [Show]?
}
