//
//  SIWAButtonTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import AuthenticationServices

class SIWAButtonTableViewCell: UITableViewCell {
	// MARK: - Properties
	weak var onboardingFooterTableViewCellDelegate: OnboardingOptionsTableViewCellDelegate?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		setupProviderSignInView()
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		setupProviderSignInView()
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
		authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)

		// Add to stack view
		self.contentView.addSubview(authorizationButton)
		authorizationButton.anchorCenterSuperview()
	}

	/// Handles the Apple ID button press.
	@objc func handleAuthorizationAppleIDButtonPress() {
		onboardingFooterTableViewCellDelegate?.handleAuthorizationAppleIDButtonPress()
	}
}
