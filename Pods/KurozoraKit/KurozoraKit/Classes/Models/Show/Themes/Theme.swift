//
//  Theme.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

/**
	A root object that stores information about a theme resource.
*/
public struct Theme: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the genre.
	public let attributes: Theme.Attributes

	// MARK: - Functions
	public static func == (lhs: Theme, rhs: Theme) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
