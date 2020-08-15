//
//  ActivityStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 20/04/2020.
//

import Foundation

/**
	The set of available activity status types.

	```
	case online
	case seenRecently
	case offline
	```
*/
public enum ActivityStatus: String, Codable {
	// MARK: - Cases
	/// The user is currently online.
	case online = "Online"

	/// The user was recently online.
	case seenRecently = "Seen Recently"

	/// The user is offline.
	case offline = "Offline"

	// MARK: - Properties
	/// The string value of an activity status type.
	public var stringValue: String {
		switch self {
		case .online:
			return "Online"
		case .seenRecently:
			return "Seen Recently"
		case .offline:
			return "Offline"
		}
	}

	/// The symbol value of an activity status type.
	public var symbolValue: String {
		switch self {
		case .online:
			return "✓"
		case .seenRecently:
			return "–"
		case .offline:
			return "x"
		}
	}

	/// The color value of an activity status type.
	public var colorValue: UIColor {
		switch self {
		case .online:
			return .green
		case .seenRecently:
			return .yellow
		case .offline:
			return .red
		}
	}
}
