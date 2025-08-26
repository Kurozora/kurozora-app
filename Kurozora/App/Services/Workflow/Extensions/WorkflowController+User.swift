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
	/// Checks whether the current user is signed in.
	/// If the user is not signed in, the method waits for the user to complete the sign in flow before returning.
	///
	///	- Parameter viewController: The view controller on which the sign in flow is presented if necessary.
	@MainActor
	func isSignedIn(on viewController: UIViewController? = nil) async -> Bool {
		if User.isSignedIn {
			return true
		} else {
			return await withCheckedContinuation { continuation in
				self.presentSignInView(on: viewController)?.onSignIn = {
					continuation.resume(returning: true)
				}
			}
		}
	}

	/// Checks whether the current user has a valid subscription. If the user dos then a success block is run. Otherwise subscription features are turned off.
	///
	///	- Parameter viewController: The view controller on which the subscription flow is presented if necessary.
	@MainActor
	func isSubscribed(on viewController: UIViewController? = nil) async -> Bool {
		// Perform action if everything is ok, otherwise prompt for subscription.
		if User.current?.attributes.isSubscribed ?? false {
			return true
		}

		let subscribeAction = UIAlertAction(title: Trans.subscribe, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.presentSubscribeView(on: viewController)
		}

		let viewController = viewController ?? UIApplication.topViewController
		_ = viewController?.presentAlertController(title: "Kurozora+ Required", message: "This feature is only accessible to Kurozora+ users. Funds from this go to supporting Kurozora's development.", actions: [subscribeAction])
		return false
	}

	@MainActor
	func isProOrSubscribed(on viewController: UIViewController? = nil) async -> Bool {
		// Perform action if everything is ok, otherwise prompt for subscription.
		if User.isSubscribed || User.isPro {
			return true
		}

		let subscribeAction = UIAlertAction(title: Trans.subscribe, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.presentSubscribeView(on: viewController)
		}

		let proAction = UIAlertAction(title: Trans.pro, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.presentTipJarView(on: viewController)
		}

		let viewController = viewController ?? UIApplication.topViewController
		_ = viewController?.presentAlertController(title: "Pro Required", message: "This feature is accessible to Pro users. Funds from this go to supporting Kurozora's development. Alternatively, this feature and all other features are also included with Kurozora+.", actions: [proAction, subscribeAction])
		return false
	}

	/// Subscribes user with their reminders.
	@MainActor
	func subscribeToReminders(on viewController: UIViewController? = nil) async {
		if await WorkflowController.shared.isSubscribed(on: viewController) {
			let reminderSubscriptionURL = KService.reminderSubscriptionURL
			let reminderSubscriptionString = reminderSubscriptionURL.absoluteString.removingPrefix(reminderSubscriptionURL.scheme ?? "")

			UIApplication.shared.kOpen(nil, deepLink: URL(string: "webcal\(reminderSubscriptionString)"))
		}
	}

	/// Get the settings used to enable additional functionality in the app.
	func getSettings() async {
		do {
			let settingsResponse = try await KService.getSettings().value
			KSettings = settingsResponse.data
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	/// Repopulates the current user's data.
	///
	/// This method can be used to restore the current user's data after the app has been completely closed.
	///
	/// - Returns: A Boolean indicating whether the user's details were restored successfully.
	@discardableResult
	func restoreCurrentUserSession() async -> Bool {
		let accountKey = UserSettings.selectedAccount
		if let authenticationKey = SharedDelegate.shared.keychain[accountKey] {
			KService.authenticationKey = authenticationKey

			do {
				_ = try await KService.getProfileDetails()
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
	@discardableResult
	func presentSignInView(on viewController: UIViewController? = nil) -> SignInTableViewController? {
		if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
			let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
			let viewController = viewController ?? UIApplication.topViewController
			viewController?.present(kNavigationController, animated: true)

			return signInTableViewController
		}

		return nil
	}

	/// Presents the user with the subscribe view.
	///
	///	- Parameter viewController: The view controller on which the subscription view is presented.
	func presentSubscribeView(on viewController: UIViewController? = nil) {
		if let subscriptionKNavigationController = R.storyboard.purchase.subscriptionKNavigationController() {
			let viewController = viewController ?? UIApplication.topViewController
			viewController?.present(subscriptionKNavigationController, animated: true)
		}
	}

	/// Presents the user with the tip jar view.
	///
	///	- Parameter viewController: The view controller on which the Tip Jar view is presented .
	func presentTipJarView(on viewController: UIViewController? = nil) {
		if let tipJarKNavigationController = R.storyboard.purchase.tipJarKNavigationController() {
			let viewController = viewController ?? UIApplication.topViewController
			viewController?.present(tipJarKNavigationController, animated: true)
		}
	}

	/// Signs out the user and removes all data from the keychain.
	func signOut() async {
		guard User.isSignedIn else { return }
		let slug = User.current?.attributes.slug ?? ""

		do {
			_ = try await KService.signOut()
			try? SharedDelegate.shared.keychain.remove(slug)
		} catch let error as KKAPIError {
			await UIApplication.topViewController?.presentAlertController(title: "Can't Sign Out 😔", message: error.message)
			print("-----", error.message)
		} catch {
			print("-----", error.localizedDescription)
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
		let slug = User.current?.attributes.slug ?? ""

		do {
			_ = try await KService.deleteUser(password: password)
			try? SharedDelegate.shared.keychain.remove(slug)
			return true
		} catch let error as KKAPIError {
			await UIApplication.topViewController?.presentAlertController(title: "Can't Delete Account 😔", message: error.message)
			print("-----", error.message)
		} catch {
			print("-----", error.localizedDescription)
		}

		return false
	}
}
