//
//  SIWAButtonTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import AuthenticationServices
import UIKit

class SIWAButtonTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var stackView: UIStackView!

	// MARK: - Properties
	weak var onboardingFooterTableViewCellDelegate: OnboardingOptionsTableViewCellDelegate?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		self.setupProviderSignInView()
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		self.setupProviderSignInView()
	}

	/// Sets up the sign in view by adding an "or" label and the Sign in with Apple ID button.
	func setupProviderSignInView() {
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
		self.stackView.addArrangedSubview(authorizationButton)
	}

	/// Handles the Apple ID button press.
	@objc func handleAuthorizationAppleIDButtonPress() {
		self.onboardingFooterTableViewCellDelegate?.handleAuthorizationAppleIDButtonPress()
	}
}
