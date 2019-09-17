//
//  WelcomeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftTheme
import WhatsNew
import AuthenticationServices

class WelcomeViewController: UIViewController {
	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet weak var buttonsStackView: UIStackView!

	var logoutReason: String? = nil
	var isKiller: Bool?
	var statusBarShouldBeHidden = true

	override var prefersStatusBarHidden: Bool {
		return statusBarShouldBeHidden
	}

	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return UIStatusBarAnimation.slide
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)

		// Show the status bar
		statusBarShouldBeHidden = true
		UIView.animate(withDuration: 0.25) {
			self.setNeedsStatusBarAppearanceUpdate()
		}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		backgroundImageView.addParallax()

		if #available(iOS 13.0, *) {
			let signInWithAppleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
			signInWithAppleButton.addConstraint(signInWithAppleButton.heightAnchor.constraint(equalToConstant: 40))
			signInWithAppleButton.cornerRadius = 20
			signInWithAppleButton.addTarget(self, action: #selector(signInWithAppleButtonPressed), for: .touchUpInside)
			buttonsStackView.addArrangedSubview(signInWithAppleButton)
		}
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if WhatsNew.shouldPresent() {
			let whatsNew = KWhatsNewViewController(items: [
				WhatsNewItem.image(title: "Very Sleep", subtitle: "Easy on your eyes with the dark theme.", image: #imageLiteral(resourceName: "darkmode")),
				WhatsNewItem.image(title: "High Five", subtitle: "Your privacy is our #1 priority!", image: #imageLiteral(resourceName: "privacy_icon")),
				WhatsNewItem.image(title: "Attention Grabber", subtitle: "New follower? New message? Look here!", image: #imageLiteral(resourceName: "notifications_icon"))
			])
			whatsNew.titleText = "What's New"
			whatsNew.buttonText = "Continue"
			whatsNew.titleColor = KThemePicker.textColor.colorValue
			whatsNew.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
			whatsNew.itemTitleColor = KThemePicker.textColor.colorValue
			whatsNew.itemSubtitleColor = KThemePicker.subTextColor.colorValue
			whatsNew.buttonTextColor = KThemePicker.tintedButtonTextColor.colorValue
			whatsNew.buttonBackgroundColor = KThemePicker.tintColor.colorValue
			present(whatsNew, animated: true, completion: nil)
		}

		if let isKiller = isKiller, !isKiller && logoutReason != nil {
			SCLAlertView().showInfo("You have been logged out", subTitle: logoutReason)
			self.logoutReason = nil
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "login", bundle: nil)
		return storyboard.instantiateInitialViewController()
	}

	@objc @available(iOS 13.0, *)
	func signInWithAppleButtonPressed() {
		let authorizationRequest = ASAuthorizationAppleIDProvider().createRequest()
		authorizationRequest.requestedScopes = [.email]

		let authorizationController = ASAuthorizationController(authorizationRequests: [authorizationRequest])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
	}

	@objc @available(iOS 13.0, *)
	func testUserID(userID: String) {
		let provider = ASAuthorizationAppleIDProvider()
		provider.getCredentialState(forUserID: userID) { (credentialState, _) in
			switch credentialState {
			case .revoked:
				print("ID is revoked")
			case .authorized:
				print("ID is authorized")
			case .notFound:
				print("ID is notFound")
			case .transferred:
				print("ID is transferred.")
			default:
				break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Hide the status bar
		statusBarShouldBeHidden = false
		UIView.animate(withDuration: 0.25) {
			self.setNeedsStatusBarAppearanceUpdate()
		}
	}
}

// MARK: - ASAuthorizationControllerDelegate
@available(iOS 13.0, *)
extension WelcomeViewController: ASAuthorizationControllerDelegate {
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		if let authorizationCredentials = authorization.credential as? ASAuthorizationAppleIDCredential {
			if let email = authorizationCredentials.email {
				print("Got email: \(email)")
			}
			print("and user: \(authorizationCredentials.user)")
			testUserID(userID: authorizationCredentials.user)
		}
	}
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
@available(iOS 13.0, *)
extension WelcomeViewController: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return self.view.window!
	}
}
