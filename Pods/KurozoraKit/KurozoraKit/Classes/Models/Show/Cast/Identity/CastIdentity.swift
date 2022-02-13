//
//  CastIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 12/02/2022.
//

/**
	A root object that stores information about a season identity resource.
*/
public class CastIdentity: IdentityResource, Hashable {
	public let id: Int

	public let type: String

	public let href: String

	// MARK: - Functions
	public static func == (lhs: CastIdentity, rhs: CastIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
