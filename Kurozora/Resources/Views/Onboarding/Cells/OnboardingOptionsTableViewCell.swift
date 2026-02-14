//
//  OnboardingOptionsTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import AuthenticationServices
import UIKit

@objc protocol OnboardingOptionsTableViewCellDelegate: AnyObject {
	@MainActor
	func handleAuthorizationAppleIDButtonPress()
	@MainActor
	func handleForgotPasswordButtonPress()
	@MainActor
	func handleRegisterButtonPress()
}

class OnboardingOptionsTableViewCell: OnboardingBaseTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var forgotPasswordButton: KButton!
	@IBOutlet weak var orLabel: KSecondaryLabel!
	@IBOutlet weak var registerPasswordButton: KButton!
	@IBOutlet weak var optionsStackView: UIStackView?
	@IBOutlet weak var promotionalImageView: UIImageView?
	@IBOutlet weak var descriptionLabel: KLabel?

	// MARK: - Properties
	weak var delegate: OnboardingOptionsTableViewCellDelegate?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		self.forgotPasswordButton.addTarget(self, action: #selector(self.forgotPasswordButtonPressed), for: .touchUpInside)
		self.registerPasswordButton.addTarget(self, action: #selector(self.registerButtonPressed), for: .touchUpInside)
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		self.forgotPasswordButton.setTitle(Trans.Onboarding.forgotPasswordOptionsButton, for: .normal)
		self.orLabel.text = Trans.Onboarding.onboardingOrSeparator
		self.registerPasswordButton.setTitle(Trans.Onboarding.registerOptionsButton, for: .normal)
		self.descriptionLabel?.text = Trans.Onboarding.onboardingDescription
		self.setupProviderSignInView()
	}

	/// Sets up the sign in view by adding an "or" label and the Sign in with Apple ID button.
	func setupProviderSignInView() {
		// Create a new 'or label' separator.
		let orLabel = KSecondaryLabel()
		orLabel.text = Trans.Onboarding.onboardingOrSeparator
		orLabel.font = .preferredFont(forTextStyle: .subheadline)

		// Create and setup Apple ID authorization button
		let style: ASAuthorizationAppleIDButton.Style = KThemeStyle.isNightTheme() ? .white : .black
		let authorizationButton = ASAuthorizationAppleIDButton(type: .default, style: style)

		// Add height constraint
		let heightConstraint = authorizationButton.heightAnchor.constraint(equalToConstant: 40)
		authorizationButton.addConstraint(heightConstraint)

		// Add width constraint
		let widthConstraint = authorizationButton.widthAnchor.constraint(equalToConstant: 220)
		authorizationButton.addConstraint(widthConstraint)
		authorizationButton.addTarget(self, action: #selector(self.handleAuthorizationAppleIDButtonPress), for: .touchUpInside)

		// Add to stack view
		self.optionsStackView?.addArrangedSubview(orLabel)
		self.optionsStackView?.addArrangedSubview(authorizationButton)
	}

	/// Handles the Apple ID button press.
	@objc func handleAuthorizationAppleIDButtonPress() {
		self.delegate?.handleAuthorizationAppleIDButtonPress()
	}

	/// Handles the forgot password button press.
	@objc func forgotPasswordButtonPressed() {
		self.delegate?.handleForgotPasswordButtonPress()
	}

	/// Handles the register button press.
	@objc func registerButtonPressed() {
		self.delegate?.handleRegisterButtonPress()
	}
}
