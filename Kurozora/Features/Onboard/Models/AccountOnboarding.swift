//
//  AccountOnboarding.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	Set of available account onboarding types.

	```
	case username = 0
	case email = 1
	case password = 2
	case footer = 3
	```
*/
enum AccountOnboarding: Int, CaseIterable {
	// MARK: - Cases
	/// Register onboarding.
	case register = 0

	/// Sign in with Apple onboarding.
	case siwa = 1

	/// Sign in onboarding.
	case signIn = 2

	/// Reset password onboarding.
	case reset = 3

	// MARK: - Properties
	/// The array of account onboarding cell types.
	var cellTypes: [AccountOnboarding.Cell] {
		switch self {
		case .register:
			return AccountOnboarding.Cell.allCases
		case .siwa:
			return AccountOnboarding.Cell.siwaCases
		case .signIn:
			return AccountOnboarding.Cell.signInCases
		case .reset:
			return AccountOnboarding.Cell.resetCases
		}
	}
}
