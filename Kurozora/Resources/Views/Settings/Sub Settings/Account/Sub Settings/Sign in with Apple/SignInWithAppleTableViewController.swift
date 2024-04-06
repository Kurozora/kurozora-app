//
//  SignInWithAppleTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import AuthenticationServices

class SignInWithAppleTableViewController: ServiceTableViewController {
	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Configure properties
		self.previewImage = R.image.promotional.signInWithApple()
		self.serviceType = .signInWithApple
	}
}

// MARK: - UITableViewDataSource
extension SignInWithAppleTableViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .body:
			guard let siwaButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.siwaButtonTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.siwaButtonTableViewCell.identifier)")
			}
			siwaButtonTableViewCell.onboardingFooterTableViewCellDelegate = self
			return siwaButtonTableViewCell
		default:
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
}

// MARK: - OnboardingOptionsTableViewCellDelegate
extension SignInWithAppleTableViewController: OnboardingOptionsTableViewCellDelegate {
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
extension SignInWithAppleTableViewController: ASAuthorizationControllerDelegate {
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
						if let slug = User.current?.attributes.slug {
							try? SharedDelegate.shared.keychain.set(oAuthResponse.authenticationToken, key: slug)
							UserSettings.set(slug, forKey: .selectedAccount)
						}

						// Update the user's authentication key in KurozoraKit.
						KService.authenticationKey = oAuthResponse.authenticationToken

						// Dismiss the view.
						self.dismiss(animated: true, completion: nil)
					default: break
					}
				case .failure: break
				}
			}
			print("----------- Ended authorizationController() -----------")
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
extension SignInWithAppleTableViewController: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return view.window ?? UIWindow()
	}
}
