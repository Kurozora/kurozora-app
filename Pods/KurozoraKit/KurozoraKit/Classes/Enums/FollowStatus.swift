//
//  FollowStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	The set of available follow status types.

	```
	case unfollow = 0
	case follow = 1
	```
*/
public enum FollowStatus: Int {
	// MARK: - Cases
	/// Unfollow another user.
	case unfollow = 0

	/// Follow another user.
	case follow = 1
}
