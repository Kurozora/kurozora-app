//
//  RelatedGameAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/03/2023.
//

extension RelatedGame {
	/// A root object that stores information about a single related game, such as the relation between the game.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The relation between the game.
		public let relation: MediaRelation
	}
}
