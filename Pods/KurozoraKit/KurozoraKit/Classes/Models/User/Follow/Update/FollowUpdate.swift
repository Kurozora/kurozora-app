//
//  FollowUpdate.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

/**
	A root object that stores information about a user follow update resource.
*/
public struct FollowUpdate: Codable {
	// MARK: - Properties
	/// Whether the user is followed or not.
	fileprivate var isFollowed: Bool?

	/// The follow status of the user.
	fileprivate var _followStatus: FollowStatus?
}

// MARK: - Helpers
extension FollowUpdate {
	// MARK: - Properties
	/// The follow status of the user.
	public var followStatus: FollowStatus {
		get {
			return self._followStatus ?? FollowStatus(self.isFollowed)
		}
		set {
			self._followStatus = newValue
		}
	}
}
