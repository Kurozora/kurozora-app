//
//  Language.swift
//  Alamofire
//
//  Created by Khoren Katklian on 13/07/2021.
//

/**
	A root object that stores information about a language resource.
*/
public struct Language: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the language.
	public let attributes: Language.Attributes

	// MARK: - Functions
	public static func == (lhs: Language, rhs: Language) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
