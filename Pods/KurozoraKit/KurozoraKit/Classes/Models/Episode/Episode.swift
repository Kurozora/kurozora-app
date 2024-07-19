//
//  Episode.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/// A root object that stores information about an episode resource.
public class Episode: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: String

	public let type: String

	public let href: String

	/// The attributes belonging to the episode.
	public var attributes: Episode.Attributes

	/// The relationships belonging to the episode.
	public let relationships: Episode.Relationships?

	// MARK: - Functions
	public static func == (lhs: Episode, rhs: Episode) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
