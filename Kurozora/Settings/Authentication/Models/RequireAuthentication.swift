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

	- case immediately = 0
	- case thirtySeconds = 1
	- case oneMinute = 2
	- case twoMinutes = 3
	- case threeMinutes = 4
	- case fourMinutes = 5
	- case fiveMinutes = 6
*/
enum RequireAuthentication: Int {
	case immediately
	case thirtySeconds
	case oneMinute
	case twoMinutes
	case threeMinutes
	case fourMinutes
	case fiveMinutes

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

	func equals(_ string: String) -> Bool {
		switch self.stringValue {
		case string:
			return true
		default:
			return false
		}
	}
	static var all: [RequireAuthentication] = [.immediately, .thirtySeconds, .oneMinute, .twoMinutes, .threeMinutes, .fourMinutes, .fiveMinutes]
}
