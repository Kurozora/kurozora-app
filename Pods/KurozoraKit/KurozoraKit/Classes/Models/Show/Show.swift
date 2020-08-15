//
//  Show.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/**
	A root object that stores information about a show resource.
*/
public struct Show: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the show.
	public var attributes: Show.Attributes

	/// The relationships belonging to the show.
	public let relationships: Show.Relationships?
}
