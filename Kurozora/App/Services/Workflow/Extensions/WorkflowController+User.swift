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
	/// Checks whether the current user is signed in. If the user is signed in then a success block is run. Otherwise the user is asked to sign in.
	///
	///	- Parameter viewController: The view controller on which the sign in flow is presented if necessary.
	/// - Parameter completion: Optional completion handler (default is `nil`).
	@discardableResult func isSignedIn(on viewController: UIViewController? = nil, _ completion: (() -> Void)? = nil) -> Bool {
		if User.isSignedIn {
			completion?()
			return true
		} else {
			self.presentSignInView(on: viewController)
			return false
		}
	}

	/// Checks whether the current user has a valid subscription. If the user dos then a success block is run. Otherwise subscription features are turned off.
	@MainActor
	func isSubscribed() async -> Bool {
		// Perform action if everything is ok, otherwise prompt for subscription.
		if User.current?.attributes.isSubscribed ?? false {
			return true
		}

		let subscribeAction = UIAlertAction(title: Trans.subscribe, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.presentSubscribeView()
		}

		_ = UIApplication.topViewController?.presentAlertController(title: "Kurozora+ Required", message: "This feature is only accessible to Kurozora+ users. Funds from this go to supporting Kurozora's development.", actions: [subscribeAction])
		return false
	}

	@MainActor
	func isProOrSubscribed() async -> Bool {
		// Perform action if everything is ok, otherwise prompt for subscription.
		if User.current?.attributes.isSubscribed ?? false || User.current?.attributes.isPro ?? false {
			return true
		}

		let subscribeAction = UIAlertAction(title: Trans.subscribe, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.presentSubscribeView()
		}

		let proAction = UIAlertAction(title: Trans.pro, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.presentTipJarView()
		}

		_ = UIApplication.topViewController?.presentAlertController(title: "Pro Required", message: "This feature is accessible to Pro users. Funds from this go to supporting Kurozora's development. Alternatively, this feature and all other features are also included with Kurozora+.", actions: [proAction, subscribeAction])
		return false
	}

	/// Subscribes user with their reminders.
	func subscribeToReminders() {
		Task {
			if await WorkflowController.shared.isSubscribed() {
				let reminderSubscriptionURL = KService.reminderSubscriptionURL
				let reminderSubscriptionString = reminderSubscriptionURL.absoluteString.removingPrefix(reminderSubscriptionURL.scheme ?? "")
				DispatchQueue.main.async {
					UIApplication.shared.kOpen(nil, deepLink: URL(string: "webcal\(reminderSubscriptionString)"))
				}
			}
		}
	}

	/// Repopulates the current user's data.
	///
	/// This method can be used to restore the current user's data after the app has been completely closed.
	///
	/// - Returns: A Boolean indicating whether the user's details were restored successfully.
	func restoreCurrentUserSession() async -> Bool {
		let accountKey = UserSettings.selectedAccount
		if let authenticationKey = KurozoraDelegate.shared.keychain[accountKey] {
			KService.authenticationKey = authenticationKey

			do {
				_ = try await KService.getProfileDetails().value
				return true
			} catch {
				print("-----", error.localizedDescription)
				return false
			}
		}

		return false
	}

	/// Presents the user with the sign in view
	///
	///	- Parameter viewController: The view controller on which the sign in flow is presented if necessary.
	func presentSignInView(on viewController: UIViewController? = nil) {
		if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
			let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
			let viewController = viewController ?? UIApplication.topViewController
			viewController?.present(kNavigationController, animated: true)
		}
	}

	/// Presents the user with the subscribe view.
	func presentSubscribeView() {
		if let subscriptionKNavigationController = R.storyboard.purchase.subscriptionKNavigationController() {
			UIApplication.topViewController?.present(subscriptionKNavigationController, animated: true)
		}
	}

	/// Presents the user with the tip jar view.
	func presentTipJarView() {
		if let tipJarKNavigationController = R.storyboard.purchase.tipJarKNavigationController() {
			UIApplication.topViewController?.present(tipJarKNavigationController, animated: true)
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

	/// Deletes the user's account.
	///
	/// - Parameters:
	///    - password: The password of the user.
	///
	/// - Returns: a boolean indicating whether the deletion is successful.
	func deleteUser(password: String) async -> Bool {
		guard User.isSignedIn else { return false }
		let username = User.current?.attributes.username ?? ""

		do {
			_ = try await KService.deleteUser(password: password).value
			try? KurozoraDelegate.shared.keychain.remove(username)
			return true
		} catch {
			print("-----", error.localizedDescription)
			return false
		}
	}
}
