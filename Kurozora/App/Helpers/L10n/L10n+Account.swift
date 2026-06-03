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
			defaultValue: "Errr…",
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

	// MARK: - Product Features
	/// The 'stylish app icons' product feature title.
	///
	/// - Tag: L10n-featureAppIconsTitle
	static let featureAppIconsTitle: String = String(
		localized: "Stylish App Icons",
		table: "Account",
		comment: "The 'stylish app icons' product feature title."
	)
	/// The 'stylish app icons' product feature description.
	///
	/// - Tag: L10n-featureAppIconsDescription
	static let featureAppIconsDescription: String = String(
		localized: "Make your home screen stand out with premium and limited time app icons.",
		table: "Account",
		comment: "The 'stylish app icons' product feature description."
	)
	/// The 'startup chimes' product feature title.
	///
	/// - Tag: L10n-featureStartupChimesTitle
	static let featureStartupChimesTitle: String = String(
		localized: "Startup Chimes",
		table: "Account",
		comment: "The 'startup chimes' product feature title."
	)
	/// The 'startup chimes' product feature description.
	///
	/// - Tag: L10n-featureStartupChimesDescription
	static let featureStartupChimesDescription: String = String(
		localized: "Immerse yourself in the world of anime from the very start with serene chimes and iconic anime sounds.",
		table: "Account",
		comment: "The 'startup chimes' product feature description."
	)
	/// The 'get animated' product feature title.
	///
	/// - Tag: L10n-featureGetAnimatedTitle
	static let featureGetAnimatedTitle: String = String(
		localized: "Get Animated",
		table: "Account",
		comment: "The 'get animated' product feature title."
	)
	/// The 'get animated' product feature description.
	///
	/// - Tag: L10n-featureGetAnimatedDescription
	static let featureGetAnimatedDescription: String = String(
		localized: "Upgrade your profile with a gif image that captures your unique style.",
		table: "Account",
		comment: "The 'get animated' product feature description."
	)
	/// The 'change your identity' product feature title.
	///
	/// - Tag: L10n-featureChangeIdentityTitle
	static let featureChangeIdentityTitle: String = String(
		localized: "Change Your Identity",
		table: "Account",
		comment: "The 'change your identity' product feature title."
	)
	/// The 'change your identity' product feature description.
	///
	/// - Tag: L10n-featureChangeIdentityDescription
	static let featureChangeIdentityDescription: String = String(
		localized: "Switch things up every now an then with a fresh username that truly represents you.",
		table: "Account",
		comment: "The 'change your identity' product feature description."
	)
	/// The 'support the community' product feature title.
	///
	/// - Tag: L10n-featureSupportCommunityTitle
	static let featureSupportCommunityTitle: String = String(
		localized: "Support the Community",
		table: "Account",
		comment: "The 'support the community' product feature title."
	)
	/// The 'support the community' product feature description.
	///
	/// - Tag: L10n-featureSupportCommunityDescription
	static let featureSupportCommunityDescription: String = String(
		localized: "Your contribution helps with maintaining the servers, paying for software licenses, and fund events and activities.",
		table: "Account",
		comment: "The 'support the community' product feature description."
	)
	/// The product feature title for an extended feed-message character limit.
	///
	/// - Parameter count: The maximum number of characters.
	///
	/// - Tag: L10n-featureUpToCharacters
	static func featureUpToCharacters(_ count: Int) -> String {
		String(
			localized: "Up to \(count) Characters",
			table: "Account",
			comment: "The product feature title for an extended feed-message character limit."
		)
	}
	/// The 'unified anime linking' product feature title.
	///
	/// - Tag: L10n-featureUnifiedLinkingTitle
	static let featureUnifiedLinkingTitle: String = String(
		localized: "Unified Anime Linking",
		table: "Account",
		comment: "The 'unified anime linking' product feature title."
	)
	/// The 'unified anime linking' product feature description.
	///
	/// - Tag: L10n-featureUnifiedLinkingDescription
	static let featureUnifiedLinkingDescription: String = String(
		localized: "Seamlessly transition from other services to Kurozora. Add 'kurozora.app' to any URL and let us bring all your anime data in one place.",
		table: "Account",
		comment: "The 'unified anime linking' product feature description."
	)
	/// The 'integrate with calendar' product feature title.
	///
	/// - Tag: L10n-featureCalendarTitle
	static let featureCalendarTitle: String = String(
		localized: "Integrate with Calendar",
		table: "Account",
		comment: "The 'integrate with calendar' product feature title."
	)
	/// The 'integrate with calendar' product feature description.
	///
	/// - Tag: L10n-featureCalendarDescription
	static let featureCalendarDescription: String = String(
		localized: "Integrate your anime schedule into your calendar. Never miss an episode again with reminders for new airings.",
		table: "Account",
		comment: "The 'integrate with calendar' product feature description."
	)
	/// The 'dynamic themes' product feature title.
	///
	/// - Tag: L10n-featureDynamicThemesTitle
	static let featureDynamicThemesTitle: String = String(
		localized: "Dynamic Themes",
		table: "Account",
		comment: "The 'dynamic themes' product feature title."
	)
	/// The 'dynamic themes' product feature description.
	///
	/// - Tag: L10n-featureDynamicThemesDescription
	static let featureDynamicThemesDescription: String = String(
		localized: "Choose from a range of themes to create a look that reflects your personality and style.",
		table: "Account",
		comment: "The 'dynamic themes' product feature description."
	)
	/// The subscription feed-message character-limit product feature description.
	///
	/// - Tag: L10n-featureSubscriptionCharacterLimitDescription
	static let featureSubscriptionCharacterLimitDescription: String = String(
		localized: "Dive even deeper into discussions with an extended 1000 character limit for your feed messages.",
		table: "Account",
		comment: "The subscription feed-message character-limit product feature description."
	)
	/// The 'unlock subscriber badge' product feature title.
	///
	/// - Tag: L10n-featureSubscriberBadgeTitle
	static let featureSubscriberBadgeTitle: String = String(
		localized: "Unlock Subscriber Badge",
		table: "Account",
		comment: "The 'unlock subscriber badge' product feature title."
	)
	/// The 'unlock subscriber badge' product feature description.
	///
	/// - Tag: L10n-featureSubscriberBadgeDescription
	static let featureSubscriberBadgeDescription: String = String(
		localized: "Stand out in the community with an exclusive subscription badge that evolves over time as you continue to support Kurozora!",
		table: "Account",
		comment: "The 'unlock subscriber badge' product feature description."
	)
	/// The tip jar feed-message character-limit product feature description.
	///
	/// - Tag: L10n-featureTipJarCharacterLimitDescription
	static let featureTipJarCharacterLimitDescription: String = String(
		localized: "Have more to say? Express yourself fully with a 500 character limit for your feed messages.",
		table: "Account",
		comment: "The tip jar feed-message character-limit product feature description."
	)
	/// The 'unlock pro badge' product feature title.
	///
	/// - Tag: L10n-featureProBadgeTitle
	static let featureProBadgeTitle: String = String(
		localized: "Unlock Pro Badge",
		table: "Account",
		comment: "The 'unlock pro badge' product feature title."
	)
	/// The 'unlock pro badge' product feature description.
	///
	/// - Tag: L10n-featureProBadgeDescription
	static let featureProBadgeDescription: String = String(
		localized: "Elevate your status in the Kurozora community with the prestigious Pro badge next to your username, and show your support for Kurozora.",
		table: "Account",
		comment: "The 'unlock pro badge' product feature description."
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
		localized: "See how your data is managed…",
		table: "Account",
		comment: "The tappable legal footer link shown on the onboarding footer cell."
	)

	// MARK: - Sessions
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

	// MARK: - Account Screen
	/// The title of the account settings screen.
	///
	/// - Tag: L10n-kurozoraAccount
	static let kurozoraAccount: String = String(
		localized: "Kurozora Account",
		table: "Account",
		comment: "The title of the account settings screen."
	)
	/// The title of the active sessions screen.
	///
	/// - Tag: L10n-activeSessions
	static let activeSessions: String = String(
		localized: "Active Sessions",
		table: "Account",
		comment: "The title of the active sessions screen."
	)

	// MARK: - Edit Profile
	/// The section label above the username field on the edit profile screen.
	///
	/// - Tag: L10n-editProfileUsernameLabel
	static let editProfileUsernameLabel: String = String(
		localized: "Username",
		table: "Account",
		comment: "The section label above the username field on the edit profile screen."
	)
	/// The section label above the display name field on the edit profile screen.
	///
	/// - Tag: L10n-editProfileDisplayNameLabel
	static let editProfileDisplayNameLabel: String = String(
		localized: "Display Name",
		table: "Account",
		comment: "The section label above the display name field on the edit profile screen."
	)
	/// The section label above the bio field on the edit profile screen.
	///
	/// - Tag: L10n-editProfileBioLabel
	static let editProfileBioLabel: String = String(
		localized: "About Me",
		table: "Account",
		comment: "The section label above the bio field on the edit profile screen."
	)
	/// The alert title shown when updating the profile fails.
	///
	/// - Tag: L10n-editProfileErrorTitle
	static let editProfileErrorTitle: String = String(
		localized: "Error Updating Profile",
		table: "Account",
		comment: "The alert title shown when updating the profile fails."
	)

	// MARK: - Profile Image Selection
	/// The camera-menu action that captures a new photo.
	///
	/// - Tag: L10n-pickerTakePhoto
	static let pickerTakePhoto: String = String(
		localized: "Take Photo",
		table: "Account",
		comment: "The camera-menu action that captures a new photo."
	)
	/// The camera-menu action that picks a photo from the library.
	///
	/// - Tag: L10n-pickerPhotoLibrary
	static let pickerPhotoLibrary: String = String(
		localized: "Photo Library",
		table: "Account",
		comment: "The camera-menu action that picks a photo from the library."
	)
	/// The empty-state title prompting the user to grant photo access.
	///
	/// - Tag: L10n-photoAccessTitle
	static let photoAccessTitle: String = String(
		localized: "Access Your Photos",
		table: "Account",
		comment: "The empty-state title prompting the user to grant photo access."
	)
	/// The empty-state detail prompting the user to grant photo access.
	///
	/// - Tag: L10n-photoAccessDetail
	static let photoAccessDetail: String = String(
		localized: "Allow access to your photo library to choose a profile picture.",
		table: "Account",
		comment: "The empty-state detail prompting the user to grant photo access."
	)
	/// The button that requests photo library access.
	///
	/// - Tag: L10n-photoAccessAllowButton
	static let photoAccessAllowButton: String = String(
		localized: "Allow Access",
		table: "Account",
		comment: "The button that requests photo library access."
	)
	/// The empty-state title shown when photo access has been denied.
	///
	/// - Tag: L10n-photoAccessDeniedTitle
	static let photoAccessDeniedTitle: String = String(
		localized: "Photo Access Denied",
		table: "Account",
		comment: "The empty-state title shown when photo access has been denied."
	)
	/// The empty-state detail shown when photo access has been denied.
	///
	/// - Tag: L10n-photoAccessDeniedDetail
	static let photoAccessDeniedDetail: String = String(
		localized: "You've denied photo library access. You can change this in Settings.",
		table: "Account",
		comment: "The empty-state detail shown when photo access has been denied."
	)
	/// The button that opens the system settings.
	///
	/// - Tag: L10n-openSettings
	static let openSettings: String = String(
		localized: "Open Settings",
		table: "Account",
		comment: "The button that opens the system settings."
	)
	/// The empty-state title shown when photo access is restricted.
	///
	/// - Tag: L10n-photoAccessRestrictedTitle
	static let photoAccessRestrictedTitle: String = String(
		localized: "Photo Access Restricted",
		table: "Account",
		comment: "The empty-state title shown when photo access is restricted."
	)
	/// The empty-state detail shown when photo access is restricted.
	///
	/// - Tag: L10n-photoAccessRestrictedDetail
	static let photoAccessRestrictedDetail: String = String(
		localized: "Photo library access is restricted on this device.",
		table: "Account",
		comment: "The empty-state detail shown when photo access is restricted."
	)
	/// The alert title shown when the image source is unavailable on the device.
	///
	/// - Tag: L10n-imagePickerUnavailableTitle
	static let imagePickerUnavailableTitle: String = String(
		localized: "Unavailable",
		table: "Account",
		comment: "The alert title shown when the image source is unavailable on the device."
	)
	/// The alert message shown when the image source is unavailable on the device.
	///
	/// - Tag: L10n-imagePickerUnavailableMessage
	static let imagePickerUnavailableMessage: String = String(
		localized: "This feature is not available on your device.",
		table: "Account",
		comment: "The alert message shown when the image source is unavailable on the device."
	)

	// MARK: - Redeem Actions
	/// The redeem bar button on the redeem screen.
	///
	/// - Tag: L10n-redeemButton
	static let redeemButton: String = String(
		localized: "Redeem 🚀",
		table: "Account",
		comment: "The redeem bar button on the redeem screen."
	)
	/// The success message shown after a code is redeemed.
	///
	/// - Parameter code: The redeemed code.
	///
	/// - Tag: L10n-redeemSuccessMessage
	static func redeemSuccessMessage(_ code: String) -> String {
		String(
			localized: "\(code) was successfully redeemed 🤩",
			table: "Account",
			comment: "The success message shown after a code is redeemed."
		)
	}
	/// The placeholder for the manual code entry field.
	///
	/// - Tag: L10n-redeemManualPlaceholder
	static let redeemManualPlaceholder: String = String(
		localized: "Or enter your code manually",
		table: "Account",
		comment: "The placeholder for the manual code entry field."
	)

	// MARK: - Purchase
	/// The price shown alongside its billing period.
	///
	/// - Parameters:
	///   - price: The localized display price.
	///   - unit: The localized billing period.
	///
	/// - Tag: L10n-pricePerUnit
	static func pricePerUnit(_ price: String, per unit: String) -> String {
		String(
			localized: "\(price) per \(unit)",
			table: "Account",
			comment: "The price shown alongside its billing period."
		)
	}

	// MARK: - Sessions Actions
	/// The swipe action that signs out of a single session.
	///
	/// - Tag: L10n-signOutOfSession
	static let signOutOfSession: String = String(
		localized: "Sign Out of Session",
		table: "Account",
		comment: "The swipe action that signs out of a single session."
	)

	// MARK: - Promoted Purchase
	/// The alert title prompting the user to resume a promoted purchase.
	///
	/// - Tag: L10n-continuePurchaseTitle
	static let continuePurchaseTitle: String = String(
		localized: "Continue your purchase?",
		table: "Account",
		comment: "The alert title prompting the user to resume a promoted purchase."
	)
	/// The alert message prompting the user to resume a promoted purchase.
	///
	/// - Parameter product: The product display name.
	///
	/// - Tag: L10n-continuePurchaseMessage
	static func continuePurchaseMessage(_ product: String) -> String {
		String(
			localized: "Resume the \(product) purchase you started in the App Store.",
			table: "Account",
			comment: "The alert message prompting the user to resume a promoted purchase."
		)
	}

	// MARK: - Access Gating
	/// The alert title shown when a feature requires Kurozora+.
	///
	/// - Tag: L10n-kurozoraPlusRequiredTitle
	static let kurozoraPlusRequiredTitle: String = String(
		localized: "Kurozora+ Required",
		table: "Account",
		comment: "The alert title shown when a feature requires Kurozora+."
	)
	/// The alert message shown when a feature requires Kurozora+.
	///
	/// - Tag: L10n-kurozoraPlusRequiredMessage
	static let kurozoraPlusRequiredMessage: String = String(
		localized: "This feature is only accessible to Kurozora+ users. Funds from this go to supporting Kurozora's development.",
		table: "Account",
		comment: "The alert message shown when a feature requires Kurozora+."
	)
	/// The alert title shown when a feature requires Pro.
	///
	/// - Tag: L10n-proRequiredTitle
	static let proRequiredTitle: String = String(
		localized: "Pro Required",
		table: "Account",
		comment: "The alert title shown when a feature requires Pro."
	)
	/// The alert message shown when a feature requires Pro.
	///
	/// - Tag: L10n-proRequiredMessage
	static let proRequiredMessage: String = String(
		localized: "This feature is accessible to Pro users. Funds from this go to supporting Kurozora's development. Alternatively, this feature and all other features are also included with Kurozora+.",
		table: "Account",
		comment: "The alert message shown when a feature requires Pro."
	)

	// MARK: - Unlock Screen
	/// The subtext on the unlock screen on Mac Catalyst.
	///
	/// - Tag: L10n-unlockSnoopingQuit
	static let unlockSnoopingQuit: String = String(
		localized: "Use the button above to unlock Kurozora or if you're snooping around someone else's device then press ⌘ + Q to quit 😤",
		table: "Account",
		comment: "The subtext on the unlock screen on Mac Catalyst."
	)
	/// The subtext on the unlock screen on iOS.
	///
	/// - Tag: L10n-unlockSnoopingExit
	static let unlockSnoopingExit: String = String(
		localized: "Use the button above to unlock Kurozora or if you're snooping around someone else's device then exit the app 😤",
		table: "Account",
		comment: "The subtext on the unlock screen on iOS."
	)

	// MARK: - Authentication
	/// The alert title shown when biometric authentication fails.
	///
	/// - Tag: L10n-errorAuthenticating
	static let errorAuthenticating: String = String(
		localized: "Error Authenticating",
		table: "Account",
		comment: "The alert title shown when biometric authentication fails."
	)

	// MARK: - Onboarding Placeholders
	/// The username field placeholder during sign-up.
	///
	/// - Tag: L10n-onboardingUsernamePlaceholder
	static let onboardingUsernamePlaceholder: String = String(
		localized: "Username: pick a cool one 🙈",
		table: "Account",
		comment: "The username field placeholder during sign-up."
	)
	/// The email field placeholder during sign-up.
	///
	/// - Tag: L10n-onboardingSignUpEmailPlaceholder
	static let onboardingSignUpEmailPlaceholder: String = String(
		localized: "Email: we all forget our passwords 🙉",
		table: "Account",
		comment: "The email field placeholder during sign-up."
	)
	/// The password field placeholder during sign-up.
	///
	/// - Tag: L10n-onboardingSignUpPasswordPlaceholder
	static let onboardingSignUpPasswordPlaceholder: String = String(
		localized: "Password: make it super secret 🙊",
		table: "Account",
		comment: "The password field placeholder during sign-up."
	)
	/// The email field placeholder during sign-in.
	///
	/// - Tag: L10n-onboardingSignInEmailPlaceholder
	static let onboardingSignInEmailPlaceholder: String = String(
		localized: "Your cool email address 🙌",
		table: "Account",
		comment: "The email field placeholder during sign-in."
	)
	/// The password field placeholder during sign-in.
	///
	/// - Tag: L10n-onboardingSignInPasswordPlaceholder
	static let onboardingSignInPasswordPlaceholder: String = String(
		localized: "Your super secret password 👀",
		table: "Account",
		comment: "The password field placeholder during sign-in."
	)
	/// The email field placeholder during password reset.
	///
	/// - Tag: L10n-onboardingResetEmailPlaceholder
	static let onboardingResetEmailPlaceholder: String = String(
		localized: "Your email address to the rescue 💌",
		table: "Account",
		comment: "The email field placeholder during password reset."
	)
	/// The footer explaining how the Kurozora account is used during onboarding.
	///
	/// - Tag: L10n-onboardingFooter
	static let onboardingFooter: String = String(
		localized: "Your Kurozora Account information is used to enable Kurozora services when you sign in. Kurozora services includes the library where you can keep track of the shows you are interested in.",
		table: "Account",
		comment: "The footer explaining how the Kurozora account is used during onboarding."
	)

	// MARK: - Library Import
	/// The import bar button on the library import screen.
	///
	/// - Tag: L10n-importButton
	static let importButton: String = String(
		localized: "Import 📲",
		table: "Account",
		comment: "The import bar button on the library import screen."
	)
}
