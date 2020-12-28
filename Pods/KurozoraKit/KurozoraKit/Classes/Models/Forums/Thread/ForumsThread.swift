//
//  ForumsThread.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/11/2018.
//

/**
	A root object that stores information about a forums thread resource.
*/
public class ForumsThread: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// The attributes belonging to the forums thread.
	public var attributes: ForumsThread.Attributes

	/// The relationships belonging to the forums thread.
	public let relationships: ForumsThread.Relationships

	// MARK: - Functions
	public static func == (lhs: ForumsThread, rhs: ForumsThread) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
