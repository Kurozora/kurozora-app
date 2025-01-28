//
//  Game.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/02/2023.
//

/// A root object that stores information about a game resource.
public final class Game: IdentityResource, Hashable, @unchecked Sendable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the game.
	public var attributes: Game.Attributes

	/// The relationships belonging to the game.
	public let relationships: Game.Relationships?

	// MARK: - Functions
	public static func == (lhs: Game, rhs: Game) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
