//
//  UsersListType.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//

import Foundation

/// The set of available users list types.
///
/// - `followers`: the list is of the `followers` type.
/// - `following`: the list is of the `following` type.
///
/// - Tag: UsersListType
public enum UsersListType: String {
	// MARK: - Cases
	/// Indicates the list is of the `followers` type.
	///
	/// - Tag: UsersListType-followers
	case followers

	/// Indicates the list is of the `following` type.
	///
	/// - Tag: UsersListType-following
	case following

	// MARK: - Properties
	/// The string value of a users list.
	///
	/// - Tag: UsersListType-stringValue
	public var stringValue: String {
		switch self {
		case .followers:
			return "Followers"
		case .following:
			return "Following"
		}
	}
}
