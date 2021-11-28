//
//  Session.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/08/2020.
//

/**
	A root object that stores information about a collection of session.
*/
public struct Session: Codable, Hashable {
	// MARK: - Properties
	/// The id of the resource.
	public let id: String

	/// The type of the resource.
	public let type: String

	/// The relative link to where the resource is located.
	public let href: String

	/// The attributes belonging to the session.
	public let attributes: Session.Attributes

	/// The relationships belonging to the session.
	public let relationships: Session.Relationships

	// MARK: - Functions
	public static func == (lhs: Session, rhs: Session) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
