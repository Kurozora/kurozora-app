//
//  SessionIdentity.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 21/07/2022.
//

/// A root object that stores information about a session identity resource.
public struct SessionIdentity: Codable, Hashable, Sendable {
	// MARK: - Properties
	/// The id of the resource.
	public let id: String

	/// The type of the resource.
	public let type: String

	/// The relative link to where the resource is located.
	public let href: String

	// MARK: - Initializers
	public init(id: String) {
		self.id = id
		self.type = "sessions"
		self.href = ""
	}

	// MARK: - Functions
	public static func == (lhs: SessionIdentity, rhs: SessionIdentity) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
