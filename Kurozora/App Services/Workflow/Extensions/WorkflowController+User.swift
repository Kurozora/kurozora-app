//
//  WorkflowController+User.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

// MARK: - User
extension WorkflowController {
	/**
		Checks whether the current user is signed in. If the user is signed in then a success block is run. Otherwise the user is asked to sign in.

		- Parameter completion: Optional completion handler (default is `nil`).
	*/
	func isSignedIn(_ completion: (() -> Void)? = nil) {
		if User.isSignedIn {
			completion?()
		} else {
			if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
				let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
				UIApplication.topViewController?.present(kNavigationController, animated: true)
			}
		}
	}

	/**
		Checks whether the current user is pro. If the user is pro in then a success block is run. Otherwise pro features are turned off.

		- Parameter completion: Optional completion handler (default is `nil`).
	*/
	func isPro(_ completion: (() -> Void)? = nil) {
		if User.isPro {
			completion?()
		} else {
			UIApplication.topViewController?.presentAlertController(title: "That's Unfortunate", message: "This feature is only accessible to pro users 🧐")
		}
	}

	/**
		Repopulates the current user's data.

		This method can be used to restore the current user's data after the app has been completely closed.
	*/
	func restoreCurrentUserSession() {
		let accountKey = UserSettings.selectedAccount
		if let authenticationKey = KurozoraDelegate.shared.keychain[accountKey] {
			DispatchQueue.global(qos: .background).async {
				KService.restoreDetails(forUserWith: authenticationKey) { result in
					switch result {
					case .success(let newAuthenticationKey):
						try? KurozoraDelegate.shared.keychain.set(newAuthenticationKey, key: accountKey)
					case .failure:
						try? KurozoraDelegate.shared.keychain.remove(accountKey)
					}
				}
			}
		}
	}
}
