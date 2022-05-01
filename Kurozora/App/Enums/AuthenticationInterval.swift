//
//  AuthenticationInterval.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/// The set of available authentication interval types.
///
/// ```
/// case immediately = 0
/// case thirtySeconds
/// case oneMinute
/// case twoMinutes
/// case threeMinutes
/// case fourMinutes
/// case fiveMinutes
/// ```
enum AuthenticationInterval: Int {
	// MARK: - Cases
	/// The app asks for authentication immediately.
	case immediately = 0

	/// The app asks for authentication after thirty seconds of it being in the background.
	case thirtySeconds

	/// The app asks for authentication after one minute of it being in the background.
	case oneMinute

	/// The app asks for authentication after two minutes of it being in the background.
	case twoMinutes

	/// The app asks for authentication after three minutes of it being in the background.
	case threeMinutes

	/// The app asks for authentication after four minutes of it being in the background.
	case fourMinutes

	/// The app asks for authentication after five minute of it being in the background.
	case fiveMinutes

	// MARK: - Properties
	/// An array of all `AuthenticationInterval` types.
	static let all: [AuthenticationInterval] = [.immediately, .thirtySeconds, .oneMinute, .twoMinutes, .threeMinutes, .fourMinutes, .fiveMinutes]

	/// The string value of an authentication interval type.
	var stringValue: String {
		switch self {
		case .immediately:
			return Trans.immediately
		case .thirtySeconds:
			return Trans.thirtySeconds
		case .oneMinute:
			return Trans.oneMinute
		case .twoMinutes:
			return Trans.twoMinutes
		case .threeMinutes:
			return Trans.threeMinutes
		case .fourMinutes:
			return Trans.fourMinutes
		case .fiveMinutes:
			return Trans.fiveMinutes
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
