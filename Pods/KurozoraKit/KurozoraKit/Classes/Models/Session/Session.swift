//
//  Session.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/08/2020.
//

/**
	A root object that stores information about a collection of session.
*/
public struct Session: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the session.
	public let attributes: Session.Attributes

	/// The relationships belonging to the session.
	public let relationships: Session.Relationships
}
