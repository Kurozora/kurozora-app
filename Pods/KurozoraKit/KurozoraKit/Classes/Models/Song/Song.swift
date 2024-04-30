//
//  Song.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/// A root object that stores information about a song resource.
public class Song: IdentityResource, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, href, attributes, relationships
	}

	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the song.
	public var attributes: Song.Attributes

	/// The relationships belonging to the song.
	public let relationships: Song.Relationships?

	// MARK: - Functions
	public static func == (lhs: Song, rhs: Song) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
