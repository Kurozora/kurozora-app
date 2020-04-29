//
//  AuthenticationInterval.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	The set of available authentication interval types.

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
enum AuthenticationInterval: Int {
	// MARK: - Cases
	/// The app asks for authentication immediately.
	case immediately = 0

	/// The app asks for authentication after thirty seconds of it being in the background.
	case thirtySeconds = 1

	/// The app asks for authentication after one minute of it being in the background.
	case oneMinute = 2

	/// The app asks for authentication after two minutes of it being in the background.
	case twoMinutes = 3

	/// The app asks for authentication after three minutes of it being in the background.
	case threeMinutes = 4

	/// The app asks for authentication after four minutes of it being in the background.
	case fourMinutes = 5

	/// The app asks for authentication after five minute of it being in the background.
	case fiveMinutes = 6

	// MARK: - Properties
	/// An array of all `AuthenticationInterval` types.
	static let all: [AuthenticationInterval] = [.immediately, .thirtySeconds, .oneMinute, .twoMinutes, .threeMinutes, .fourMinutes, .fiveMinutes]

	/// The string value of an authentication interval type.
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

	/// The interval value of an authentication interval type.
	var intervalValue: Int {
		switch self {
		case .immediately:
			return 0
		case .thirtySeconds:
			return 30
		case .oneMinute:
			return 60
		case .twoMinutes:
			return 120
		case .threeMinutes:
			return 180
		case .fourMinutes:
			return 240
		case .fiveMinutes:
			return 300
		}
	}
}
