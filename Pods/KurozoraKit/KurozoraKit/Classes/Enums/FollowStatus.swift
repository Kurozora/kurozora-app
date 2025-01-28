//
//  FollowStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//

import Foundation

/// The set of available follow status types.
///
/// ```
/// case unfollow = -1
/// case disabled = 0
/// case follow = 1
/// ```
public enum FollowStatus: Int, Codable, Sendable {
	// MARK: - Cases
	/// Unfollow another user.
	case notFollowed = -1

	/// The user can't be followed or unfollowed
	case disabled = 0

	/// Follow another user.
	case followed = 1

	// MARK: - Initializers
	/// Initializes an instance of `FollowStatus` with the given bool value.
	///
	/// If `nil` is given, then an instance of `.disabled` is initialized.
	///
	/// - Parameter bool: The boolean value used to initialize an instance of `FollowStatus`.
	public init(_ bool: Bool?) {
		if let bool = bool {
			self = bool ? .followed : .notFollowed
		} else {
			self = .disabled
		}
	}
}
