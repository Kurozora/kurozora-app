//
//  AuthenticationManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import LocalAuthentication
import UIKit

/// Manages biometric and passcode authentication for app lock.
final class AuthenticationManager {
	// MARK: - Properties
	/// Returns the singleton `AuthenticationManager` instance.
	static let shared = AuthenticationManager()

	/// Indicates whether authentication has been enabled by the user.
	private(set) var isEnabled: Bool = false

	/// The deadline (uptime) after which the app should ask the user for authentication.
	private(set) var authenticationDeadline: Int = 0

	// MARK: - Initializers
	private init() {}

	// MARK: - Scene Lifecycle
	/// Called when the scene enters the background.
	///
	/// Records the authentication deadline and dismisses any existing authentication view controller.
	func sceneDidEnterBackground() {
		self.isEnabled = UserSettings.authenticationEnabled

		if self.isEnabled {
			self.recordAuthenticationDeadline()
		}
	}

	/// Called when the scene becomes active.
	///
	/// Presents the authentication screen if the deadline has passed.
	///
	/// - Parameter presentingOn: The view controller to present the authentication screen on. Defaults to `topViewController`.
	func sceneDidBecomeActiveIfNeeded(presentingOn viewController: UIViewController? = nil) {
		if Date.uptime() > self.authenticationDeadline, self.isEnabled {
			DispatchQueue.main.async {
				self.presentAuthenticationScreen(on: viewController)
			}
		}
	}

	// MARK: - App Init / Return from Offline
	/// Presents the authentication screen if required by user settings.
	///
	/// - Parameter presentingOn: The view controller to present the authentication screen on. Defaults to `topViewController`.
	func authenticateIfRequired(presentingOn viewController: UIViewController? = nil) {
		if UserSettings.authenticationEnabled {
			DispatchQueue.main.async {
				self.presentAuthenticationScreen(on: viewController)
			}
		}
	}

	// MARK: - Auth Handling
	/// Evaluates local authentication for the given `AuthenticationViewController`.
	///
	/// On success the view controller is dismissed; on failure the unlock UI is shown.
	///
	/// - Parameter viewController: The `AuthenticationViewController` requesting authentication.
	func handleAuthentication(for viewController: AuthenticationViewController) {
		self.evaluateLocalAuthentication(viewController: viewController) { success in
			if success {
				DispatchQueue.main.async {
					viewController.dismiss(animated: true, completion: nil)
				}
			} else {
				viewController.toggleHide()
			}
		}
	}

	// MARK: - Biometric Permission
	/// Requests biometric permission by evaluating the device owner authentication policy.
	///
	/// - Parameter completion: A closure called on the main queue with `true` if biometric evaluation succeeds.
	func requestBiometricPermission(for reason: String, completion: @escaping @MainActor (Bool) -> Void) {
		let context = LAContext()
		var authError: NSError?

		if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
			Task {
				let success = (try? await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)) ?? false
				completion(success)
			}
		} else {
			if let error = authError {
				UIApplication.topViewController?.presentAlertController(
					title: L10n.errorAuthenticating,
					message: Self.evaluateAuthenticationPolicyMessage(forErrorCode: error.code)
				)
			}
			completion(false)
		}
	}

	// MARK: - Private Helpers
	/// Records the authentication deadline based on the current uptime and the user's configured interval.
	private func recordAuthenticationDeadline() {
		self.authenticationDeadline = Date.uptime() + UserSettings.authenticationInterval.rawValue
	}

	/// Presents the authentication screen on the given view controller, or the top view controller if `nil`.
	///
	/// - Parameter viewController: The view controller to present on. Defaults to `topViewController`.
	private func presentAuthenticationScreen(on viewController: UIViewController? = nil) {
		let presenter = viewController ?? UIApplication.topViewController

		guard
			let presenter = presenter,
			!(presenter is AuthenticationViewController)
		else { return }

		let authenticationViewController = AuthenticationViewController()
		authenticationViewController.modalPresentationStyle = .overFullScreen
		presenter.present(authenticationViewController, animated: true)
	}

	/// Evaluates local authentication using biometrics or device passcode.
	///
	/// - Parameters:
	///   - viewController: The `AuthenticationViewController` on which authentication is taking place.
	///   - completion: A closure called with `true` if the user authenticated successfully.
	private func evaluateLocalAuthentication(viewController: AuthenticationViewController, completion: @escaping @MainActor (Bool) -> Void) {
		let context = LAContext()
		var authError: NSError?

		let reasonString = L10n.biometricReasonContinue

		if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
			Task {
				let success = (try? await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonString)) ?? false
				completion(success)
			}
		} else {
			guard let error = authError else { return }

			UIApplication.topViewController?.presentAlertController(
				title: L10n.errorAuthenticating,
				message: Self.evaluateAuthenticationPolicyMessage(forErrorCode: error.code)
			)
		}
	}

	// MARK: - Error Messages
	/// Returns a string describing the evaluated Policy Fail Error for the given error code.
	///
	/// - Parameter errorCode: The `LAError` code to evaluate.
	///
	/// - Returns: A string describing the error.
	private static func evaluatePolicyFailErrorMessage(forErrorCode errorCode: Int) -> String {
		switch errorCode {
		case LAError.biometryNotAvailable.rawValue:
			return L10n.authErrorBiometryNotAvailable
		case LAError.biometryLockout.rawValue:
			return L10n.authErrorBiometryLockout
		case LAError.biometryNotEnrolled.rawValue:
			return L10n.authErrorBiometryNotEnrolled
		default:
			return L10n.authErrorUnknownCode
		}
	}

	/// Returns a string describing the evaluated Authentication Policy error for the given error code.
	///
	/// - Parameter errorCode: The `LAError` code to evaluate.
	///
	/// - Returns: A string describing the error.
	private static func evaluateAuthenticationPolicyMessage(forErrorCode errorCode: Int) -> String {
		switch errorCode {
		case LAError.authenticationFailed.rawValue:
			return L10n.authErrorAuthenticationFailed
		case LAError.appCancel.rawValue:
			return L10n.authErrorAppCancel
		case LAError.invalidContext.rawValue:
			return L10n.authErrorInvalidContext
		case LAError.notInteractive.rawValue:
			return L10n.authErrorNotInteractive
		case LAError.passcodeNotSet.rawValue:
			return L10n.authErrorPasscodeNotSet
		case LAError.systemCancel.rawValue:
			return L10n.authErrorSystemCancel
		case LAError.userCancel.rawValue:
			return L10n.authErrorUserCancel
		case LAError.userFallback.rawValue:
			return L10n.authErrorUserFallback
		default:
			return self.evaluatePolicyFailErrorMessage(forErrorCode: errorCode)
		}
	}
}
