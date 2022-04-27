//
//  SignInTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import AuthenticationServices

class SignInTableViewController: AccountOnboardingTableViewController {
	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Configure properties
		self.accountOnboardingType = .signIn
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		performExistingAccountSetupFlows()
	}

	// MARK: - Functions
	/// Prompts the user if an existing Keychain credential or Apple ID credential is found.
	func performExistingAccountSetupFlows() {
		// Prepare requests for both Apple ID and password providers.
		let requests = [ASAuthorizationAppleIDProvider().createRequest(),
						ASAuthorizationPasswordProvider().createRequest()]

		// Create an authorization controller with the given requests.
		let authorizationController = ASAuthorizationController(authorizationRequests: requests)
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
	}

	/// Signs in a user using their email address and password.
	///
	/// - Parameters:
	///    - email: The email address of the user.
	///    - password: The password of the user.
	func signInWithKurozora(email: String? = nil, password: String? = nil) {
		guard let kurozoraID = email ?? textFieldArray.first??.trimmedText else { return }
		guard let password = password ?? textFieldArray.last??.text else { return }

		KService.signIn(kurozoraID, password) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let authenticationToken):
				// Save user in keychain.
				if let username = User.current?.attributes.username {
					try? KurozoraDelegate.shared.keychain.set(authenticationToken, key: username)
					UserSettings.set(username, forKey: .selectedAccount)
				}

				// Dismiss the view and register user for push notifications.
				self.dismiss(animated: true) {
					UserSettings.shared.removeObject(forKey: UserSettingsKey.lastNotificationRegistrationRequest.rawValue)
					WorkflowController.shared.registerForPushNotifications()
				}
			case .failure: break
			}
		}
	}

	// MARK: - IBActions
	override func rightNavigationBarButtonPressed(sender: AnyObject) {
		super.rightNavigationBarButtonPressed(sender: sender)

		self.signInWithKurozora()
	}
}

// MARK: - KTableViewControllerDataSource
extension SignInTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			OnboardingHeaderTableViewCell.self,
			OnboardingTextFieldTableViewCell.self,
			OnboardingFooterTableViewCell.self
		]
	}
}

// MARK: - OnboardingOptionsTableViewCellDelegate
extension SignInTableViewController: OnboardingOptionsTableViewCellDelegate {
	func handleAuthorizationAppleIDButtonPress() {
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.email]

		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
	}
}

// MARK: - ASAuthorizationControllerDelegate
extension SignInTableViewController: ASAuthorizationControllerDelegate {
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		switch authorization.credential {
		case let appleIDCredential as ASAuthorizationAppleIDCredential:
			print("----------- Statrted authorizationController() -----------")
			print("User ID - \(appleIDCredential.user)")
			print("User Name - \(appleIDCredential.fullName?.description ?? "N/A")")
			print("User Email - \(appleIDCredential.email ?? "N/A")")
			print("Real User Status - \(appleIDCredential.realUserStatus.rawValue)")

			let authorizationCode = appleIDCredential.authorizationCode ?? Data()
			if let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) {
				print("Refresh Token \(authorizationCodeString)")
			}

			let identityTokenData = appleIDCredential.identityToken ?? Data()
			guard let identityTokenString = String(data: identityTokenData, encoding: .utf8) else { return }
			print("Identity Token \(identityTokenString)")

			KService.signIn(withAppleID: identityTokenString) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let oAuthResponse):
					switch oAuthResponse.action {
					case .signIn:
						// Save user in keychain.
						if let username = User.current?.attributes.username {
							try? KurozoraDelegate.shared.keychain.set(oAuthResponse.authenticationToken, key: username)
							UserSettings.set(username, forKey: .selectedAccount)
						}

						// Dismiss the view and register user for push notifications.
						self.dismiss(animated: true) {
							UserSettings.shared.removeObject(forKey: UserSettingsKey.lastNotificationRegistrationRequest.rawValue)
							WorkflowController.shared.registerForPushNotifications()
						}
					case .setupAccount:
						if let signUpTableViewController = R.storyboard.onboarding.signUpTableViewController() {
							signUpTableViewController.isSIWA = true
							self.show(signUpTableViewController, sender: nil)
						}
					default: break
					}
				case .failure: break
				}
			}
		case let passwordCredential as ASPasswordCredential:
			// Sign in using an existing iCloud Keychain credential.
			let email = passwordCredential.user
			let password = passwordCredential.password

			self.signInWithKurozora(email: email, password: password)
		default: break
		}
	}

	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		var message = ""
		if let error = error as? ASAuthorizationError {
			switch error.code {
			case .canceled: break
			case .failed:
				message = "Authentication failed by Apple. Please try again."
			case .invalidResponse:
				message = "The app received an invalid response from Apple. Please try again."
			case .notHandled:
				message = "An error occured and the authentication was not handled by Apple. Please try again."
			default: break
			}
		}

		if !message.isEmpty {
			self.presentAlertController(title: "Error", message: message)
		}
	}
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension SignInTableViewController: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return view.window ?? UIWindow()
	}
}
