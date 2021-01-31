//
//  OnboardingOptionsTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import AuthenticationServices

@objc protocol OnboardingOptionsTableViewCellDelegate: class {
	func handleAuthorizationAppleIDButtonPress()
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

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		setupProviderSignInView()
	}

	/// Sets up the sign in view by adding an "or" label and the Sign in with Apple ID button.
	func setupProviderSignInView() {
		// Create a new 'or label' separator.
		let orLabel: KSecondaryLabel = KSecondaryLabel(text: "━━━━━━ or ━━━━━━")
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
		authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)

		// Add to stack view
		optionsStackView?.addArrangedSubviews([orLabel, authorizationButton])
	}

	/// Handles the Apple ID button press.
	@objc func handleAuthorizationAppleIDButtonPress() {
		self.delegate?.handleAuthorizationAppleIDButtonPress()
	}
}
