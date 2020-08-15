//
//  Theme.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/02/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

/**
	A root object that stores information about a theme resource.
*/
public struct Theme: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the theme.
	public let attributes: Theme.Attributes
}
