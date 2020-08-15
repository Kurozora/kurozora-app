//
//  ExploreCategory.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2018.
//

/**
	A root object that stores information about an explore category resource.
*/
public struct ExploreCategory: Codable {
	// MARK: - Properties
	/// The type of the resource.
	public let type: String

	/// The relative link to where the resource is located.
	public let href: String
	
	/// The attributes belonging to the explore category.
	public let attributes: ExploreCategory.Attributes

	/// The relationships belonging to the explore category.
	public let relationships: ExploreCategory.Relationships
}
