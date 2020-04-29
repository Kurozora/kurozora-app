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

class SignInWithAppleTableViewController: KTableViewController {
	// MARK: - Properties
	let previewImages = [R.image.promotional.signInWithApple()]

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

		// Stop activity indicator as it's not needed for now.
		_prefersActivityIndicatorHidden = true
	}
}

// MARK: - UITableViewDataSource
extension SignInWithAppleTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			guard let productPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productPreviewTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productPreviewTableViewCell.identifier)")
			}
			return productPreviewTableViewCell
		} else if indexPath.section == 1 {
			guard let productHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productHeaderTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productHeaderTableViewCell.identifier)")
			}
			return productHeaderTableViewCell
		} else if indexPath.section == 2 {
			guard let siwaButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.siwaButtonTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.siwaButtonTableViewCell.identifier)")
			}
			return siwaButtonTableViewCell
		}

		guard let productInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productInfoTableViewCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productInfoTableViewCell.identifier)")
		}
		return productInfoTableViewCell
	}
}

// MARK: - UITableViewDelegate
extension SignInWithAppleTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			let productPreviewTableViewCell = cell as? ProductPreviewTableViewCell
			productPreviewTableViewCell?.previewImages = previewImages
		} else if indexPath.section == 2 {
			let siwaButtonTableViewCell = cell as? SIWAButtonTableViewCell
			siwaButtonTableViewCell?.onboardingFooterTableViewCellDelegate = self
		}
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			let cellRatio: CGFloat = UIDevice.isLandscape ? 1.5 : 3
			return view.frame.height / cellRatio
		}

		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 22
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
		KService.register(withAppleUserID: appleIDCredential.user, emailAddress: emailAddress) { result in
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
