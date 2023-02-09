//
//  Library.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/02/2023.
//

/// A root object that stores information about a library resource.
public struct Library: Codable {
	// MARK: - Properties
	/// A collection of games.
	public let games: [Game]?

	/// A collection of literatures.
	public let literatures: [Literature]?

	/// A collection of shows.
	public let shows: [Show]?
}
