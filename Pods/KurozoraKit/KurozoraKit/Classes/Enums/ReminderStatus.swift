//
//  ReminderStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

import Foundation

/**
	The set of available reminder status types.

	```
	case notReminded = -1
	case disabled = 0
	case reminded = 1
	```
*/
public enum ReminderStatus: Int, Codable {
	// MARK: - Cases
	/// The user is not reminded.
	case notReminded = -1

	/// The show can't be reminded or unreminded
	case disabled = 0

	/// The user is reminded.
	case reminded = 1

	// MARK: - Initializers
	/**
		Initializes an instance of `ReminderStatus` with the given bool value.

		If `nil` is given, then an instance of `.disabled` is initialized.

		- Parameter bool: The boolean value used to initialize an instance of `ReminderStatus`.
	*/
	public init(_ bool: Bool?) {
		if let bool = bool {
			self = bool ? .reminded : .notReminded
		} else {
			self = .disabled
		}
	}
}
