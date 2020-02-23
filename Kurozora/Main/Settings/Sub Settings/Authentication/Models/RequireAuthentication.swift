//
//  RequireAuthentication.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of require authentication options

	```
	case immediately = 0
	case thirtySeconds = 1
	case oneMinute = 2
	case twoMinutes = 3
	case threeMinutes = 4
	case fourMinutes = 5
	case fiveMinutes = 6
	```
*/
enum RequireAuthentication: Int {
	/// The app asks for authentication immediately.
	case immediately

	/// The app asks for authentication after thirty seconds of the app being in the background.
	case thirtySeconds

	/// The app asks for authentication after one minute of the app being in the background.
	case oneMinute

	/// The app asks for authentication after two minutes of the app being in the background.
	case twoMinutes

	/// The app asks for authentication after three minutes of the app being in the background.
	case threeMinutes

	/// The app asks for authentication after four minutes of the app being in the background.
	case fourMinutes

	/// The app asks for authentication after six minute of the app being in the background.
	case fiveMinutes

	/// An array of all RequireAuthentication attributes.
	static let all: [RequireAuthentication] = [.immediately, .thirtySeconds, .oneMinute, .twoMinutes, .threeMinutes, .fourMinutes, .fiveMinutes]

	/// The string value of an authentication timeout.
	var stringValue: String {
		switch self {
		case .immediately:
			return "Immediately"
		case .thirtySeconds:
			return "30 Seconds"
		case .oneMinute:
			return "1 Minute"
		case .twoMinutes:
			return "2 Minutes"
		case .threeMinutes:
			return "3 Minutes"
		case .fourMinutes:
			return "4 Minutes"
		case .fiveMinutes:
			return "5 Minutes"
		}
	}

	/**
		Returns a RequireAuthentication object from the given string.

		- Parameter string: The string from which a RequireAuthentication object is returned.

		- Returns: a RequireAuthentication object from the given string.
	*/
	static func valueFrom(_ string: String?) -> RequireAuthentication {
		guard let string = string else { return .immediately }
		switch string {
		case "Immediately":
			return .immediately
		case "30 Seconds":
			return .thirtySeconds
		case "1 Minute":
			return .oneMinute
		case "2 Minutes":
			return .twoMinutes
		case "3 Minutes":
			return .threeMinutes
		case "4 Minutes":
			return .fourMinutes
		case "5 Minutes":
			return .fiveMinutes
		default:
			return .immediately
		}
	}

	/**
		Checks whether the given string is a match.

		- Parameter string: The string which should be matched with.

		- Returns: a boolean indicating whether the given string matches.
	*/
	func equals(_ string: String) -> Bool {
		switch self.stringValue {
		case string:
			return true
		default:
			return false
		}
	}
}
