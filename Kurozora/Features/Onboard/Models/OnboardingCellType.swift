//
//  OnboardingCellType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of onboarding cell types used on the onboarding table views.

	```
	case username = 0
	case email = 1
	case password = 2
	case footer = 3
	```
*/
enum OnboardingCellType: Int {
	/// Username cell type.
	case username = 0

	/// Email cell type.
	case email = 1

	/// Password cell type.
	case password = 2

	/// Footer cell type.
	case footer = 3

	// MARK: - Properties
	/// An array containing all onboarding cell types.
	static let all: [OnboardingCellType] = [.username, .email, .password, .footer]

	/// An array containing all Sign In With Apple onboarding cell types.
	static let allSIWA: [OnboardingCellType] = [.username, .footer]

	/// An array containing only sign in onboarding cell types.
	static let allSignIn: [OnboardingCellType] = [.email, .password, .footer]

	/// An array containing only reset password onboarding cell types.
	static let allReset: [OnboardingCellType] = [.email, .footer]
}
