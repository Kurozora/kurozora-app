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
	case signIn = 1
	case reset = 2
	```
*/
enum OnboardingType: Int {
	/// Register onboarding.
	case register = 0

	/// Sign in onboarding.
	case signIn = 1

	/// Reset password onboarding.
	case reset = 2

	/// An array containing all onboarding types.
	static let all: [OnboardingType] = [.register, .signIn, .reset]

	/// The onboarding cell type array of an onboarding type.
	var cellType: [OnboardingCellType] {
		switch self {
		case .register:
			return OnboardingCellType.all
		case .signIn:
			return OnboardingCellType.allSignIn
		case .reset:
			return OnboardingCellType.allReset
		}
	}
}
