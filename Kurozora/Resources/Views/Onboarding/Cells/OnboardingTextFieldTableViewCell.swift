//
//  OnboardingTextFieldTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class OnboardingTextFieldTableViewCell: OnboardingBaseTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var textField: KTextField!

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		self.textField.textAlignment = .natural
		self.textField.font = .preferredFont(forTextStyle: .body)

		switch self.accountOnboardingType {
		case .signUp:
			switch self.textField.textType {
			case .username:
				self.textField.placeholder = L10n.onboardingUsernamePlaceholder
			case .emailAddress:
				self.textField.placeholder = L10n.onboardingSignUpEmailPlaceholder
			case .password:
				self.textField.placeholder = L10n.onboardingSignUpPasswordPlaceholder
			default: break
			}
		case .siwa:
			switch self.textField.textType {
			case .username:
				self.textField.placeholder = L10n.onboardingUsernamePlaceholder
			default: break
			}
		case .signIn:
			switch self.textField.textType {
			case .emailAddress:
				self.textField.placeholder = L10n.onboardingSignInEmailPlaceholder
			case .password:
				self.textField.placeholder = L10n.onboardingSignInPasswordPlaceholder
			default: break
			}
		case .reset:
			switch self.textField.textType {
			case .emailAddress:
				self.textField.placeholder = L10n.onboardingResetEmailPlaceholder
			default: break
			}
		case .twoFactor:
			self.textField.textAlignment = .center
			self.textField.font = .monospacedSystemFont(ofSize: 24, weight: .semibold)
		}
	}
}
