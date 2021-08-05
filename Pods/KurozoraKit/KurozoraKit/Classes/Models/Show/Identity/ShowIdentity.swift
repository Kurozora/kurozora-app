//
//  ShowIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 20/07/2021.
//

/**
	A root object that stores information about a show identity resource.
*/
public class ShowIdentity: IdentityResource, Hashable {
	public let id: Int

	public let type: String

	public let href: String

	// MARK: - Functions
	public static func == (lhs: ShowIdentity, rhs: ShowIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
