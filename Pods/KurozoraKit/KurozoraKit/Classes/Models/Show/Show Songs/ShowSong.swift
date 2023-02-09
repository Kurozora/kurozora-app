//
//  ShowSong.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/// A root object that stores information about a show song resource.
public class ShowSong: IdentityResource, Hashable {
	// MARK: - Enums
	public enum CodingKeys : String, CodingKey {
		case id = "uuid", type, href, show, song, attributes
	}

	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The show belonging to the show song.
	public let show: Show?

	/// The song belonging to the show song.
	public let song: Song

	/// The attributes belonging to the show song.
	public var attributes: ShowSong.Attributes

	// MARK: - Functions
	public static func == (lhs: ShowSong, rhs: ShowSong) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
