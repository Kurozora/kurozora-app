//
//  Legal.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

/**
	A root object that stores information about a legal resource.
*/
public struct Legal: Codable {
	// MARK: - Properties
	/// The type of the legal resource.
	public let type: String

	/// The relative link to where the legal resource is located.
	public let href: String

	/// The attributes belonging to the legal resource.
	public let attributes: Legal.Attributes
}
