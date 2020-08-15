//
//  ForumsLock.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 08/08/2020.
//

/**
	A root object that stores information about a single forums lock, such as the lock status.
*/
public struct ForumsLock: Codable {
	// MARK: - Properties
	/// Whether the forums is locked.
	fileprivate let isLocked: Bool

	/// The lock status of the forums.
	fileprivate var _lockStatus: LockStatus?
}

// MARK: - Helpers
extension ForumsLock {
	// MARK: - Properties
	/// The lock status of the forums section.
	public var lockStatus: LockStatus {
		get {
			return _lockStatus ?? LockStatus(from: isLocked)
		}
		set {
			_lockStatus = newValue
		}
	}
}
