//
//  UserType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

enum UserType: Int {
	/// Refers to normal users with no special permissions.
	case normal = 0

	/// Refers to mods with mod permissions enabled.
	case mod

	/// Refers to admins with all permissions enabled.
	case admin
}
