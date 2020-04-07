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
import SCLAlertView

class SignInTableViewController: BaseOnboardingTableViewController {
	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		onboardingType = .signIn
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if #available(iOS 13.0, macCatalyst 13.0, *) {
			performExistingAccountSetupFlows()
		}
	}

	// MARK: - Functions
	/// Prompts the user if an existing KDefaults credential or Apple ID credential is found.
	@available(iOS 13.0, macCatalyst 13.0, *)
	func performExistingAccountSetupFlows() {
		// Prepare requests for both Apple ID and password providers.
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()

		// Create an authorization controller with the given requests.
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
	}

	// MARK: - IBActions
	override func rightNavigationBarButtonPressed(sender: AnyObject) {
		super.rightNavigationBarButtonPressed(sender: sender)

		guard let kurozoraID = textFieldArray.first??.trimmedText else { return }
		guard let password = textFieldArray.last??.text else { return }
		#if targetEnvironment(macCatalyst)
		let platform = " on macOS "
		#else
		let platform = " on iOS "
		#endif
		let device = UIDevice.modelName + platform + UIDevice.current.systemVersion

		KService.signIn(kurozoraID, password, device, withSuccess: { (success) in
			if success {
				DispatchQueue.main.async {
					NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
					self.dismiss(animated: true) {
						UserSettings.shared.removeObject(forKey: UserSettingsKey.lastNotificationRegistrationRequest.rawValue)
						WorkflowController.shared.registerForPushNotifications()
					}
				}
			}
			self.rightNavigationBarButton.isEnabled = false
		})
	}
}

// MARK: - OnboardingFooterTableViewCellDelegate
extension SignInTableViewController: OnboardingFooterTableViewCellDelegate {
	@available(iOS 13.0, macCatalyst 13.0, *)
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
@available(iOS 13.0, macCatalyst 13.0, *)
extension SignInTableViewController: ASAuthorizationControllerDelegate {
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
//		print("User ID - \(appleIDCredential.user)")
//		print("User Name - \(appleIDCredential.fullName?.description ?? "N/A")")
//		print("User Email - \(appleIDCredential.email ?? "N/A")")
//		print("Real User Status - \(appleIDCredential.realUserStatus.rawValue)")
//
//		if let authorizationCode = appleIDCredential.authorizationCode,
//			let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) {
//			print("Refresh Token \(authorizationCodeString)")
//		}
//
//		if let identityTokenData = appleIDCredential.identityToken,
//			let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
//			print("Identity Token \(identityTokenString)")
//		}

		guard let emailAddress = appleIDCredential.email else { return }
		KService.register(withAppleUserID: appleIDCredential.user, emailAddress: emailAddress) { (success) in
			if success {
//				if let registerTableViewController = R.storyboard.onboarding.registerTableViewController() {
//					registerTableViewController.isSIWA = true
//					self.show(registerTableViewController, sender: nil)
//				}

				let alertController = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
				alertController.showSuccess("Hooray!", subTitle: "Account created successfully!")
				alertController.addButton("Done", action: {
					DispatchQueue.main.async {
						self.navigationController?.popViewController(animated: true)
						self.dismiss(animated: true) {
							UserSettings.shared.removeObject(forKey: UserSettingsKey.lastNotificationRegistrationRequest.rawValue)
							WorkflowController.shared.registerForPushNotifications()
						}
					}
				})
			}
		}
	}

	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		var subTitle = ""
		if let error = error as? ASAuthorizationError {
			switch error.code {
			case .canceled: break
			case .failed:
				subTitle = "Authentication failed by Apple. Please try again."
			case .invalidResponse:
				subTitle = "The app received an invalid response from Apple. Please try again."
			case .notHandled:
				subTitle = "An error occured and the authentication was not handled by Apple. Please try again."
			default: break
			}
		}

		if !subTitle.isEmpty {
			SCLAlertView().showError("Error", subTitle: subTitle)
		}
//		print("Error description: \(subTitle)")
//		print("Error localized: \(error.localizedDescription)")
	}
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
@available(iOS 13.0, macCatalyst 13.0, *)
extension SignInTableViewController: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return view.window ?? UIWindow()
	}
}
