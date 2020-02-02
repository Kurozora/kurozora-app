//
//  OnboardingType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of onboarding types used to determin the onboarding view.

	```
	case register = 0
	case siwa = 1
	case signIn = 2
	case reset = 3
	```
*/
enum OnboardingType: Int {
	/// Register onboarding.
	case register = 0

	/// Sign In With Apple onboarding.
	case siwa = 1

	/// Sign in onboarding.
	case signIn = 2

	/// Reset password onboarding.
	case reset = 3

	/// An array containing all onboarding types.
	static let all: [OnboardingType] = [.register, .siwa, .signIn, .reset]

	/// The onboarding cell type array of an onboarding type.
	var cellType: [OnboardingCellType] {
		switch self {
		case .register:
			return OnboardingCellType.all
		case .siwa:
			return OnboardingCellType.allSIWA
		case .signIn:
			return OnboardingCellType.allSignIn
		case .reset:
			return OnboardingCellType.allReset
		}
	}
}
