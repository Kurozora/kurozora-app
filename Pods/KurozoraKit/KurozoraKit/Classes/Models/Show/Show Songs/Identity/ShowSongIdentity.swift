//
//  ShowSongIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/**
	A root object that stores information about a show song identity resource.
*/
public class ShowSongIdentity: IdentityResource, Hashable {
	public let id: Int

	public let type: String

	public let href: String

	// MARK: - Functions
	public static func == (lhs: ShowSongIdentity, rhs: ShowSongIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
