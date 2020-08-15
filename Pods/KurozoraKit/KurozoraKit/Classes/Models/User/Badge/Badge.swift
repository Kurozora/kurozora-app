//
//  BadgeElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

/**
	A root object that stores information about a badge resource.
*/
public struct Badge: Codable {
	// MARK: - Properties
	/// The id of the resource.
	public let id: Int

	/// The type of the resource.
	public let type: String

	/// The attributes belonging to the badge.
	public var attributes: Badge.Attributes
}
