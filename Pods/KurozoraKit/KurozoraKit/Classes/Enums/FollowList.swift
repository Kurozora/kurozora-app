//
//  FollowList.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/// The set of available follow list types.
///
/// ```
/// case followers = "followers"
/// case following = "following"
/// ```
public enum FollowList: String {
	// MARK: - Cases
	/// The user's followers list.
	case followers

	/// The user's following list.
	case following

	// MARK: - Properties
	/// The string value of a follow list.
	public var stringValue: String {
		switch self {
		case .followers:
			return "Followers"
		case .following:
			return "Following"
		}
	}
}
