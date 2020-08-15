//
//  Cast.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/06/2020.
//

/**
	A root object that stores information about a cast resource.
*/
public struct Cast: Codable {
	// MARK: - Properties
	/// The type of the resource.
	public let type: String

	/// The relative link to where the resource is located.
	public let href: String

	/// The attributes belonging to the show.
	public var attributes: Cast.Attributes

	/// The relationships belonging to the show.
	public let relationships: Cast.Relationships
}
