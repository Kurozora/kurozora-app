//
//  SignInTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import AuthenticationServices
import KurozoraKit
import UIKit

class SignInTableViewController: AccountOnboardingTableViewController {
	// MARK: - Properties
	var onSignIn: (() -> Void)?
	var onDismiss: (() -> Void)?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Add cancel button
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(sender:)))

		// Configure properties
		self.accountOnboardingType = .signIn
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.performExistingAccountSetupFlows()
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
	func signInWithKurozora(email: String? = nil, password: String? = nil) async {
		guard let email = email ?? self.textFieldArray.first??.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
		guard let password = password ?? self.textFieldArray.last??.text else { return }

		do {
			let signInResponse = try await KService.signIn(email: email, password: password).response()
			let authenticationToken = signInResponse.authenticationToken

			// Save user in keychain.
			if let slug = User.current?.attributes.slug {
				let account = StoredAccount(
					slug: slug,
					username: User.current?.attributes.username,
					profileImageURL: User.current?.attributes.profile?.url,
					authenticationToken: authenticationToken
				)
				AccountManager.shared.save(account)
				UserSettings.set(slug, forKey: .selectedAccount)
				WatchSessionManager.shared.sendAuthState(slug: slug, token: authenticationToken)
			}

			// Dismiss the view and register user for push notifications.
			self.dismiss(animated: true) {
				UserSettings.shared.removeObject(forKey: UserSettingsKey.lastNotificationRegistrationRequest.rawValue)
				WorkflowController.shared.registerForPushNotifications()
				self.onSignIn?()
			}
		} catch let error as APIError {
			// Re-enable user interaction.
			self.disableUserInteraction(false)
			self.presentAlertController(title: L10n.Onboarding.signInErrorTitle, message: error.message)
		} catch {
			// Re-enable user interaction.
			self.disableUserInteraction(false)
			self.presentAlertController(title: L10n.Onboarding.signInErrorTitle, message: L10n.Onboarding.genericSignInErrorMessage)
		}
	}

	// MARK: - Actions
	override func cancelButtonPressed(sender: UIBarButtonItem) {
		self.dismiss(animated: true) {
			self.onDismiss?()
		}
	}

	override func rightNavigationBarButtonPressed(sender: AnyObject) {
		super.rightNavigationBarButtonPressed(sender: sender)

		Task {
			await self.signInWithKurozora()
		}
	}
}

// MARK: - KTableViewControllerDataSource
extension SignInTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			OnboardingHeaderTableViewCell.self,
			OnboardingTextFieldTableViewCell.self,
			OnboardingOptionsTableViewCell.self,
			OnboardingFooterTableViewCell.self,
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

	func handleForgotPasswordButtonPress() {
		let resetPasswordTableViewController = ResetPasswordTableViewController()
		self.show(resetPasswordTableViewController, sender: nil)
	}

	func handleRegisterButtonPress() {
		let signUpTableViewController = SignUpTableViewController()
		signUpTableViewController.onSignUp = self.onSignIn
		self.show(signUpTableViewController, sender: nil)
	}
}

// MARK: - ASAuthorizationControllerDelegate
extension SignInTableViewController: ASAuthorizationControllerDelegate {
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		switch authorization.credential {
		case let appleIDCredential as ASAuthorizationAppleIDCredential:
			print("----------- Started authorizationController() -----------")
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

			Task {
				do {
					let oAuthResponse = try await KService.signIn(withAppleIDToken: identityTokenString).response()

					switch oAuthResponse.action {
					case .signIn:
						// Save user in keychain.
						if let slug = User.current?.attributes.slug {
							let account = StoredAccount(
								slug: slug,
								username: User.current?.attributes.username,
								profileImageURL: User.current?.attributes.profile?.url,
								authenticationToken: oAuthResponse.authenticationToken
							)
							AccountManager.shared.save(account)
							UserSettings.set(slug, forKey: .selectedAccount)
							WatchSessionManager.shared.sendAuthState(slug: slug, token: oAuthResponse.authenticationToken)
						}

						// Dismiss the view and register user for push notifications.
						self.dismiss(animated: true) {
							UserSettings.shared.removeObject(forKey: UserSettingsKey.lastNotificationRegistrationRequest.rawValue)
							WorkflowController.shared.registerForPushNotifications()
							self.onSignIn?()
						}
					case .setupAccount:
						let signUpTableViewController = SignUpTableViewController()
						signUpTableViewController.isSIWA = true
						signUpTableViewController.onSignUp = self.onSignIn
						self.show(signUpTableViewController, sender: nil)
					default:
						DispatchQueue.main.async {
							// Re-enable user interaction.
							self.disableUserInteraction(false)
						}
					}
				} catch let error as APIError {
					// Re-enable user interaction.
					self.disableUserInteraction(false)
					self.presentAlertController(title: L10n.Onboarding.signInErrorTitle, message: error.message)
				} catch {
					// Re-enable user interaction.
					self.disableUserInteraction(false)
					self.presentAlertController(title: L10n.Onboarding.signInErrorTitle, message: L10n.Onboarding.genericSignInErrorMessage)
				}
			}
		case let passwordCredential as ASPasswordCredential:
			// Sign in using an existing iCloud Keychain credential.
			let email = passwordCredential.user
			let password = passwordCredential.password

			Task {
				await self.signInWithKurozora(email: email, password: password)
			}
		default: break
		}
	}

	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		var message = ""
		if let error = error as? ASAuthorizationError {
			switch error.code {
			case .canceled: break
			case .failed:
				message = L10n.Onboarding.appleAuthenticationFailedMessage
			case .invalidResponse:
				message = L10n.Onboarding.appleInvalidResponseMessage
			case .notHandled:
				message = L10n.Onboarding.appleAuthenticationNotHandledMessage
			default: break
			}
		}

		if !message.isEmpty {
			self.presentAlertController(title: L10n.error, message: message)
		}
	}
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension SignInTableViewController: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return view.window ?? UIWindow()
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SignInTableViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		self.onDismiss?()
	}
}
