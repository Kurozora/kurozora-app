//
//  ForumsSection.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 11/10/2018.
//

/**
	A root object that stores information about a forums section resource.
*/
public struct ForumsSection: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the forums section.
	public let attributes: ForumsSection.Attributes

	// MARK: - Functions
	public static func == (lhs: ForumsSection, rhs: ForumsSection) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
