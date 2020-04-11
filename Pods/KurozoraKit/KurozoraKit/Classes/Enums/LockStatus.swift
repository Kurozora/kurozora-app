//
//  LockStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	The set of available lock status types.

	```
	case unlocked = 0
	case locked = 1
	```
*/
public enum LockStatus: Int {
	// MARK: - Cases
	/// The thread is unlocked.
	case unlocked = 0

	/// The thread is locked.
	case locked = 1

	// MARK: - Properties
	/// The boolean value of a lock status type.
	public var boolValue: Bool {
		switch self {
		case .unlocked:
			return false
		case .locked:
			return true
		}
	}
}
