//
//  UserRole.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/03/2024.
//

import Foundation

/// The set of available user role types.
///
/// ```
/// case superAdmin = 1
/// case admin = 2
/// case editor = 3
/// ```
public enum UserRole: Int, Codable, Sendable {
	// MARK: - Cases
	/// Indicates the user has the super admin role.
	case superAdmin = 1
	/// Indicates the user has the admin role.
	case admin = 2
	/// Indicates the user has the editor role.
	case editor = 3
}
