//
//  UserType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	Type of users which represents what level of access does each user have in the app.

	```
	case normal = 0
	case mod = 1
	case admin = 2
	```
*/
enum UserType: Int {
	/// Refers to normal users with no special permissions.
	case normal = 0

	/// Refers to mods with mod permissions enabled.
	case mod

	/// Refers to admins with all permissions enabled.
	case admin
}
