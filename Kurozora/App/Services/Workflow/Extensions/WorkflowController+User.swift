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
		_ = viewController?.presentAlertController(title: L10n.kurozoraPlusRequiredTitle, message: L10n.kurozoraPlusRequiredMessage, actions: [subscribeAction])
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
		_ = viewController?.presentAlertController(title: L10n.proRequiredTitle, message: L10n.proRequiredMessage, actions: [proAction, subscribeAction])
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

	/// Fetches the authenticated user's account settings.
	func fetchMySettings() async {
		do {
			let settingsResponse = try await KService.mySettings().response()

			guard let settings = settingsResponse.data.first else { return }

			UserSettings.set(settings.attributes.ratingStyle.rawValue, forKey: .ratingStyle)
			NotificationCenter.default.post(name: .KSRatingStyleDidChange, object: nil)
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	/// Repopulates the current user's data.
	///
	/// - Parameter updateAuthenticationKey: Whether the authentication key of the active account is applied before the user's data is requested.
	///
	/// - Returns: A Boolean indicating whether the user's details were restored successfully.
	@discardableResult
	func restoreCurrentUserSession(updateAuthenticationKey: Bool = true) async -> Bool {
		let accountKey = UserSettings.selectedAccount
		if let account = AccountManager.shared.account(forSlug: accountKey) {
			if updateAuthenticationKey {
				KService.authenticationKey = account.authenticationToken
			}

			do {
				_ = try await KService.profileDetails().response()

				// Refresh stored metadata with latest profile data
				AccountManager.shared.updateMetadata(
					forSlug: accountKey,
					username: User.current?.attributes.username,
					profileImageURL: User.current?.attributes.profile?.url
				)

				if let currentUser = User.current {
					UserProfileCache.save(currentUser, forSlug: accountKey)
				}

				Task { [weak self] in
					await self?.fetchMySettings()
				}

				return true
			} catch let error as APIError where (400..<500).contains(error.statusCode ?? 0) {
				print("-----", error.message)
				return false
			} catch {
				guard let cachedUser = UserProfileCache.load(forSlug: accountKey) else {
					print("-----", error.localizedDescription)
					return false
				}

				await KService.restoreSession(with: cachedUser)
				return true
			}
		}

		return false
	}

	/// Switches to the given account.
	///
	/// - Parameter account: The account to make active.
	@MainActor
	func switchAccount(to account: StoredAccount) {
		UserSettings.set(account.slug, forKey: .selectedAccount)
		KService.authenticationKey = account.authenticationToken
		WatchSessionManager.shared.sendAuthState(slug: account.slug, token: account.authenticationToken)

		Task {
			if await self.restoreCurrentUserSession() {
				NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
			}
		}
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
			UserProfileCache.remove(forSlug: slug)
			await LibraryStore.shared.clear(forUserSlug: slug)
			await LibraryOutbox.shared.clear(forUserSlug: slug)
			await WatchedStore.shared.clear()
			await LibraryArtStore.shared.removeAll()
			WatchSessionManager.shared.sendAuthState(slug: nil, token: nil)
		} catch let error as APIError {
			await UIApplication.topViewController?.presentAlertController(title: L10n.cantSignOutTitle, message: error.message)
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
			UserProfileCache.remove(forSlug: slug)
			await LibraryStore.shared.clear(forUserSlug: slug)
			await LibraryOutbox.shared.clear(forUserSlug: slug)
			await WatchedStore.shared.clear()
			await LibraryArtStore.shared.removeAll()
			return true
		} catch let error as APIError {
			await UIApplication.topViewController?.presentAlertController(title: L10n.cantDeleteAccountTitle, message: error.message)
			print("-----", error.message)
		} catch {
			print("-----", error.localizedDescription)
		}

		return false
	}
}
