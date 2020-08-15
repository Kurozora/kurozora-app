//
//  ForumsThread.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/11/2018.
//

/**
	A root object that stores information about a forums thread resource.
*/
public struct ForumsThread: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the forums thread.
	public var attributes: ForumsThread.Attributes

	/// The relationships belonging to the forums thread.
	public let relationships: ForumsThread.Relationships
}
