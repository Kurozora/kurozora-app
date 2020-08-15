//
//  SignInWithAppleTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import AuthenticationServices
import SCLAlertView

class SignInWithAppleTableViewController: ServiceTableViewController {
	// MARK: - Properties
	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Configure properties
		self.previewImage = R.image.promotional.signInWithApple()
		self.serviceType = .signInWithApple

		// Stop activity indicator as it's not needed for now.
		_prefersActivityIndicatorHidden = true
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
			return siwaButtonTableViewCell
		default:
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
}

// MARK: - UITableViewDelegate
extension SignInWithAppleTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		switch Section(rawValue: indexPath.section) {
		case .body:
			if let siwaButtonTableViewCell = cell as? SIWAButtonTableViewCell {
				siwaButtonTableViewCell.onboardingFooterTableViewCellDelegate = self
			}
		default: break
		}
	}
}

// MARK: - OnboardingFooterTableViewCellDelegate
extension SignInWithAppleTableViewController: OnboardingFooterTableViewCellDelegate {
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
extension SignInWithAppleTableViewController: ASAuthorizationControllerDelegate {
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
		guard let emailAddress = appleIDCredential.email else { return }
		KService.register(withAppleUserID: appleIDCredential.user, emailAddress: emailAddress) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success:
				let alertController = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
				alertController.showSuccess("Yay!", subTitle: "You can now sign in using Sign in with Apple!")
				alertController.addButton("Done", action: {
					DispatchQueue.main.async {
						self.navigationController?.popViewController(animated: true)

						self.dismiss(animated: true) {
							UserSettings.shared.removeObject(forKey: UserSettingsKey.lastNotificationRegistrationRequest.rawValue)
							WorkflowController.shared.registerForPushNotifications()
						}
					}
				})
			case .failure: break
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
	}
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
@available(iOS 13.0, macCatalyst 13.0, *)
extension SignInWithAppleTableViewController: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return view.window ?? UIWindow()
	}
}
