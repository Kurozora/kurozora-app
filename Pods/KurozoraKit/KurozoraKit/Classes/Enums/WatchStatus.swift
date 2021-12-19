//
//  WatchStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/03/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

/**
	The set of available watch status types.

	```
	case notWatched = -1
	case disabled = 0
	case watched = 1
	```
*/
public enum WatchStatus: Int, Codable {
	// MARK: - Cases
	/// The episode is not watched.
	case notWatched = -1

	/// The episode can't be watched or unwatched.
	case disabled = 0

	/// The episode is watched.
	case watched = 1

	// MARK: - Properties
	/// The string value of a watch status type.
	public var stringValue: String {
		switch self {
		case .notWatched:
			return "Not Watched"
		case .disabled:
			return "Disabled"
		case .watched:
			return "Watched"
		}
	}

	// MARK: - Functions
	/**
		Initializes an instance of `WatchStatus` with the given bool value.

		If `nil` is given, then an instance of `.disabled` is initialized.

		- Parameter bool: The boolean value used to initialize an instance of `WatchStatus`.
	*/
	public init(_ bool: Bool?) {
		if let bool = bool {
			self = bool ? .watched : .notWatched
		} else {
			self = .disabled
		}
	}
}
