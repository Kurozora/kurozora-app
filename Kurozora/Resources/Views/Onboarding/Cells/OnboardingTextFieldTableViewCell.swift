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
				self.textField.placeholder = "Username: pick a cool one 🙈"
			case .emailAddress:
				self.textField.placeholder = "Email: we all forget our passwords 🙉"
			case .password:
				self.textField.placeholder = "Password: make it super secret 🙊"
			default: break
			}
		case .siwa:
			switch self.textField.textType {
			case .username:
				self.textField.placeholder = "Username: pick a cool one 🙈"
			default: break
			}
		case .signIn:
			switch self.textField.textType {
			case .emailAddress:
				self.textField.placeholder = "Your cool email address 🙌"
			case .password:
				self.textField.placeholder = "Your super secret password 👀"
			default: break
			}
		case .reset:
			switch self.textField.textType {
			case .emailAddress:
				self.textField.placeholder = "Your email address to the rescue 💌"
			default: break
			}
		case .twoFactor:
			self.textField.textAlignment = .center
			self.textField.font = .monospacedSystemFont(ofSize: 24, weight: .semibold)
		}
	}
}
