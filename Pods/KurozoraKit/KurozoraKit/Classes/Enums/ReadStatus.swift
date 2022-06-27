//
//  ReadStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/04/2020.
//

import Foundation

/// The set of available read status types.
///
/// ```
/// case unread = 0
/// case read = 1
/// ```
public enum ReadStatus: Int, Codable {
	// MARK: - Cases
	/// The notification is unread.
	case unread = 0

	/// The notification is read.
	case read = 1

	// MARK: - Initializers
	/// Initializes an instance of `ReadStatus` with the given bool value.
	///
	/// - Parameter bool: The boolean value used to initialize an instance of `ReadStatus`.
	public init(from bool: Bool) {
		self = bool ? .read : .unread
	}

//	// MARK: - Properties
//	/// The boolean value of a read status tpye.
//	public var boolValue: Bool {
//		switch self {
//		case .read:
//			return true
//		case .unread:
//			return false
//		}
//	}
}
