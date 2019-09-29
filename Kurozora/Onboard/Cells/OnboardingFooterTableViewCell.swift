//
//  OnboardingFooterTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import AuthenticationServices
import SCLAlertView

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

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		super.configureCell()

		if #available(iOS 13.0, *) {
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
			authorizationButton.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)

			// Add to stack view
			optionsStackView?.addArrangedSubviews([orLabel, authorizationButton])
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

	@available(iOS 13.0, *)
	@objc private func handleLogInWithAppleIDButtonPress() {
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.init("username"), .init("email")]

		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
	}

	/**
		Modally presents the legal view controller.

		- Parameter sender: The object containing a reference to the button that initiated this action.
	*/
	@objc fileprivate func legalButtonPressed(_ sender: UIButton) {
		sender.alpha = 1.0

		if let legalViewController = LegalViewController.instantiateFromStoryboard() as? LegalViewController {
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

// MARK: - ASAuthorizationControllerDelegate
@available(iOS 13.0, *)
extension OnboardingFooterTableViewCell: ASAuthorizationControllerDelegate {
	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//		SCLAlertView().showError("Error", subTitle: error.localizedDescription)
	}

	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
			// Create an account in your system.
			// For the purpose of this demo app, store the these details in the keychain.
			try? Kurozora.shared.KDefaults.set("\(appleIDCredential.user)", key: "SIWA_user")
			try? Kurozora.shared.KDefaults.set("Kirito", key: "username")
			try? Kurozora.shared.KDefaults.set("\(2)", key: "user_role")
			try? Kurozora.shared.KDefaults.set(appleIDCredential.email ?? "sabonmail", key: "email")

			print("User ID - \(appleIDCredential.user)")
			print("User Name - \(appleIDCredential.fullName?.description ?? "N/A")")
			print("User Email - \(appleIDCredential.email ?? "N/A")")
			print("Real User Status - \(appleIDCredential.realUserStatus.rawValue)")

			if let authorizationCode = appleIDCredential.authorizationCode,
				let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) {
				try? Kurozora.shared.KDefaults.set(authorizationCodeString, key: "auth_token")
				print("Refresh Token \(authorizationCodeString)")
			}

			if let identityTokenData = appleIDCredential.identityToken,
				let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
				try? Kurozora.shared.KDefaults.set(identityTokenString, key: "id_token")
				print("Identity Token \(identityTokenString)")
			}

			//Show Home View Controller
			self.parentViewController?.dismiss(animated: true, completion: nil)
		} else if let passwordCredential = authorization.credential as? ASPasswordCredential {
			// Sign in using an existing iCloud Keychain credential.
			let username = passwordCredential.user
			let password = passwordCredential.password

			// For the purpose of this demo app, show the password credential as an alert.
			DispatchQueue.main.async {
				let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
				SCLAlertView().showInfo("Keychain Credential Received", subTitle: message)
			}
		}
	}
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
@available(iOS 13.0, *)
extension OnboardingFooterTableViewCell: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return self.contentView.window!
	}
}
