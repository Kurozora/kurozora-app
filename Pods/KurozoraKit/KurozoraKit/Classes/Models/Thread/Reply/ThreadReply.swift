//
//  ThreadReply.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/12/2018.
//

/**
	A root object that stores information about thread reply resource.
*/
public struct ThreadReply: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the thread reply
	public let attributes: ThreadReply.Attributes

	/// The relationships belonging to the thread reply
	public let relationships: ThreadReply.Relationships
}
