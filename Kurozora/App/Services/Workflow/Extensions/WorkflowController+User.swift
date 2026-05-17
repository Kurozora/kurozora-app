//
//  WorkflowController+User.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

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
				var didResume = false
				let signInVC = self.presentSignInView(on: viewController)

				signInVC.onSignIn = {
					guard !didResume else { return }
					didResume = true
					continuation.resume(returning: true)
				}
				signInVC.onDismiss = {
					guard !didResume else { return }
					didResume = true
					continuation.resume(returning: false)
				}

				signInVC.navigationController?.presentationController?.delegate = signInVC
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

		let subscribeAction = UIAlertAction(title: L10n.subscribe, style: .default) { [weak self] _ in
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

		let subscribeAction = UIAlertAction(title: L10n.subscribe, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.presentSubscribeView(on: viewController)
		}

		let proAction = UIAlertAction(title: L10n.pro, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.presentTipJarView(on: viewController)
		}

		let viewController = viewController ?? UIApplication.topViewController
		_ = viewController?.presentAlertController(title: "Pro Required", message: "This feature is accessible to Pro users. Funds from this go to supporting Kurozora's development. Alternatively, this feature and all other features are also included with Kurozora+.", actions: [proAction, subscribeAction])
		return false
	}

	/// Get the settings used to enable additional functionality in the app.
	func getSettings() async {
		do {
			let settingsResponse = try await KService.settings().response()
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
		if let account = AccountManager.shared.account(forSlug: accountKey) {
			KService.authenticationKey = account.authenticationToken

			do {
				_ = try await KService.profileDetails().response()

				// Refresh stored metadata with latest profile data
				AccountManager.shared.updateMetadata(
					forSlug: accountKey,
					username: User.current?.attributes.username,
					profileImageURL: User.current?.attributes.profile?.url
				)

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
	func presentSignInView(on viewController: UIViewController? = nil) -> SignInTableViewController {
		let signInTableViewController = SignInTableViewController()
		let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
		let viewController = viewController ?? UIApplication.topViewController
		viewController?.present(kNavigationController, animated: true)

		return signInTableViewController
	}

	/// Presents the user with the subscribe view.
	///
	///	- Parameter viewController: The view controller on which the subscription view is presented.
	func presentSubscribeView(on viewController: UIViewController? = nil) {
		let subscriptionCollectionViewController = SubscriptionCollectionViewController()
		let kNavigationController = KNavigationController(rootViewController: subscriptionCollectionViewController)
		let viewController = viewController ?? UIApplication.topViewController
		viewController?.present(kNavigationController, animated: true)
	}

	/// Presents the user with the tip jar view.
	///
	///	- Parameter viewController: The view controller on which the Tip Jar view is presented .
	func presentTipJarView(on viewController: UIViewController? = nil) {
		let tipJarCollectionViewController = TipJarCollectionViewController()
		let kNavigationController = KNavigationController(rootViewController: tipJarCollectionViewController)
		let viewController = viewController ?? UIApplication.topViewController
		viewController?.present(kNavigationController, animated: true)
	}

	/// Signs out the user and removes all data from the keychain.
	func signOut() async {
		guard User.isSignedIn else { return }
		let slug = User.current?.attributes.slug ?? UserSettings.selectedAccount

		do {
			_ = try await KService.signOut()
			AccountManager.shared.remove(slug: slug)
			WatchSessionManager.shared.sendAuthState(slug: nil, token: nil)
		} catch let error as APIError {
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
		let slug = User.current?.attributes.slug ?? UserSettings.selectedAccount

		do {
			_ = try await KService.deleteAccount(password: password).response()
			AccountManager.shared.remove(slug: slug)
			return true
		} catch let error as APIError {
			await UIApplication.topViewController?.presentAlertController(title: "Can't Delete Account 😔", message: error.message)
			print("-----", error.message)
		} catch {
			print("-----", error.localizedDescription)
		}

		return false
	}
}
