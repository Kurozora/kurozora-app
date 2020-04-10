//
//  ReadStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	List of read status.

	```
	case unread = 0
	case read = 1
	```
*/
public enum ReadStatus: Int {
	// MARK: - Cases
	case unread = 0
	case read = 1

	// MARK: - Initializers
	/**
		Initializes an instance of `ReadStatus` with the given bool value.

		- Parameter bool: The boolean value used to initialize an instance of `ReadStatus`.
	*/
	public init(from bool: Bool) {
		self = bool ? .read : .unread
	}

	// MARK: - Properties
	/// The boolean value of a read status.
	var boolValue: Bool {
		switch self {
		case .read:
			return true
		case .unread:
			return false
		}
	}
}
