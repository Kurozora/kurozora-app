//
//  OnboardingFooterTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import AuthenticationServices

@objc protocol OnboardingFooterTableViewCellDelegate: class {
	@available(iOS 13.0, macCatalyst 13.0, *)
	func handleAuthorizationAppleIDButtonPress()
}

class OnboardingFooterTableViewCell: OnboardingBaseTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var forgotPasswordButton: UIButton! {
		didSet {
			forgotPasswordButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var orLabel: UILabel! {
		didSet {
			orLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var registerPasswordButton: UIButton! {
		didSet {
			registerPasswordButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var optionsStackView: UIStackView?
	@IBOutlet weak var promotionalImageView: UIImageView?
	@IBOutlet weak var descriptionLabel: UILabel? {
		didSet {
			descriptionLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var legalButton: UIButton? {
		didSet {
			legalButton?.addTarget(self, action: #selector(legalButtonPressed), for: .touchUpInside)
			legalButton?.addTarget(self, action: #selector(legalButtonTouched), for: [.touchDown, .touchDragExit, .touchDragInside, .touchCancel])
		}
	}

	// MARK: - Properties
	weak var onboardingFooterTableViewCellDelegate: OnboardingFooterTableViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		super.configureCell()

		if #available(iOS 13.0, macCatalyst 13.0, *) {
			setupProviderSignInView()
		}

		if legalButton != nil {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = .center

			// Normal state
			let attributedString = NSMutableAttributedString(string: "Your Kurozra ID information is used to enable Kurozora services when you sign in. Kurozora services includes the library where you can keep track of the shows you are interested in. \n", attributes: [.foregroundColor: KThemePicker.subTextColor.colorValue, .paragraphStyle: paragraphStyle])
			attributedString.append(NSAttributedString(string: "See how your data is managed...", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue, .paragraphStyle: paragraphStyle]))
			legalButton?.setAttributedTitle(attributedString, for: .normal)
		}
	}

	/// Sets up the sign in view by adding an "or" label and the Sign in with Apple ID button.
	@available(iOS 13.0, macCatalyst 13.0, *)
	func setupProviderSignInView() {
		// Create a new 'or label' separator.
		let orLabel: UILabel = UILabel(text: "—————— or ——————")
		orLabel.font = .systemFont(ofSize: 15)
		orLabel.theme_textColor = KThemePicker.subTextColor.rawValue

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
	@available(iOS 13.0, macCatalyst 13.0, *)
	@objc func handleAuthorizationAppleIDButtonPress() {
		onboardingFooterTableViewCellDelegate?.handleAuthorizationAppleIDButtonPress()
	}

	/**
		Modally presents the legal view controller.

		- Parameter sender: The object containing a reference to the button that initiated this action.
	*/
	@objc fileprivate func legalButtonPressed(_ sender: UIButton) {
		sender.alpha = 1.0

		if let legalViewController = R.storyboard.legal.legalViewController() {
			let kNavigationController = KNavigationController(rootViewController: legalViewController)
			self.parentViewController?.present(kNavigationController)
		}
	}

	/**
		Changes the opacity of the button to match the default UIButton mechanic.

		- Parameter sender: The object containing a reference to the button that initiated this action.
	*/
	@objc fileprivate func legalButtonTouched(_ sender: UIButton) {
		if sender.state == .highlighted {
			sender.alpha = 0.5
		} else {
			sender.alpha = 1.0
		}
	}
}
