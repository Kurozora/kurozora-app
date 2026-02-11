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
/// - `immediately`:  authenticate immediately.
/// - `thirtySeconds`: authenticate after thirty seconds of it being in the background.
/// - `oneMinute`: authenticate after one minute of it being in the background.
/// - `twoMinutes`: authenticate after two minutes of it being in the background.
/// - `threeMinutes`: authenticate after three minutes of it being in the background.
/// - `fourMinutes`: authenticate after four minutes of it being in the background.
/// - `fiveMinutes`: authenticate after five minute of it being in the background.
///
/// - Tag: AuthenticationInterval
enum AuthenticationInterval: Int, CaseIterable {
	// MARK: - Cases
	/// The app asks for authentication immediately.
	///
	/// - Tag: AuthenticationInterval-immediately
	case immediately = 0

	/// The app asks for authentication after thirty seconds of it being in the background.
	///
	/// - Tag: AuthenticationInterval-thirtySeconds
	case thirtySeconds = 30

	/// The app asks for authentication after one minute of it being in the background.
	///
	/// - Tag: AuthenticationInterval-oneMinute
	case oneMinute = 60

	/// The app asks for authentication after two minutes of it being in the background.
	///
	/// - Tag: AuthenticationInterval-twoMinutes
	case twoMinutes = 120

	/// The app asks for authentication after three minutes of it being in the background.
	///
	/// - Tag: AuthenticationInterval-threeMinutes
	case threeMinutes = 180

	/// The app asks for authentication after four minutes of it being in the background.
	///
	/// - Tag: AuthenticationInterval-fourMinutes
	case fourMinutes = 240

	/// The app asks for authentication after five minute of it being in the background.
	///
	/// - Tag: AuthenticationInterval-fiveMinutes
	case fiveMinutes = 300

	// MARK: - Properties
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

	/// The footer string value of an authentication interval type.
	var footerStringValue: String {
		switch self {
		case .immediately:
			return Trans.immediateAuthenticationRequired
		case .thirtySeconds:
			return Trans.authenticationInterval("30 seconds.")
		case .oneMinute:
			return Trans.authenticationInterval("1 minute.")
		case .twoMinutes:
			return Trans.authenticationInterval("2 minutes.")
		case .threeMinutes:
			return Trans.authenticationInterval("3 minutes.")
		case .fourMinutes:
			return Trans.authenticationInterval("4 minutes.")
		case .fiveMinutes:
			return Trans.authenticationInterval("5 minutes")
		}
	}
}
