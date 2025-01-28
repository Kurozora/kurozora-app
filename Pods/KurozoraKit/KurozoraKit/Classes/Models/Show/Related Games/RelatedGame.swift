//
//  RelatedGame.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/03/2023.
//

/// A root object that stores information about a related game resource.
public struct RelatedGame: Codable, Hashable, Sendable {
	// MARK: - Properties
	/// The id of the related game.
	public let id: UUID = UUID()

	/// The game related to the parent game.
	public let game: Game

	/// The attributes belonging to the related game.
	public var attributes: RelatedGame.Attributes

	// MARK: - CodingKeys
	enum CodingKeys: String, CodingKey {
		case game
		case attributes
	}

	// MARK: - Functions
	public static func == (lhs: RelatedGame, rhs: RelatedGame) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
