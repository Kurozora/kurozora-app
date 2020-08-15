//
//  Genre.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

/**
	A root object that stores information about a genre resource.
*/
public struct Genre: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the genre.
	public let attributes: Genre.Attributes
}
