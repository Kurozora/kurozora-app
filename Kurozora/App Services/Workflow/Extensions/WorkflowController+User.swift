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
	@discardableResult func isSignedIn(_ completion: (() -> Void)? = nil) -> Bool {
		if User.isSignedIn {
			completion?()
			return true
		} else {
			self.presentSignInView()
			return false
		}
	}

	/**
		Checks whether the current user is pro. If the user is pro in then a success block is run. Otherwise pro features are turned off.

		- Parameter completion: Optional completion handler (default is `nil`).
	*/
	@MainActor
	@discardableResult func isPro(_ completion: (() -> Void)? = nil) async -> Bool {
//		if User.isPro {
		// Get entitled subscription ID
		var entitledProductID = ""
		for await result in Transaction.currentEntitlements {
			if case .verified(let transaction) = result {
				entitledProductID = transaction.productID
			}
		}

		// Check if purchased which also validates with StoreKit.
		let isPurchased = try? await store.isPurchased(entitledProductID)

		// Perform action if everything is ok, otherwise prompt for subscription.
		if isPurchased ?? false {
			completion?()
			return true
		} else {
			let subscribeAction = UIAlertAction(title: "Subscribe", style: .default) { _ in
				self.presentSubscribeView()
			}

			UIApplication.topViewController?.presentAlertController(title: "That's Unfortunate", message: "This feature is only accessible to pro users 🧐", actions: [subscribeAction])
			return false
		}
	}

	/// Subscribes user with their reminders.
	func subscribeToReminders() {
		UIApplication.topViewController?.presentAlertController(title: "Work in Progress", message: "Reminders have temporarily been disabled. An improved version is being worked on and should be available soon!")
//		Task {
//			await WorkflowController.shared.isPro {
//				let reminderSubscriptionURL = KService.reminderSubscriptionURL
//				let reminderSubscriptionString = reminderSubscriptionURL.absoluteString.removingPrefix(reminderSubscriptionURL.scheme ?? "")
//				DispatchQueue.main.async {
//					UIApplication.shared.kOpen(nil, deepLink: URL(string: "webcal\(reminderSubscriptionString)"))
//				}
//			}
//		}
	}

	/**
		Repopulates the current user's data.

		This method can be used to restore the current user's data after the app has been completely closed.
	*/
	func restoreCurrentUserSession() {
		let accountKey = UserSettings.selectedAccount
		if let authenticationKey = KurozoraDelegate.shared.keychain[accountKey] {
			KService.authenticationKey = authenticationKey

			DispatchQueue.global(qos: .background).async {
				KService.getProfileDetails { _ in }
			}
		}
	}

	/// Presents the user with the sign in view
	func presentSignInView() {
		if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
			let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
			UIApplication.topViewController?.present(kNavigationController, animated: true)
		}
	}

	/// Presents the user with the subscribe view.
	func presentSubscribeView() {
		if let subscriptionKNavigationController = R.storyboard.purchase.subscriptionKNavigationController() {
			UIApplication.topViewController?.present(subscriptionKNavigationController, animated: true)
		}
	}

	/// Signs out the user and removes all data from the keychain.
	func signOut() {
		let username = User.current?.attributes.username ?? ""
		if User.isSignedIn {
			KService.signOut { result in
				switch result {
				case .success:
					try? KurozoraDelegate.shared.keychain.remove(username)
				case .failure:
					break
				}
			}
		}
	}
}
