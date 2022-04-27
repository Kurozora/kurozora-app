//
//  OnboardingType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension AccountOnboarding {
	/// Set of available onboarding text field types.
	enum TextField: Int, CaseIterable {
		// MARK: - Cases
		/// Username cell type.
		case username = 0

		/// Email cell type.
		case email = 1

		/// Password cell type.
		case password = 2

		// MARK: - Properties
		/// An array containing all Sign in with Apple cell types.
		static let siwaCases: [TextField] = [.username]

		/// An array containing only sign in cell types.
		static let signInCases: [TextField] = [.email, .password]

		/// An array containing only reset password cell types.
		static let resetCases: [TextField] = [.email]
	}
}
