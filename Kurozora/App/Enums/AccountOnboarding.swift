//
//  AccountOnboarding.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/// Set of available account onboarding types.
enum AccountOnboarding: Int, CaseIterable {
	// MARK: - Cases
	/// Sign up onboarding.
	case signUp = 0

	/// Sign in with Apple onboarding.
	case siwa = 1

	/// Sign in onboarding.
	case signIn = 2

	/// Reset password onboarding.
	case reset = 3

	// MARK: - Properties
	/// The title value of an account onboarding type.
	var titleValue: String {
		switch self {
		case .signUp:
			return "New to Kurozora?"
		case .siwa:
			return "Setup Account"
		case .signIn:
			return "Kurozora ID"
		case .reset:
			return "Forgot Password?"
		}
	}

	/// The sub text value of an account onboarding type.
	var subTextValue: String {
		switch self {
		case .signUp:
			return "Create an account and join the community."
		case .siwa:
			return "Finish setting up your account and join the comminty."
		case .signIn:
			return "Sign in with your Kurozora ID to use the library and other Kurozora services."
		case .reset:
			return "Enter your Kurozora ID to continue."
		}
	}

	/// The navigation bar button title value of an account onboarding type.
	var navigationBarButtonTitleValue: String {
		switch self {
		case .signUp:
			return "Join 🤗"
		case .siwa:
			return "Join 🤗"
		case .signIn:
			return "Open sesame 👐"
		case .reset:
			return "Send ✨"
		}
	}

	/// The sections of an account onboarding type.
	var sections: [AccountOnboarding.Sections] {
		switch self {
		case .signUp:
			return AccountOnboarding.Sections.signUpCases
		case .siwa:
			return AccountOnboarding.Sections.siwaCases
		case .signIn:
			return AccountOnboarding.Sections.signInCases
		case .reset:
			return AccountOnboarding.Sections.resetCases
		}
	}

	/// The array of account onboarding cell types.
	var textFieldTypes: [AccountOnboarding.TextField] {
		switch self {
		case .signUp:
			return AccountOnboarding.TextField.allCases
		case .siwa:
			return AccountOnboarding.TextField.siwaCases
		case .signIn:
			return AccountOnboarding.TextField.signInCases
		case .reset:
			return AccountOnboarding.TextField.resetCases
		}
	}

	/// Set of available onboarding section types.
	enum Sections: Int, CaseIterable {
		// MARK: - Cases
		/// Header section.
		case header = 0

		/// Text fields section.
		case textFields = 1

		/// Options section.
		case options = 2

		/// Footer section.
		case footer = 3

		// MARK: - Properties
		/// An array containing all sign up section types.
		static let signUpCases: [Sections] = [.textFields, .footer]

		/// An array containing all Sign in with Apple section types.
		static let siwaCases: [Sections] = [.textFields, .footer]

		/// An array containing only sign in section types.
		static let signInCases: [Sections] = [.header, .textFields, .options, .footer]

		/// An array containing only reset password section types.
		static let resetCases: [Sections] = [.header, .textFields]
	}
}
