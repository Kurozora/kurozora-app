//
//  BaseOnboardingTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import AuthenticationServices
import SCLAlertView

class BaseOnboardingTableViewController: UITableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var subTextLabel: UILabel! {
		didSet {
			subTextLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var rightNavigationBarButton: UIBarButtonItem!

	// MARK: - Properties
	var textFieldArray: [UITextField?] = []
	var onboardingType: OnboardingType = .register

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		rightNavigationBarButton.isEnabled = false
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if #available(iOS 13.0, *) {
			performExistingAccountSetupFlows()
		}
	}

	// MARK: - Functions
	/// Prompts the user if an existing KDefaults credential or Apple ID credential is found.
	@available(iOS 13.0, *)
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

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func rightNavigationBarButtonPressed(sender: AnyObject) {
		view.endEditing(true)
	}
}

// MARK: - UITableViewDataSource
extension BaseOnboardingTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return onboardingType.cellType.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = onboardingType.cellType[indexPath.row] == .footer ? "OnboardingFooterTableViewCell" : "OnboardingTextFieldCell"
		let onboardingBaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OnboardingBaseTableViewCell
		onboardingBaseTableViewCell.onboardingType = onboardingType

		switch onboardingType.cellType[indexPath.row] {
		case .username:
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.textType = .username
		case .email:
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.textType = .emailAddress
		case .password:
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.textType = .password
		default: break
		}

		if onboardingBaseTableViewCell as? OnboardingTextFieldCell != nil {
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.tag = indexPath.row
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.delegate = self
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
			textFieldArray.append((onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField)
		}

		if onboardingBaseTableViewCell as? OnboardingFooterTableViewCell != nil {
			(onboardingBaseTableViewCell as? OnboardingFooterTableViewCell)?.onboardingFooterTableViewCellDelegate = self
		}

		onboardingBaseTableViewCell.configureCell()
		return onboardingBaseTableViewCell
	}
}

// MARK: - UITextFieldDelegate
extension BaseOnboardingTableViewController: UITextFieldDelegate {
	@objc func editingChanged(_ textField: UITextField) {
		if textField.text?.count == 1, textField.text?.first == " " {
			textField.text = ""
			return
		}

		var rightNavigationBarButtonIsEnabled = false
		textFieldArray.forEach({
			if let textField = $0?.text, !textField.isEmpty {
				rightNavigationBarButtonIsEnabled = true
				return
			}
			rightNavigationBarButtonIsEnabled = false
		})

		rightNavigationBarButton.isEnabled = rightNavigationBarButtonIsEnabled
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		switch onboardingType {
		case .register:
			textField.returnKeyType = textField.tag == textFieldArray.count - 1 ? .join : .next
		case .signIn:
			textField.returnKeyType = textField.tag == textFieldArray.count - 1 ? .go : .next
		case .reset:
			textField.returnKeyType = textField.tag == textFieldArray.count - 1 ? .send : .next
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField.tag == textFieldArray.count - 1 {
			rightNavigationBarButtonPressed(sender: textField)
		} else {
			textFieldArray[textField.tag + 1]?.becomeFirstResponder()
		}

		return true
	}
}

// MARK: - OnboardingFooterTableViewCellDelegate
extension BaseOnboardingTableViewController: OnboardingFooterTableViewCellDelegate {
	@available(iOS 13.0, *)
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
@available(iOS 13.0, *)
extension BaseOnboardingTableViewController: ASAuthorizationControllerDelegate {
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
			self.dismiss(animated: true, completion: nil)
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

	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		//		SCLAlertView().showError("Error", subTitle: error.localizedDescription)
	}
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
@available(iOS 13.0, *)
extension BaseOnboardingTableViewController: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return self.view.window!
	}
}
