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
	case siwa

	/// Sign in onboarding.
	case signIn

	/// Reset password onboarding.
	case reset

	// MARK: - Properties
	/// The title value of an account onboarding type.
	var titleValue: String {
		switch self {
		case .signUp:
			return Trans.Onboarding.signInHeadline
		case .siwa:
			return Trans.Onboarding.siwaHeadline
		case .signIn:
			return Trans.Onboarding.signInHeadline
		case .reset:
			return Trans.Onboarding.forgotPasswordHeadline
		}
	}

	/// The sub text value of an account onboarding type.
	var subTextValue: String {
		switch self {
		case .signUp:
			return Trans.Onboarding.signUpSubheadline
		case .siwa:
			return Trans.Onboarding.siwaSubheadline
		case .signIn:
			return Trans.Onboarding.signInSubheadline
		case .reset:
			return Trans.Onboarding.forgotPasswordSubheadline
		}
	}

	/// The navigation bar button title value of an account onboarding type.
	var navigationBarButtonTitleValue: String {
		switch self {
		case .signUp:
			return Trans.Onboarding.signUpButton
		case .siwa:
			return Trans.Onboarding.siwaButton
		case .signIn:
			return Trans.Onboarding.signInButton
		case .reset:
			return Trans.Onboarding.forgotPasswordButton
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
			return AccountOnboarding.TextField.signUpCases
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
