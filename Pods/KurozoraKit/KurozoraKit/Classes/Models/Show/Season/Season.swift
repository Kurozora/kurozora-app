//
//  Season.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/**
	A root object that stores information about a season resource.
*/
public struct Season: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the season.
	public let attributes: Season.Attributes
}

