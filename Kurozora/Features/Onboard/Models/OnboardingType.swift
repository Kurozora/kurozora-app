//
//  OnboardingType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension AccountOnboarding {
	/**
		Set of available onboarding cell types.

		```
		case register = 0
		case siwa = 1
		case signIn = 2
		case reset = 3
		```
	*/
	enum Cell: Int, CaseIterable {
		// MARK: - Cases
		/// Username cell type.
		case username = 0

		/// Email cell type.
		case email = 1

		/// Password cell type.
		case password = 2

		/// Footer cell type.
		case footer = 3

		// MARK: - Properties
		/// An array containing all Sign in with Apple cell types.
		static let siwaCases: [Cell] = [.username, .footer]

		/// An array containing only sign in cell types.
		static let signInCases: [Cell] = [.email, .password, .footer]

		/// An array containing only reset password cell types.
		static let resetCases: [Cell] = [.email]
	}
}
