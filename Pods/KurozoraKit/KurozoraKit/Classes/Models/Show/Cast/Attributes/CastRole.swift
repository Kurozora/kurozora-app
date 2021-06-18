//
//  CastRole.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/06/2021.
//

import Foundation

/**
	A root object that stores information about a cast role resource.
*/
public struct CastRole: Codable, Hashable {
	// MARK: - Properties
	/// The name of the cast role.
	public let name: String

	/// The description of the cast role.
	public let description: String

	// MARK: - Functions
	public static func == (lhs: CastRole, rhs: CastRole) -> Bool {
		return lhs.name == rhs.name
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.name)
	}
}
