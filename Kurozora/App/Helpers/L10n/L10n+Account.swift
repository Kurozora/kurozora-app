//
//  L10n+Account.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

extension L10n {
	// MARK: - Onboarding
	/// Strings shown during sign-up, sign-in, Sign in with Apple, and password reset flows.
	///
	/// - Tag: L10n-Onboarding
	struct Onboarding {
		/// The headline string for signing up.
		///
		/// - Tag: L10n-signUpHeadline
		static let signUpHeadline: String = String(
			localized: "onboarding.signUpHeadline",
			defaultValue: "New to Kurozora?",
			table: "Account",
			comment: "The headline string for signing up."
		)

		/// The subheadline string for signing up.
		///
		/// - Tag: L10n-signUpSubheadline
		static let signUpSubheadline: String = String(
			localized: "onboarding.signUpSubheadline",
			defaultValue: "Create an account and join the community.",
			table: "Account",
			comment: "The subheadline string for signing up."
		)

		/// The button string for signing up.
		///
		/// - Tag: L10n-signUpButton
		static let signUpButton: String = String(
			localized: "onboarding.signUpButton",
			defaultValue: "Join 🤗",
			table: "Account",
			comment: "The button string for signing up."
		)

		/// The headline string for sign up alert.
		///
		/// - Tag: L10n-signUpAlertHeadline
		static let signUpAlertHeadline: String = String(
			localized: "onboarding.signUpAlertHeadline",
			defaultValue: "Hooray!",
			table: "Account",
			comment: "The headline string for sign up alert."
		)

		/// The subheadline string for sign up alert.
		///
		/// - Tag: L10n-signUpAlertSubheadline
		static let signUpAlertSubheadline: String = String(
			localized: "onboarding.signUpAlertSubheadline",
			defaultValue: "Account created successfully! Please check your email for confirmation.",
			table: "Account",
			comment: "The subheadline string for sign up alert."
		)

		/// The headline string for sign up error alert.
		///
		/// - Tag: L10n-signUpErrorAlertHeadline
		static let signUpErrorAlertHeadline: String = String(
			localized: "onboarding.signUpErrorAlertHeadline",
			defaultValue: "Can't Sign Up 😔",
			table: "Account",
			comment: "The headline string for sign up alert."
		)

		/// The headline string for signing in.
		///
		/// - Tag: L10n-signInHeadline
		static let signInHeadline: String = String(
			localized: "onboarding.signInHeadline",
			defaultValue: "Kurozora Account",
			table: "Account",
			comment: "The headline string for signing in."
		)

		/// The subheadline string for signing in.
		///
		/// - Tag: L10n-signInSubheadline
		static let signInSubheadline: String = String(
			localized: "onboarding.signInSubheadline",
			defaultValue: "Sign in with your Kurozora Account to use the library and other Kurozora services.",
			table: "Account",
			comment: "The subheadline string for signing in."
		)

		/// The button string for signing in.
		///
		/// - Tag: L10n-signInButton
		static let signInButton: String = String(
			localized: "onboarding.signInButton",
			defaultValue: "Open sesame 👐",
			table: "Account",
			comment: "The button string for signing in."
		)

		/// The headline string for Sign in with Apple.
		///
		/// - Tag: L10n-siwaHeadline
		static let siwaHeadline: String = String(
			localized: "onboarding.siwaHeadline",
			defaultValue: "Setup Account",
			table: "Account",
			comment: "The headline string for Sign in with Apple."
		)

		/// The subheadline string for Sign in with Apple.
		///
		/// - Tag: L10n-siwaSubheadline
		static let siwaSubheadline: String = String(
			localized: "onboarding.siwaSubheadline",
			defaultValue: "Finish setting up your account and join the community.",
			table: "Account",
			comment: ""
		)

		/// The button string for sign in with Apple.
		///
		/// - Tag: L10n-siwaButton
		static let siwaButton: String = String(
			localized: "onboarding.siwaButton",
			defaultValue: "Join 🤗",
			table: "Account",
			comment: "The button string for sign in with Apple."
		)

		/// The headline string for resetting password.
		///
		/// - Tag: L10n-forgotPasswordHeadline
		static let forgotPasswordHeadline: String = String(
			localized: "onboarding.forgotPasswordHeadline",
			defaultValue: "Forgot Password?",
			table: "Account",
			comment: "The headline string for resetting password."
		)

		/// The subheadline string for resetting password.
		///
		/// - Tag: L10n-forgotPasswordSubheadline
		static let forgotPasswordSubheadline: String = String(
			localized: "onboarding.forgotPasswordSubheadline",
			defaultValue: "Enter your Kurozora Account to continue.",
			table: "Account",
			comment: "The subheadline string for resetting password."
		)

		/// The button string for resetting password.
		///
		/// - Tag: L10n-forgotPasswordButton
		static let forgotPasswordButton: String = String(
			localized: "onboarding.forgotPasswordButton",
			defaultValue: "Send ✨",
			table: "Account",
			comment: "The button string for resetting password."
		)

		/// The headline string for resetting password alert.
		///
		/// - Tag: L10n-forgotPasswordAlertHeadline
		static let forgotPasswordAlertHeadline: String = String(
			localized: "onboarding.forgotPasswordAlertHeadline",
			defaultValue: "Success!",
			table: "Account",
			comment: "The headline string for resetting password alert."
		)

		/// The subheadline string for resetting password alert.
		///
		/// - Tag: L10n-forgotPasswordAlertSubheadline
		static let forgotPasswordAlertSubheadline: String = String(
			localized: "onboarding.forgotPasswordAlertSubheadline",
			defaultValue: "If an account exists with this Kurozora Account, you should receive an email with your reset link shortly.",
			table: "Account",
			comment: "The subheadline string for resetting password alert."
		)

		/// The headline string for resetting password error alert.
		///
		/// - Tag: L10n-forgotPasswordErrorAlertHeadline
		static let forgotPasswordErrorAlertHeadline: String = String(
			localized: "onboarding.forgotPasswordErrorAlertHeadline",
			defaultValue: "Errr...",
			table: "Account",
			comment: "The headline string for resetting password alert."
		)

		/// The subheadline string for resetting password error alert.
		///
		/// - Tag: L10n-forgotPasswordErrorAlertSubheadline
		static let forgotPasswordErrorAlertSubheadline: String = String(
			localized: "onboarding.forgotPasswordErrorAlertSubheadline",
			defaultValue: "Please type a valid Kurozora Account 😣",
			table: "Account",
			comment: "The subheadline string for resetting password alert."
		)

		/// The button string for the forgot password option on the sign in screen.
		///
		/// - Tag: L10n-forgotPasswordOptionsButton
		static let forgotPasswordOptionsButton: String = String(
			localized: "onboarding.forgotPasswordOptionsButton",
			defaultValue: "Forgot your password? Let's reset 📧",
			table: "Account",
			comment: "The button string for the forgot password option on the sign in screen."
		)

		/// The separator string between onboarding options.
		///
		/// - Tag: L10n-onboardingOrSeparator
		static let onboardingOrSeparator: String = String(
			localized: "onboarding.onboardingOrSeparator",
			defaultValue: "━━━━━━ or ━━━━━━",
			table: "Account",
			comment: "The separator string between onboarding options."
		)

		/// The button string for the register option on the sign in screen.
		///
		/// - Tag: L10n-registerOptionsButton
		static let registerOptionsButton: String = String(
			localized: "onboarding.registerOptionsButton",
			defaultValue: "New to Kurozora? Join us 🔥",
			table: "Account",
			comment: "The button string for the register option on the sign in screen."
		)

		/// The description string shown below onboarding options.
		///
		/// - Tag: L10n-onboardingDescription
		static let onboardingDescription: String = String(
			localized: "onboarding.onboardingDescription",
			defaultValue: "Your Kurozora Account lets you access your library, favorites, reminders, reviews, and more on your devices, automatically.",
			table: "Account",
			comment: "The description string shown below onboarding options."
		)

		/// Title shown on the Apple sign-in screen.
		static let signInWithAppleTitle: String = String(
			localized: "onboarding.signInWithAppleTitle",
			defaultValue: "Sign in with Apple",
			table: "Account",
			comment: "Title for the button or screen that allows the user to sign in with Apple."
		)

		/// Title shown when sign-in fails.
		static let signInErrorTitle: String = String(
			localized: "onboarding.signInErrorTitle",
			defaultValue: "Can't Sign In 😔",
			table: "Account",
			comment: "Alert title shown when the user cannot sign in."
		)

		/// Generic fallback error message for sign-in failures.
		static let genericSignInErrorMessage: String = String(
			localized: "onboarding.genericSignInErrorMessage",
			defaultValue: "An error occurred while trying to sign in. Please try again.",
			table: "Account",
			comment: "Generic error message shown when sign-in fails for an unknown reason."
		)

		/// Headline shown on the two-factor challenge screen.
		///
		/// - Tag: L10n-twoFactorHeadline
		static let twoFactorHeadline: String = String(
			localized: "onboarding.twoFactorHeadline",
			defaultValue: "Two-Factor Authentication",
			table: "Account",
			comment: "Headline shown on the two-factor authentication challenge screen."
		)

		/// Subheadline shown on the two-factor challenge screen when prompting for a TOTP code.
		///
		/// - Tag: L10n-twoFactorSubheadlineTOTP
		static let twoFactorSubheadlineTOTP: String = String(
			localized: "onboarding.twoFactorSubheadlineTOTP",
			defaultValue: "Enter the 6-digit code from your authenticator app.",
			table: "Account",
			comment: "Subheadline shown when the two-factor challenge expects a 6-digit TOTP code."
		)

		/// Subheadline shown on the two-factor challenge screen when prompting for a recovery code.
		///
		/// - Tag: L10n-twoFactorSubheadlineRecovery
		static let twoFactorSubheadlineRecovery: String = String(
			localized: "onboarding.twoFactorSubheadlineRecovery",
			defaultValue: "Enter one of your recovery codes.",
			table: "Account",
			comment: "Subheadline shown when the two-factor challenge expects a recovery code."
		)

		/// Placeholder shown in the TOTP entry field.
		///
		/// - Tag: L10n-twoFactorTOTPPlaceholder
		static let twoFactorTOTPPlaceholder: String = String(
			localized: "onboarding.twoFactorTOTPPlaceholder",
			defaultValue: "000 000",
			table: "Account",
			comment: "Placeholder shown in the TOTP entry field of the two-factor challenge screen."
		)

		/// Placeholder shown in the recovery code entry field.
		///
		/// - Tag: L10n-twoFactorRecoveryPlaceholder
		static let twoFactorRecoveryPlaceholder: String = String(
			localized: "onboarding.twoFactorRecoveryPlaceholder",
			defaultValue: "XXXXXXXXXX-XXXXXXXXXX",
			table: "Account",
			comment: "Placeholder showing the format of a recovery code on the two-factor challenge screen."
		)

		/// Toggle button title to switch from TOTP entry to recovery code entry.
		///
		/// - Tag: L10n-twoFactorUseRecoveryCode
		static let twoFactorUseRecoveryCode: String = String(
			localized: "onboarding.twoFactorUseRecoveryCode",
			defaultValue: "Use a recovery code instead",
			table: "Account",
			comment: "Toggle button title that switches the two-factor challenge screen from TOTP to recovery code entry."
		)

		/// Toggle button title to switch from recovery code entry to TOTP entry.
		///
		/// - Tag: L10n-twoFactorUseTOTP
		static let twoFactorUseTOTP: String = String(
			localized: "onboarding.twoFactorUseTOTP",
			defaultValue: "Use authenticator code instead",
			table: "Account",
			comment: "Toggle button title that switches the two-factor challenge screen from recovery code to TOTP entry."
		)

		/// Title for the verify button on the two-factor challenge screen.
		///
		/// - Tag: L10n-twoFactorVerifyButton
		static let twoFactorVerifyButton: String = String(
			localized: "onboarding.twoFactorVerifyButton",
			defaultValue: "Verify ✅",
			table: "Account",
			comment: "Title for the navigation bar verify button on the two-factor challenge screen."
		)

		/// Alert title shown when the two-factor challenge token has expired.
		///
		/// - Tag: L10n-twoFactorExpiredTitle
		static let twoFactorExpiredTitle: String = String(
			localized: "onboarding.twoFactorExpiredTitle",
			defaultValue: "Session Expired",
			table: "Account",
			comment: "Alert title shown when the two-factor authentication challenge expires."
		)

		/// Alert message shown when the two-factor challenge token has expired.
		///
		/// - Tag: L10n-twoFactorExpiredMessage
		static let twoFactorExpiredMessage: String = String(
			localized: "onboarding.twoFactorExpiredMessage",
			defaultValue: "Your verification session has expired. Please sign in again.",
			table: "Account",
			comment: "Alert message shown when the two-factor authentication challenge expires."
		)

		/// Inline error shown when the entered TOTP or recovery code is wrong.
		///
		/// - Tag: L10n-twoFactorInvalidCode
		static let twoFactorInvalidCode: String = String(
			localized: "onboarding.twoFactorInvalidCode",
			defaultValue: "Incorrect code. Please try again.",
			table: "Account",
			comment: "Inline error shown beneath the input field when the two-factor code is incorrect."
		)

		/// Inline error shown when the recovery code does not match the expected format.
		///
		/// - Tag: L10n-twoFactorInvalidFormat
		static let twoFactorInvalidFormat: String = String(
			localized: "onboarding.twoFactorInvalidFormat",
			defaultValue: "Recovery codes use the format XXXXXXXXXX-XXXXXXXXXX.",
			table: "Account",
			comment: "Inline error shown when the recovery code is not in the expected format."
		)

		/// Inline error shown when the network request fails on the two-factor screen.
		///
		/// - Tag: L10n-twoFactorNetworkError
		static let twoFactorNetworkError: String = String(
			localized: "onboarding.twoFactorNetworkError",
			defaultValue: "Network error. Check your connection and try again.",
			table: "Account",
			comment: "Inline error shown on the two-factor screen when the verification request fails due to a network error."
		)

		/// Error message when Apple authentication fails.
		static let appleAuthenticationFailedMessage: String = String(
			localized: "onboarding.appleAuthenticationFailedMessage",
			defaultValue: "Authentication failed by Apple. Please try again.",
			table: "Account",
			comment: "Error message shown when Apple authentication fails."
		)

		/// Error message when Apple returns invalid response.
		static let appleInvalidResponseMessage: String = String(
			localized: "onboarding.appleInvalidResponseMessage",
			defaultValue: "The app received an invalid response from Apple. Please try again.",
			table: "Account",
			comment: "Error message shown when Apple returns an invalid authentication response."
		)

		/// Error message when Apple authentication is not handled.
		static let appleAuthenticationNotHandledMessage: String = String(
			localized: "onboarding.appleAuthenticationNotHandledMessage",
			defaultValue: "An error occurred and the authentication was not handled by Apple. Please try again.",
			table: "Account",
			comment: "Error message shown when Apple authentication was not handled properly."
		)
	}

	// MARK: - Redeem
	/// The headline string for the Redeem view.
	///
	/// - Tag: L10n-redeemHeadline
	static let redeemHeadline: String = String(
		localized: "Redeem your code using the camera on your device.",
		table: "Account",
		comment: "The headline string for the Redeem view."
	)
	/// The subheadline string for the Redeem view.
	///
	/// - Tag: L10n-redeemSubheadline
	static let redeemSubheadline: String = String(
		localized: "Found a Kurozora code in the wild? This is the place to redeem it!",
		table: "Account",
		comment: "The subheadline string for the Redeem view."
	)
	/// The footer string for the Redeem view.
	///
	/// - Tag: L10n-redeemFooter
	static let redeemFooter: String = String(
		localized: "Redeeming a code will unlock special badges and achievements, as well as increase your reputation points. Please keep in mind Kurozora codes are redeemable only once per account and expire after one use.",
		table: "Account",
		comment: "The footer string for the Redeem view."
	)
	/// The headline string for the redeem error pop-up.
	///
	/// - Tag: L10n-redeemErrorHeadline
	static let redeemErrorHeadline: String = String(
		localized: "Error Redeeming Code",
		table: "Account",
		comment: "The headline string for the redeem error pop-up."
	)
	/// The subheadline string for the redeem error pop-up.
	///
	/// - Tag: L10n-redeemErrorSubheadline
	static let redeemErrorSubheadline: String = String(
		localized: "The code entered is not valid.",
		table: "Account",
		comment: "The subheadline string for the redeem error pop-up."
	)
	/// The headline string for the redeem processing pop-up.
	///
	/// - Tag: L10n-redeemProcessingHeadline
	static let redeemProcessingHeadline: String = String(
		localized: "Processing redeem code.",
		table: "Account",
		comment: "The headline string for the redeem processing pop-up."
	)
	/// The headline string for the redeem success pop-up.
	///
	/// - Tag: L10n-redeemSuccessHeadline
	static let redeemSuccessHeadline: String = String(
		localized: "Zoop, badoop, fruitloop!",
		table: "Account",
		comment: "The headline string for the redeem success pop-up."
	)
	/// The subheadline string for the redeem success pop-up.
	///
	/// - Tag: L10n-redeemSuccessSubheadline
	static let redeemSuccessSubheadline: String = String(
		localized: "%d was successfully redeemed 🤩",
		table: "Account",
		comment: "The subheadline string for the redeem success pop-up."
	)

	// MARK: - SiwA
	/// The headline string for the Sign in with Apple view.
	///
	/// - Tag: L10n-signInWithAppleHeadline
	static let signInWithAppleHeadline: String = String(
		localized: "Start using Sign in with Apple",
		table: "Account",
		comment: "The headline string for the Sign in with Apple view."
	)
	/// The subheadline string for the Sign in with Apple view.
	///
	/// - Tag: L10n-signInWithAppleSubheadline
	static let signInWithAppleSubheadline: String = String(
		localized: "Sign in with Apple is the fast, easy way for you to sign in to Kurozora using the Apple ID you already have.",
		table: "Account",
		comment: "The subheadline string for the Sign in with Apple view."
	)
	/// The footer string for the Sign in with Apple view.
	///
	/// - Tag: L10n-signInWithAppleFooter
	static let signInWithAppleFooter: String = String(
		localized: "Kurozora offers Sign in with Apple for users who want the extra peace of mind when it comes to security and privacy. Sign in with Apple is a convenient way to sign in to apps and sites while having more control over the information you share. Kurozora is restricted to asking only for your name and email address, and Apple won’t track your app activity or build a profile of you.",
		table: "Account",
		comment: "The footer string for the Sign in with Apple view."
	)

	// MARK: - In-App Purchases
	/// The message string for the product not found.
	///
	/// - Tag: L10n-productIDsNotSet
	static let productIDsNotSet: String = String(
		localized: "Product ids not set, call setProductIDs method!",
		table: "Account",
		comment: "The message string for the product not found."
	)
	/// The message string for IAP is disabled.
	///
	/// - Tag: L10n-iapDisabled
	static let iapDisabled: String = String(
		localized: "You are not authorized to make payments. In-App Purchases may be restricted on your device.",
		table: "Account",
		comment: "The message string for IAP is disabled."
	)
	/// The message string for restoring IAP has failed.
	///
	/// - Tag: L10n-iapRestoreFailed
	static let iapRestoreFailed: String = String(
		localized: "There are no restorable purchases.\nOnly previously bought non-consumable products and auto-renewable subscriptions can be restored.",
		table: "Account",
		comment: "The message string for restoring IAP has failed."
	)
	/// The message string for restoring IAP has succeeded.
	///
	/// - Tag: L10n-iapRestoreSucceeded
	static let iapRestoreSucceeded: String = String(
		localized: "All purchases have been restored.\nPlease remember that only previously bought non-consumable products and auto-renewable subscriptions can be restored.",
		table: "Account",
		comment: "The message string for restoring IAP has succeeded."
	)

	// MARK: - Subscription
	/// The footer string for the Subscription view.
	///
	/// - Tag: L10n-subscriptionFooter
	static let subscriptionFooter: String = String(
		localized: "Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.",
		table: "Account",
		comment: "The footer string for the Subscription view."
	)
	/// The string for the 'manage subscriptions' settings option.
	///
	/// - Tag: L10n-manageSubscriptions
	static let manageSubscriptions: String = String(
		localized: "Manage Subscriptions",
		table: "Account",
		comment: "The string for the 'manage subscriptions' settings option."
	)

	// MARK: - Tip Jar
	/// The footer string for the Tip Jar view.
	///
	/// - Tag: L10n-tipJarFooter
	static let tipJarFooter: String = String(
		localized: "Payment will be charged to your Apple ID account at the confirmation of purchase. Unlike Kurozora+ subscription, tips are a one time purchase. Your account will be charged only once every time you tip.",
		table: "Account",
		comment: "The footer string for the Tip Jar view."
	)

	// MARK: - Request Refund
	/// The description string for the Request Refund view.
	///
	/// - Tag: L10n-requestRefundHeaderDescription
	static let requestRefundHeaderDescription: String = String(
		localized: "requestRefund.header.description",
		defaultValue: "Review your recent purchases and ask Apple to refund any you no longer want. Apple decides each request, so refunds aren't guaranteed.",
		table: "Account",
		comment: "The description string for the Request Refund view."
	)
	/// The 'purchased' section header on the Request Refund view.
	///
	/// - Tag: L10n-purchasedSectionHeader
	static let purchasedSectionHeader: String = String(
		localized: "purchased.section",
		defaultValue: "Purchased",
		table: "Account",
		comment: "The 'purchased' section header on the Request Refund view."
	)
	/// The 'refunded' section header on the Request Refund view.
	///
	/// - Tag: L10n-refundedSectionHeader
	static let refundedSectionHeader: String = String(
		localized: "refunded.section",
		defaultValue: "Refunded",
		table: "Account",
		comment: "The 'refunded' section header on the Request Refund view."
	)
	/// The empty-state title for the Request Refund view.
	///
	/// - Tag: L10n-refundEmptyTitle
	static let refundEmptyTitle: String = String(
		localized: "refund.empty.title",
		defaultValue: "No Purchases",
		table: "Account",
		comment: "The empty-state title for the Request Refund view."
	)
	/// The empty-state detail for the Request Refund view.
	///
	/// - Tag: L10n-refundEmptyDetail
	static let refundEmptyDetail: String = String(
		localized: "refund.empty.detail",
		defaultValue: "There are no purchases on this account that can be refunded.",
		table: "Account",
		comment: "The empty-state detail for the Request Refund view."
	)
	/// The 'Purchased <date>' subtitle for a consumable transaction.
	///
	/// - Tag: L10n-purchasedOn
	static func purchasedOn(_ date: String) -> String {
		return String(
			localized: "refund.purchasedOn",
			defaultValue: "Purchased \(date)",
			table: "Account",
			comment: "The 'Purchased <date>' subtitle for a consumable transaction."
		)
	}
	/// The 'Subscribed <date>' subtitle for a subscription transaction.
	///
	/// - Tag: L10n-subscribedOn
	static func subscribedOn(_ date: String) -> String {
		return String(
			localized: "refund.subscribedOn",
			defaultValue: "Subscribed \(date)",
			table: "Account",
			comment: "The 'Subscribed <date>' subtitle for a subscription transaction."
		)
	}
	/// The 'Refunded <date>' subtitle for a revoked transaction.
	///
	/// - Tag: L10n-refundedOn
	static func refundedOn(_ date: String) -> String {
		return String(
			localized: "refund.refundedOn",
			defaultValue: "Refunded \(date)",
			table: "Account",
			comment: "The 'Refunded <date>' subtitle for a revoked transaction."
		)
	}
	// MARK: - Privacy Policy
	/// The string for the phrase 'Kurozora & Privacy'.
	///
	/// - Tag: L10n-kurozoraAndPrivacy
	static let kurozoraAndPrivacy: String = String(
		localized: "Kurozora & Privacy",
		table: "Account",
		comment: "The string for the phrase 'Kurozora & Privacy'."
	)
	/// The string for the word terms of use.
	///
	/// - Tag: L10n-termsOfUse
	static let termsOfUse: String = String(
		localized: "Terms of Use",
		table: "Account",
		comment: "The string for the word terms of use."
	)
	/// The string for the word privacy policy.
	///
	/// - Tag: L10n-privacyPolicy
	static let privacyPolicy: String = String(
		localized: "Privacy Policy",
		table: "Account",
		comment: "The string for the word privacy policy."
	)
	/// The footer string to visit privacy policy.
	///
	/// - Tag: L10n-forMoreInfo
	static let forMoreInfo: String = String(
		localized: "For more information, please visit our ",
		table: "Account",
		comment: "The footer string to visit privacy policy."
	)
	/// The attributed footer string linking to the privacy policy, styled via the active theme.
	///
	/// - Tag: L10n-visitPrivacyPolicy
	static var visitPrivacyPolicy: ThemeAttributedStringPicker = {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		return ThemeAttributedStringPicker {
			let attributedString = NSMutableAttributedString(string: L10n.forMoreInfo, attributes: [.foregroundColor: KThemePicker.subTextColor.colorValue, .paragraphStyle: paragraphStyle])
			attributedString.append(NSAttributedString(string: L10n.privacyPolicy, attributes: [.foregroundColor: KThemePicker.tintColor.colorValue, .paragraphStyle: paragraphStyle]))
			return attributedString
		}
	}()

	/// The string for the phrase 'Open in Settings app'.
	///
	/// - Tag: L10n-openInSettingsApp
	static let openInSettingsApp: String = String(
		localized: "Open in Settings app",
		table: "Account",
		comment: "The string for the phrase 'Open in Settings app'."
	)

	// MARK: - Authentication
	/// The string for 'Require Authentication' settings.
	///
	/// - Tag: L10n-requireAuthentication
	static let requireAuthentication: String = String(
		localized: "Require Authentication",
		table: "Account",
		comment: "The string for 'Require Authentication' settings."
	)
	/// The string for requiring authentication immediately.
	///
	/// - Tag: L10n-immediateAuthenticationRequired
	static let immediateAuthenticationRequired: String = String(
		localized: "Authentication is required every time you return to the app.",
		table: "Account",
		comment: "The string for requiring authentication immediately."
	)
	/// The string for the 'Authentication Interval' settings description.
	///
	/// - Tag: L10n-authenticationInterval
	static func authenticationInterval(_ interval: String) -> String {
		return String(
			localized: "Authentication is required if the app remains in the background for more than \(interval).",
			table: "Account",
			comment: "The string for the 'Authentication Interval' settings description."
		)
	}

	/// The string for authenticating immediately.
	///
	/// - Tag: L10n-immediately
	static let immediately: String = String(
		localized: "Immediately",
		table: "Account",
		comment: "The string for authenticating immediately."
	)
	/// The string for authenticating after 30 seconds.
	///
	/// - Tag: L10n-thirtySeconds
	static let thirtySeconds: String = String(
		localized: "30 Seconds",
		table: "Account",
		comment: "The string for authenticating after 30 seconds."
	)
	/// The string for authenticating after 1 minute.
	///
	/// - Tag: L10n-oneMinute
	static let oneMinute: String = String(
		localized: "1 Minute",
		table: "Account",
		comment: "The string for authenticating after 1 minute."
	)
	/// The string for authenticating after 2 minutes.
	///
	/// - Tag: L10n-twoMinutes
	static let twoMinutes: String = String(
		localized: "2 Minutes",
		table: "Account",
		comment: "The string for authenticating after 2 minutes."
	)
	/// The string for authenticating after 3 minutes.
	///
	/// - Tag: L10n-threeMinutes
	static let threeMinutes: String = String(
		localized: "3 Minutes",
		table: "Account",
		comment: "The string for authenticating after 3 minutes."
	)
	/// The string for authenticating after 4 minutes.
	///
	/// - Tag: L10n-fourMinutes
	static let fourMinutes: String = String(
		localized: "4 Minutes",
		table: "Account",
		comment: "The string for authenticating after 4 minutes."
	)
	/// The string for authenticating after 5 minutes.
	///
	/// - Tag: L10n-fiveMinutes
	static let fiveMinutes: String = String(
		localized: "5 Minutes",
		table: "Account",
		comment: "The string for authenticating after 5 minutes."
	)

	// MARK: - Unlock
	/// The unlock button title for the biometric-authentication screen.
	///
	/// - Tag: L10n-unlockKurozora
	static let unlockKurozora: String = String(
		localized: "Unlock Kurozora",
		table: "Account",
		comment: "The unlock button title for the biometric-authentication screen."
	)

	// MARK: - Data Management
	/// The tappable legal footer link shown on the onboarding footer cell.
	///
	/// - Tag: L10n-seeHowDataIsManaged
	static let seeHowDataIsManaged: String = String(
		localized: "See how your data is managed...",
		table: "Account",
		comment: "The tappable legal footer link shown on the onboarding footer cell."
	)

	// MARK: - Sessions
	/// Pull-to-refresh title for the active sessions list.
	///
	/// - Tag: L10n-pullToRefreshSessions
	static let pullToRefreshSessions: String = String(
		localized: "Pull to refresh your sessions!",
		table: "Account",
		comment: "Pull-to-refresh title for the active sessions list."
	)
	/// Refresh-in-progress title for the active sessions list.
	///
	/// - Tag: L10n-refreshingSessions
	static let refreshingSessions: String = String(
		localized: "Refreshing sessions...",
		table: "Account",
		comment: "Refresh-in-progress title for the active sessions list."
	)
	/// The string for the 'current session' section.
	///
	/// - Tag: L10n-currentSession
	static let currentSession: String = String(
		localized: "Current Session",
		table: "Account",
		comment: "The string for the 'current session' section."
	)
	/// The string for the 'other session' section.
	///
	/// - Tag: L10n-otherSessions
	static let otherSessions: String = String(
		localized: "Other Sessions",
		table: "Account",
		comment: "The string for the 'other sessions' section."
	)
	/// The string for 'this device'.
	///
	/// - Tag: L10n-thisDevice
	static let thisDevice: String = String(
		localized: "This device",
		table: "Account",
		comment: "The string for 'this device'."
	)
}
