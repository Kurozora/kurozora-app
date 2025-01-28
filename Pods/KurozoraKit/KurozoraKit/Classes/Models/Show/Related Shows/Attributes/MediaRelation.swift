//
//  MediaRelation.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/06/2021.
//

/// A root object that stores information about a media relation.
public struct MediaRelation: Codable, Hashable, Sendable {
	// MARK: - Properties
	/// The name of the relation with the parent show.
	public let name: String

	/// The description of the relation with the parent show.
	public let description: String

	// MARK: - Functions
	public static func == (lhs: MediaRelation, rhs: MediaRelation) -> Bool {
		return lhs.name == rhs.name
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.name)
	}
}
