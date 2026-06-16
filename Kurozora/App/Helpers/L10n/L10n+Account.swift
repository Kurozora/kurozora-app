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
		static var signUpHeadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.signUpHeadline",
					defaultValue: "New to Kurozora?",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The headline string for signing up."
				)
			}
		}

		/// The subheadline string for signing up.
		///
		/// - Tag: L10n-signUpSubheadline
		static var signUpSubheadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.signUpSubheadline",
					defaultValue: "Create an account and join the community.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The subheadline string for signing up."
				)
			}
		}

		/// The button string for signing up.
		///
		/// - Tag: L10n-signUpButton
		static var signUpButton: String {
			L10n.resolve {
				String(
					localized: "onboarding.signUpButton",
					defaultValue: "Join 🤗",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The button string for signing up."
				)
			}
		}

		/// The headline string for sign up alert.
		///
		/// - Tag: L10n-signUpAlertHeadline
		static var signUpAlertHeadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.signUpAlertHeadline",
					defaultValue: "Hooray!",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The headline string for sign up alert."
				)
			}
		}

		/// The subheadline string for sign up alert.
		///
		/// - Tag: L10n-signUpAlertSubheadline
		static var signUpAlertSubheadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.signUpAlertSubheadline",
					defaultValue: "Account created successfully! Please check your email for confirmation.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The subheadline string for sign up alert."
				)
			}
		}

		/// The welcome message shown after account setup completes.
		static var signUpWelcomeMessage: String {
			L10n.resolve {
				String(
					localized: "Your account was successfully created!",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The welcome message shown after account setup completes."
				)
			}
		}

		/// The headline string for sign up error alert.
		///
		/// - Tag: L10n-signUpErrorAlertHeadline
		static var signUpErrorAlertHeadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.signUpErrorAlertHeadline",
					defaultValue: "Can't Sign Up 😔",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The headline string for sign up alert."
				)
			}
		}

		/// The headline string for signing in.
		///
		/// - Tag: L10n-signInHeadline
		static var signInHeadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.signInHeadline",
					defaultValue: "Kurozora Account",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The headline string for signing in."
				)
			}
		}

		/// The subheadline string for signing in.
		///
		/// - Tag: L10n-signInSubheadline
		static var signInSubheadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.signInSubheadline",
					defaultValue: "Sign in with your Kurozora Account to use the library and other Kurozora services.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The subheadline string for signing in."
				)
			}
		}

		/// The button string for signing in.
		///
		/// - Tag: L10n-signInButton
		static var signInButton: String {
			L10n.resolve {
				String(
					localized: "onboarding.signInButton",
					defaultValue: "Open sesame 👐",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The button string for signing in."
				)
			}
		}

		/// The headline string for Sign in with Apple.
		///
		/// - Tag: L10n-siwaHeadline
		static var siwaHeadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.siwaHeadline",
					defaultValue: "Setup Account",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The headline string for Sign in with Apple."
				)
			}
		}

		/// The subheadline string for Sign in with Apple.
		///
		/// - Tag: L10n-siwaSubheadline
		static var siwaSubheadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.siwaSubheadline",
					defaultValue: "Finish setting up your account and join the community.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: ""
				)
			}
		}

		/// The button string for sign in with Apple.
		///
		/// - Tag: L10n-siwaButton
		static var siwaButton: String {
			L10n.resolve {
				String(
					localized: "onboarding.siwaButton",
					defaultValue: "Join 🤗",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The button string for sign in with Apple."
				)
			}
		}

		/// The headline string for resetting password.
		///
		/// - Tag: L10n-forgotPasswordHeadline
		static var forgotPasswordHeadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.forgotPasswordHeadline",
					defaultValue: "Forgot Password?",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The headline string for resetting password."
				)
			}
		}

		/// The subheadline string for resetting password.
		///
		/// - Tag: L10n-forgotPasswordSubheadline
		static var forgotPasswordSubheadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.forgotPasswordSubheadline",
					defaultValue: "Enter your Kurozora Account to continue.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The subheadline string for resetting password."
				)
			}
		}

		/// The button string for resetting password.
		///
		/// - Tag: L10n-forgotPasswordButton
		static var forgotPasswordButton: String {
			L10n.resolve {
				String(
					localized: "onboarding.forgotPasswordButton",
					defaultValue: "Send ✨",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The button string for resetting password."
				)
			}
		}

		/// The headline string for resetting password alert.
		///
		/// - Tag: L10n-forgotPasswordAlertHeadline
		static var forgotPasswordAlertHeadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.forgotPasswordAlertHeadline",
					defaultValue: "Success!",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The headline string for resetting password alert."
				)
			}
		}

		/// The subheadline string for resetting password alert.
		///
		/// - Tag: L10n-forgotPasswordAlertSubheadline
		static var forgotPasswordAlertSubheadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.forgotPasswordAlertSubheadline",
					defaultValue: "If an account exists with this Kurozora Account, you should receive an email with your reset link shortly.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The subheadline string for resetting password alert."
				)
			}
		}

		/// The headline string for resetting password error alert.
		///
		/// - Tag: L10n-forgotPasswordErrorAlertHeadline
		static var forgotPasswordErrorAlertHeadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.forgotPasswordErrorAlertHeadline",
					defaultValue: "Errr…",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The headline string for resetting password alert."
				)
			}
		}

		/// The subheadline string for resetting password error alert.
		///
		/// - Tag: L10n-forgotPasswordErrorAlertSubheadline
		static var forgotPasswordErrorAlertSubheadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.forgotPasswordErrorAlertSubheadline",
					defaultValue: "Please type a valid Kurozora Account 😣",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The subheadline string for resetting password alert."
				)
			}
		}

		/// The button string for the forgot password option on the sign in screen.
		///
		/// - Tag: L10n-forgotPasswordOptionsButton
		static var forgotPasswordOptionsButton: String {
			L10n.resolve {
				String(
					localized: "onboarding.forgotPasswordOptionsButton",
					defaultValue: "Forgot your password? Let's reset 📧",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The button string for the forgot password option on the sign in screen."
				)
			}
		}

		/// The separator string between onboarding options.
		///
		/// - Tag: L10n-onboardingOrSeparator
		static var onboardingOrSeparator: String {
			L10n.resolve {
				String(
					localized: "onboarding.onboardingOrSeparator",
					defaultValue: "━━━━━━ or ━━━━━━",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The separator string between onboarding options."
				)
			}
		}

		/// The button string for the register option on the sign in screen.
		///
		/// - Tag: L10n-registerOptionsButton
		static var registerOptionsButton: String {
			L10n.resolve {
				String(
					localized: "onboarding.registerOptionsButton",
					defaultValue: "New to Kurozora? Join us 🔥",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The button string for the register option on the sign in screen."
				)
			}
		}

		/// The description string shown below onboarding options.
		///
		/// - Tag: L10n-onboardingDescription
		static var onboardingDescription: String {
			L10n.resolve {
				String(
					localized: "onboarding.onboardingDescription",
					defaultValue: "Your Kurozora Account lets you access your library, favorites, reminders, reviews, and more on your devices, automatically.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "The description string shown below onboarding options."
				)
			}
		}

		/// Title shown on the Apple sign-in screen.
		static var signInWithAppleTitle: String {
			L10n.resolve {
				String(
					localized: "onboarding.signInWithAppleTitle",
					defaultValue: "Sign in with Apple",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Title for the button or screen that allows the user to sign in with Apple."
				)
			}
		}

		/// Title shown when sign-in fails.
		static var signInErrorTitle: String {
			L10n.resolve {
				String(
					localized: "onboarding.signInErrorTitle",
					defaultValue: "Can't Sign In 😔",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Alert title shown when the user cannot sign in."
				)
			}
		}

		/// Generic fallback error message for sign-in failures.
		static var genericSignInErrorMessage: String {
			L10n.resolve {
				String(
					localized: "onboarding.genericSignInErrorMessage",
					defaultValue: "An error occurred while trying to sign in. Please try again.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Generic error message shown when sign-in fails for an unknown reason."
				)
			}
		}

		/// Headline shown on the two-factor challenge screen.
		///
		/// - Tag: L10n-twoFactorHeadline
		static var twoFactorHeadline: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorHeadline",
					defaultValue: "Two-Factor Authentication",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Headline shown on the two-factor authentication challenge screen."
				)
			}
		}

		/// Subheadline shown on the two-factor challenge screen when prompting for a TOTP code.
		///
		/// - Tag: L10n-twoFactorSubheadlineTOTP
		static var twoFactorSubheadlineTOTP: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorSubheadlineTOTP",
					defaultValue: "Enter the 6-digit code from your authenticator app.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Subheadline shown when the two-factor challenge expects a 6-digit TOTP code."
				)
			}
		}

		/// Subheadline shown on the two-factor challenge screen when prompting for a recovery code.
		///
		/// - Tag: L10n-twoFactorSubheadlineRecovery
		static var twoFactorSubheadlineRecovery: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorSubheadlineRecovery",
					defaultValue: "Enter one of your recovery codes.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Subheadline shown when the two-factor challenge expects a recovery code."
				)
			}
		}

		/// Placeholder shown in the TOTP entry field.
		///
		/// - Tag: L10n-twoFactorTOTPPlaceholder
		static var twoFactorTOTPPlaceholder: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorTOTPPlaceholder",
					defaultValue: "000 000",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Placeholder shown in the TOTP entry field of the two-factor challenge screen."
				)
			}
		}

		/// Placeholder shown in the recovery code entry field.
		///
		/// - Tag: L10n-twoFactorRecoveryPlaceholder
		static var twoFactorRecoveryPlaceholder: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorRecoveryPlaceholder",
					defaultValue: "XXXXXXXXXX-XXXXXXXXXX",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Placeholder showing the format of a recovery code on the two-factor challenge screen."
				)
			}
		}

		/// Toggle button title to switch from TOTP entry to recovery code entry.
		///
		/// - Tag: L10n-twoFactorUseRecoveryCode
		static var twoFactorUseRecoveryCode: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorUseRecoveryCode",
					defaultValue: "Use a recovery code instead",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Toggle button title that switches the two-factor challenge screen from TOTP to recovery code entry."
				)
			}
		}

		/// Toggle button title to switch from recovery code entry to TOTP entry.
		///
		/// - Tag: L10n-twoFactorUseTOTP
		static var twoFactorUseTOTP: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorUseTOTP",
					defaultValue: "Use authenticator code instead",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Toggle button title that switches the two-factor challenge screen from recovery code to TOTP entry."
				)
			}
		}

		/// Title for the verify button on the two-factor challenge screen.
		///
		/// - Tag: L10n-twoFactorVerifyButton
		static var twoFactorVerifyButton: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorVerifyButton",
					defaultValue: "Verify ✅",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Title for the navigation bar verify button on the two-factor challenge screen."
				)
			}
		}

		/// Alert title shown when the two-factor challenge token has expired.
		///
		/// - Tag: L10n-twoFactorExpiredTitle
		static var twoFactorExpiredTitle: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorExpiredTitle",
					defaultValue: "Session Expired",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Alert title shown when the two-factor authentication challenge expires."
				)
			}
		}

		/// Alert message shown when the two-factor challenge token has expired.
		///
		/// - Tag: L10n-twoFactorExpiredMessage
		static var twoFactorExpiredMessage: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorExpiredMessage",
					defaultValue: "Your verification session has expired. Please sign in again.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Alert message shown when the two-factor authentication challenge expires."
				)
			}
		}

		/// Inline error shown when the entered TOTP or recovery code is wrong.
		///
		/// - Tag: L10n-twoFactorInvalidCode
		static var twoFactorInvalidCode: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorInvalidCode",
					defaultValue: "Incorrect code. Please try again.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Inline error shown beneath the input field when the two-factor code is incorrect."
				)
			}
		}

		/// Inline error shown when the recovery code does not match the expected format.
		///
		/// - Tag: L10n-twoFactorInvalidFormat
		static var twoFactorInvalidFormat: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorInvalidFormat",
					defaultValue: "Recovery codes use the format XXXXXXXXXX-XXXXXXXXXX.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Inline error shown when the recovery code is not in the expected format."
				)
			}
		}

		/// Inline error shown when the network request fails on the two-factor screen.
		///
		/// - Tag: L10n-twoFactorNetworkError
		static var twoFactorNetworkError: String {
			L10n.resolve {
				String(
					localized: "onboarding.twoFactorNetworkError",
					defaultValue: "Network error. Check your connection and try again.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Inline error shown on the two-factor screen when the verification request fails due to a network error."
				)
			}
		}

		/// Error message when Apple authentication fails.
		static var appleAuthenticationFailedMessage: String {
			L10n.resolve {
				String(
					localized: "onboarding.appleAuthenticationFailedMessage",
					defaultValue: "Authentication failed by Apple. Please try again.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Error message shown when Apple authentication fails."
				)
			}
		}

		/// Error message when Apple returns invalid response.
		static var appleInvalidResponseMessage: String {
			L10n.resolve {
				String(
					localized: "onboarding.appleInvalidResponseMessage",
					defaultValue: "The app received an invalid response from Apple. Please try again.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Error message shown when Apple returns an invalid authentication response."
				)
			}
		}

		/// Error message when Apple authentication is not handled.
		static var appleAuthenticationNotHandledMessage: String {
			L10n.resolve {
				String(
					localized: "onboarding.appleAuthenticationNotHandledMessage",
					defaultValue: "An error occurred and the authentication was not handled by Apple. Please try again.",
					table: "Account",
					bundle: LanguageManager.shared.bundle,
					locale: LanguageManager.shared.locale,
					comment: "Error message shown when Apple authentication was not handled properly."
				)
			}
		}
	}

	// MARK: - Redeem
	/// The headline string for the Redeem view.
	///
	/// - Tag: L10n-redeemHeadline
	static var redeemHeadline: String {
		L10n.resolve {
			String(
				localized: "Redeem your code using the camera on your device.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the Redeem view."
			)
		}
	}
	/// The subheadline string for the Redeem view.
	///
	/// - Tag: L10n-redeemSubheadline
	static var redeemSubheadline: String {
		L10n.resolve {
			String(
				localized: "Found a Kurozora code in the wild? This is the place to redeem it!",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the Redeem view."
			)
		}
	}
	/// The footer string for the Redeem view.
	///
	/// - Tag: L10n-redeemFooter
	static var redeemFooter: String {
		L10n.resolve {
			String(
				localized: "Redeeming a code will unlock special badges and achievements, as well as increase your reputation points. Please keep in mind Kurozora codes are redeemable only once per account and expire after one use.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the Redeem view."
			)
		}
	}
	/// The headline string for the redeem error pop-up.
	///
	/// - Tag: L10n-redeemErrorHeadline
	static var redeemErrorHeadline: String {
		L10n.resolve {
			String(
				localized: "Error Redeeming Code",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the redeem error pop-up."
			)
		}
	}
	/// The subheadline string for the redeem error pop-up.
	///
	/// - Tag: L10n-redeemErrorSubheadline
	static var redeemErrorSubheadline: String {
		L10n.resolve {
			String(
				localized: "The code entered is not valid.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the redeem error pop-up."
			)
		}
	}
	/// The headline string for the redeem processing pop-up.
	///
	/// - Tag: L10n-redeemProcessingHeadline
	static var redeemProcessingHeadline: String {
		L10n.resolve {
			String(
				localized: "Processing redeem code.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the redeem processing pop-up."
			)
		}
	}
	/// The headline string for the redeem success pop-up.
	///
	/// - Tag: L10n-redeemSuccessHeadline
	static var redeemSuccessHeadline: String {
		L10n.resolve {
			String(
				localized: "Zoop, badoop, fruitloop!",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the redeem success pop-up."
			)
		}
	}
	/// The subheadline string for the redeem success pop-up.
	///
	/// - Tag: L10n-redeemSuccessSubheadline
	static var redeemSuccessSubheadline: String {
		L10n.resolve {
			String(
				localized: "%d was successfully redeemed 🤩",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the redeem success pop-up."
			)
		}
	}

	// MARK: - SiwA
	/// The headline string for the Sign in with Apple view.
	///
	/// - Tag: L10n-signInWithAppleHeadline
	static var signInWithAppleHeadline: String {
		L10n.resolve {
			String(
				localized: "Start using Sign in with Apple",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the Sign in with Apple view."
			)
		}
	}
	/// The subheadline string for the Sign in with Apple view.
	///
	/// - Tag: L10n-signInWithAppleSubheadline
	static var signInWithAppleSubheadline: String {
		L10n.resolve {
			String(
				localized: "Sign in with Apple is the fast, easy way for you to sign in to Kurozora using the Apple ID you already have.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subheadline string for the Sign in with Apple view."
			)
		}
	}
	/// The footer string for the Sign in with Apple view.
	///
	/// - Tag: L10n-signInWithAppleFooter
	static var signInWithAppleFooter: String {
		L10n.resolve {
			String(
				localized: "Kurozora offers Sign in with Apple for users who want the extra peace of mind when it comes to security and privacy. Sign in with Apple is a convenient way to sign in to apps and sites while having more control over the information you share. Kurozora is restricted to asking only for your name and email address, and Apple won’t track your app activity or build a profile of you.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the Sign in with Apple view."
			)
		}
	}

	// MARK: - In-App Purchases
	/// The message string for the product not found.
	///
	/// - Tag: L10n-productIDsNotSet
	static var productIDsNotSet: String {
		L10n.resolve {
			String(
				localized: "Product ids not set, call setProductIDs method!",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message string for the product not found."
			)
		}
	}
	/// The message string for IAP is disabled.
	///
	/// - Tag: L10n-iapDisabled
	static var iapDisabled: String {
		L10n.resolve {
			String(
				localized: "You are not authorized to make payments. In-App Purchases may be restricted on your device.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message string for IAP is disabled."
			)
		}
	}
	/// The message string for restoring IAP has failed.
	///
	/// - Tag: L10n-iapRestoreFailed
	static var iapRestoreFailed: String {
		L10n.resolve {
			String(
				localized: "There are no restorable purchases.\nOnly previously bought non-consumable products and auto-renewable subscriptions can be restored.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message string for restoring IAP has failed."
			)
		}
	}
	/// The message string for restoring IAP has succeeded.
	///
	/// - Tag: L10n-iapRestoreSucceeded
	static var iapRestoreSucceeded: String {
		L10n.resolve {
			String(
				localized: "All purchases have been restored.\nPlease remember that only previously bought non-consumable products and auto-renewable subscriptions can be restored.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message string for restoring IAP has succeeded."
			)
		}
	}

	// MARK: - Product Features
	/// The 'stylish app icons' product feature title.
	///
	/// - Tag: L10n-featureAppIconsTitle
	static var featureAppIconsTitle: String {
		L10n.resolve {
			String(
				localized: "Stylish App Icons",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'stylish app icons' product feature title."
			)
		}
	}
	/// The 'stylish app icons' product feature description.
	///
	/// - Tag: L10n-featureAppIconsDescription
	static var featureAppIconsDescription: String {
		L10n.resolve {
			String(
				localized: "Make your home screen stand out with premium and limited time app icons.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'stylish app icons' product feature description."
			)
		}
	}
	/// The 'startup chimes' product feature title.
	///
	/// - Tag: L10n-featureStartupChimesTitle
	static var featureStartupChimesTitle: String {
		L10n.resolve {
			String(
				localized: "Startup Chimes",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'startup chimes' product feature title."
			)
		}
	}
	/// The 'startup chimes' product feature description.
	///
	/// - Tag: L10n-featureStartupChimesDescription
	static var featureStartupChimesDescription: String {
		L10n.resolve {
			String(
				localized: "Immerse yourself in the world of anime from the very start with serene chimes and iconic anime sounds.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'startup chimes' product feature description."
			)
		}
	}
	/// The 'get animated' product feature title.
	///
	/// - Tag: L10n-featureGetAnimatedTitle
	static var featureGetAnimatedTitle: String {
		L10n.resolve {
			String(
				localized: "Get Animated",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'get animated' product feature title."
			)
		}
	}
	/// The 'get animated' product feature description.
	///
	/// - Tag: L10n-featureGetAnimatedDescription
	static var featureGetAnimatedDescription: String {
		L10n.resolve {
			String(
				localized: "Upgrade your profile with a gif image that captures your unique style.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'get animated' product feature description."
			)
		}
	}
	/// The 'change your identity' product feature title.
	///
	/// - Tag: L10n-featureChangeIdentityTitle
	static var featureChangeIdentityTitle: String {
		L10n.resolve {
			String(
				localized: "Change Your Identity",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'change your identity' product feature title."
			)
		}
	}
	/// The 'change your identity' product feature description.
	///
	/// - Tag: L10n-featureChangeIdentityDescription
	static var featureChangeIdentityDescription: String {
		L10n.resolve {
			String(
				localized: "Switch things up every now an then with a fresh username that truly represents you.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'change your identity' product feature description."
			)
		}
	}
	/// The 'support the community' product feature title.
	///
	/// - Tag: L10n-featureSupportCommunityTitle
	static var featureSupportCommunityTitle: String {
		L10n.resolve {
			String(
				localized: "Support the Community",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'support the community' product feature title."
			)
		}
	}
	/// The 'support the community' product feature description.
	///
	/// - Tag: L10n-featureSupportCommunityDescription
	static var featureSupportCommunityDescription: String {
		L10n.resolve {
			String(
				localized: "Your contribution helps with maintaining the servers, paying for software licenses, and fund events and activities.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'support the community' product feature description."
			)
		}
	}
	/// The product feature title for an extended feed-message character limit.
	///
	/// - Parameter count: The maximum number of characters.
	///
	/// - Tag: L10n-featureUpToCharacters
	static func featureUpToCharacters(_ count: Int) -> String {
		String(
			localized: "Up to \(count) Characters",
			table: "Account",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The product feature title for an extended feed-message character limit."
		)
	}
	/// The 'unified anime linking' product feature title.
	///
	/// - Tag: L10n-featureUnifiedLinkingTitle
	static var featureUnifiedLinkingTitle: String {
		L10n.resolve {
			String(
				localized: "Unified Anime Linking",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'unified anime linking' product feature title."
			)
		}
	}
	/// The 'unified anime linking' product feature description.
	///
	/// - Tag: L10n-featureUnifiedLinkingDescription
	static var featureUnifiedLinkingDescription: String {
		L10n.resolve {
			String(
				localized: "Seamlessly transition from other services to Kurozora. Add 'kurozora.app' to any URL and let us bring all your anime data in one place.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'unified anime linking' product feature description."
			)
		}
	}
	/// The 'integrate with calendar' product feature title.
	///
	/// - Tag: L10n-featureCalendarTitle
	static var featureCalendarTitle: String {
		L10n.resolve {
			String(
				localized: "Integrate with Calendar",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'integrate with calendar' product feature title."
			)
		}
	}
	/// The 'integrate with calendar' product feature description.
	///
	/// - Tag: L10n-featureCalendarDescription
	static var featureCalendarDescription: String {
		L10n.resolve {
			String(
				localized: "Integrate your anime schedule into your calendar. Never miss an episode again with reminders for new airings.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'integrate with calendar' product feature description."
			)
		}
	}
	/// The 'dynamic themes' product feature title.
	///
	/// - Tag: L10n-featureDynamicThemesTitle
	static var featureDynamicThemesTitle: String {
		L10n.resolve {
			String(
				localized: "Dynamic Themes",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'dynamic themes' product feature title."
			)
		}
	}
	/// The 'dynamic themes' product feature description.
	///
	/// - Tag: L10n-featureDynamicThemesDescription
	static var featureDynamicThemesDescription: String {
		L10n.resolve {
			String(
				localized: "Choose from a range of themes to create a look that reflects your personality and style.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'dynamic themes' product feature description."
			)
		}
	}
	/// The subscription feed-message character-limit product feature description.
	///
	/// - Tag: L10n-featureSubscriptionCharacterLimitDescription
	static var featureSubscriptionCharacterLimitDescription: String {
		L10n.resolve {
			String(
				localized: "Dive even deeper into discussions with an extended 1000 character limit for your feed messages.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subscription feed-message character-limit product feature description."
			)
		}
	}
	/// The 'unlock subscriber badge' product feature title.
	///
	/// - Tag: L10n-featureSubscriberBadgeTitle
	static var featureSubscriberBadgeTitle: String {
		L10n.resolve {
			String(
				localized: "Unlock Subscriber Badge",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'unlock subscriber badge' product feature title."
			)
		}
	}
	/// The 'unlock subscriber badge' product feature description.
	///
	/// - Tag: L10n-featureSubscriberBadgeDescription
	static var featureSubscriberBadgeDescription: String {
		L10n.resolve {
			String(
				localized: "Stand out in the community with an exclusive subscription badge that evolves over time as you continue to support Kurozora!",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'unlock subscriber badge' product feature description."
			)
		}
	}
	/// The tip jar feed-message character-limit product feature description.
	///
	/// - Tag: L10n-featureTipJarCharacterLimitDescription
	static var featureTipJarCharacterLimitDescription: String {
		L10n.resolve {
			String(
				localized: "Have more to say? Express yourself fully with a 500 character limit for your feed messages.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The tip jar feed-message character-limit product feature description."
			)
		}
	}
	/// The 'unlock pro badge' product feature title.
	///
	/// - Tag: L10n-featureProBadgeTitle
	static var featureProBadgeTitle: String {
		L10n.resolve {
			String(
				localized: "Unlock Pro Badge",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'unlock pro badge' product feature title."
			)
		}
	}
	/// The 'unlock pro badge' product feature description.
	///
	/// - Tag: L10n-featureProBadgeDescription
	static var featureProBadgeDescription: String {
		L10n.resolve {
			String(
				localized: "Elevate your status in the Kurozora community with the prestigious Pro badge next to your username, and show your support for Kurozora.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'unlock pro badge' product feature description."
			)
		}
	}

	// MARK: - Subscription
	/// The footer string for the Subscription view.
	///
	/// - Tag: L10n-subscriptionFooter
	static var subscriptionFooter: String {
		L10n.resolve {
			String(
				localized: "Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the Subscription view."
			)
		}
	}
	/// The string for the 'manage subscriptions' settings option.
	///
	/// - Tag: L10n-manageSubscriptions
	static var manageSubscriptions: String {
		L10n.resolve {
			String(
				localized: "Manage Subscriptions",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'manage subscriptions' settings option."
			)
		}
	}

	// MARK: - Tip Jar
	/// The footer string for the Tip Jar view.
	///
	/// - Tag: L10n-tipJarFooter
	static var tipJarFooter: String {
		L10n.resolve {
			String(
				localized: "Payment will be charged to your Apple ID account at the confirmation of purchase. Unlike Kurozora+ subscription, tips are a one time purchase. Your account will be charged only once every time you tip.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the Tip Jar view."
			)
		}
	}

	// MARK: - Request Refund
	/// The description string for the Request Refund view.
	///
	/// - Tag: L10n-requestRefundHeaderDescription
	static var requestRefundHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "requestRefund.header.description",
				defaultValue: "Review your recent purchases and ask Apple to refund any you no longer want. Apple decides each request, so refunds aren't guaranteed.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The description string for the Request Refund view."
			)
		}
	}
	/// The 'purchased' section header on the Request Refund view.
	///
	/// - Tag: L10n-purchasedSectionHeader
	static var purchasedSectionHeader: String {
		L10n.resolve {
			String(
				localized: "purchased.section",
				defaultValue: "Purchased",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'purchased' section header on the Request Refund view."
			)
		}
	}
	/// The 'refunded' section header on the Request Refund view.
	///
	/// - Tag: L10n-refundedSectionHeader
	static var refundedSectionHeader: String {
		L10n.resolve {
			String(
				localized: "refunded.section",
				defaultValue: "Refunded",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The 'refunded' section header on the Request Refund view."
			)
		}
	}
	/// The empty-state title for the Request Refund view.
	///
	/// - Tag: L10n-refundEmptyTitle
	static var refundEmptyTitle: String {
		L10n.resolve {
			String(
				localized: "refund.empty.title",
				defaultValue: "No Purchases",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state title for the Request Refund view."
			)
		}
	}
	/// The empty-state detail for the Request Refund view.
	///
	/// - Tag: L10n-refundEmptyDetail
	static var refundEmptyDetail: String {
		L10n.resolve {
			String(
				localized: "refund.empty.detail",
				defaultValue: "There are no purchases on this account that can be refunded.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail for the Request Refund view."
			)
		}
	}
	/// The 'Purchased <date>' subtitle for a consumable transaction.
	///
	/// - Tag: L10n-purchasedOn
	static func purchasedOn(_ date: String) -> String {
		return String(
			localized: "refund.purchasedOn",
			defaultValue: "Purchased \(date)",
			table: "Account",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
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
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
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
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The 'Refunded <date>' subtitle for a revoked transaction."
		)
	}
	// MARK: - Privacy Policy
	/// The string for the phrase 'Kurozora & Privacy'.
	///
	/// - Tag: L10n-kurozoraAndPrivacy
	static var kurozoraAndPrivacy: String {
		L10n.resolve {
			String(
				localized: "Kurozora & Privacy",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Kurozora & Privacy'."
			)
		}
	}
	/// The string for the word terms of use.
	///
	/// - Tag: L10n-termsOfUse
	static var termsOfUse: String {
		L10n.resolve {
			String(
				localized: "Terms of Use",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word terms of use."
			)
		}
	}
	/// The string for the word privacy policy.
	///
	/// - Tag: L10n-privacyPolicy
	static var privacyPolicy: String {
		L10n.resolve {
			String(
				localized: "Privacy Policy",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the word privacy policy."
			)
		}
	}
	/// The attributed footer string linking to the privacy policy, styled via the active theme.
	///
	/// - Tag: L10n-visitPrivacyPolicy
	static var visitPrivacyPolicy: ThemeAttributedStringPicker = {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		return ThemeAttributedStringPicker {
			let linkText = L10n.privacyPolicy
			let format = String(
				localized: "visitPrivacyPolicyFooter",
				defaultValue: "For more information, please visit our %@",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Footer linking to the privacy policy. The placeholder is the linked Privacy Policy text."
			)
			let fullText = String(format: format, linkText)
			let attributedString = NSMutableAttributedString(string: fullText, attributes: [.foregroundColor: KThemePicker.subTextColor.colorValue, .paragraphStyle: paragraphStyle])

			if let linkRange = fullText.range(of: linkText) {
				attributedString.addAttribute(.foregroundColor, value: KThemePicker.tintColor.colorValue, range: NSRange(linkRange, in: fullText))
			}

			return attributedString
		}
	}()

	/// The string for the phrase 'Open in Settings app'.
	///
	/// - Tag: L10n-openInSettingsApp
	static var openInSettingsApp: String {
		L10n.resolve {
			String(
				localized: "Open in Settings app",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the phrase 'Open in Settings app'."
			)
		}
	}

	// MARK: - Authentication
	/// The string for 'Require Authentication' settings.
	///
	/// - Tag: L10n-requireAuthentication
	static var requireAuthentication: String {
		L10n.resolve {
			String(
				localized: "Require Authentication",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for 'Require Authentication' settings."
			)
		}
	}
	/// The string for requiring authentication immediately.
	///
	/// - Tag: L10n-immediateAuthenticationRequired
	static var immediateAuthenticationRequired: String {
		L10n.resolve {
			String(
				localized: "Authentication is required every time you return to the app.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for requiring authentication immediately."
			)
		}
	}
	/// The string for the 'Authentication Interval' settings description.
	///
	/// - Tag: L10n-authenticationInterval
	static func authenticationInterval(_ interval: String) -> String {
		return String(
			localized: "Authentication is required if the app remains in the background for more than \(interval).",
			table: "Account",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The string for the 'Authentication Interval' settings description."
		)
	}
	/// The thirty seconds interval phrase used in the authentication interval description.
	static var intervalThirtySeconds: String {
		L10n.resolve {
			String(localized: "30 seconds", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The thirty seconds interval phrase used in the authentication interval description.")
		}
	}
	/// The one minute interval phrase used in the authentication interval description.
	static var intervalOneMinute: String {
		L10n.resolve {
			String(localized: "1 minute", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The one minute interval phrase used in the authentication interval description.")
		}
	}
	/// The two minutes interval phrase used in the authentication interval description.
	static var intervalTwoMinutes: String {
		L10n.resolve {
			String(localized: "2 minutes", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The two minutes interval phrase used in the authentication interval description.")
		}
	}
	/// The three minutes interval phrase used in the authentication interval description.
	static var intervalThreeMinutes: String {
		L10n.resolve {
			String(localized: "3 minutes", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The three minutes interval phrase used in the authentication interval description.")
		}
	}
	/// The four minutes interval phrase used in the authentication interval description.
	static var intervalFourMinutes: String {
		L10n.resolve {
			String(localized: "4 minutes", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The four minutes interval phrase used in the authentication interval description.")
		}
	}
	/// The five minutes interval phrase used in the authentication interval description.
	static var intervalFiveMinutes: String {
		L10n.resolve {
			String(localized: "5 minutes", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The five minutes interval phrase used in the authentication interval description.")
		}
	}

	/// The string for authenticating immediately.
	///
	/// - Tag: L10n-immediately
	static var immediately: String {
		L10n.resolve {
			String(
				localized: "Immediately",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for authenticating immediately."
			)
		}
	}
	/// The string for authenticating after 30 seconds.
	///
	/// - Tag: L10n-thirtySeconds
	static var thirtySeconds: String {
		L10n.resolve {
			String(
				localized: "30 Seconds",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for authenticating after 30 seconds."
			)
		}
	}
	/// The string for authenticating after 1 minute.
	///
	/// - Tag: L10n-oneMinute
	static var oneMinute: String {
		L10n.resolve {
			String(
				localized: "1 Minute",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for authenticating after 1 minute."
			)
		}
	}
	/// The string for authenticating after 2 minutes.
	///
	/// - Tag: L10n-twoMinutes
	static var twoMinutes: String {
		L10n.resolve {
			String(
				localized: "2 Minutes",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for authenticating after 2 minutes."
			)
		}
	}
	/// The string for authenticating after 3 minutes.
	///
	/// - Tag: L10n-threeMinutes
	static var threeMinutes: String {
		L10n.resolve {
			String(
				localized: "3 Minutes",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for authenticating after 3 minutes."
			)
		}
	}
	/// The string for authenticating after 4 minutes.
	///
	/// - Tag: L10n-fourMinutes
	static var fourMinutes: String {
		L10n.resolve {
			String(
				localized: "4 Minutes",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for authenticating after 4 minutes."
			)
		}
	}
	/// The string for authenticating after 5 minutes.
	///
	/// - Tag: L10n-fiveMinutes
	static var fiveMinutes: String {
		L10n.resolve {
			String(
				localized: "5 Minutes",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for authenticating after 5 minutes."
			)
		}
	}

	// MARK: - Unlock
	/// The unlock button title for the biometric-authentication screen.
	///
	/// - Tag: L10n-unlockKurozora
	static var unlockKurozora: String {
		L10n.resolve {
			String(
				localized: "Unlock Kurozora",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The unlock button title for the biometric-authentication screen."
			)
		}
	}

	// MARK: - Data Management
	/// The tappable legal footer link shown on the onboarding footer cell.
	///
	/// - Tag: L10n-seeHowDataIsManaged
	static var seeHowDataIsManaged: String {
		L10n.resolve {
			String(
				localized: "See how your data is managed…",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The tappable legal footer link shown on the onboarding footer cell."
			)
		}
	}

	// MARK: - Sessions
	/// The string for the 'current session' section.
	///
	/// - Tag: L10n-currentSession
	static var currentSession: String {
		L10n.resolve {
			String(
				localized: "Current Session",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'current session' section."
			)
		}
	}
	/// The string for the 'other session' section.
	///
	/// - Tag: L10n-otherSessions
	static var otherSessions: String {
		L10n.resolve {
			String(
				localized: "Other Sessions",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'other sessions' section."
			)
		}
	}
	/// The string for 'this device'.
	///
	/// - Tag: L10n-thisDevice
	static var thisDevice: String {
		L10n.resolve {
			String(
				localized: "This device",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for 'this device'."
			)
		}
	}

	/// The title of the action that signs out every other session.
	///
	/// - Tag: L10n-signOutAllOtherSessions
	static var signOutAllOtherSessions: String {
		L10n.resolve {
			String(
				localized: "Sign Out All Other Sessions",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the action that signs out every other session."
			)
		}
	}
	/// The message asking for the password before signing out the selected sessions.
	///
	/// - Tag: L10n-signOutSessionsConfirmation
	static var signOutSessionsConfirmation: String {
		L10n.resolve {
			String(
				localized: "Enter your password to sign out the selected sessions.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message asking for the password before signing out the selected sessions."
			)
		}
	}
	/// The message asking for the password before signing out every other session.
	///
	/// - Tag: L10n-signOutAllOtherSessionsConfirmation
	static var signOutAllOtherSessionsConfirmation: String {
		L10n.resolve {
			String(
				localized: "Enter your password to sign out all of your other sessions across all of your devices.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message asking for the password before signing out every other session."
			)
		}
	}
	/// The error title shown when sessions can't be signed out.
	///
	/// - Tag: L10n-couldNotSignOutSessions
	static var couldNotSignOutSessions: String {
		L10n.resolve {
			String(
				localized: "Could Not Sign Out Sessions",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The error title shown when sessions can't be signed out."
			)
		}
	}

	// MARK: - Account Screen
	/// The title of the account settings screen.
	///
	/// - Tag: L10n-kurozoraAccount
	static var kurozoraAccount: String {
		L10n.resolve {
			String(
				localized: "Kurozora Account",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the account settings screen."
			)
		}
	}
	/// The title of the active sessions screen.
	///
	/// - Tag: L10n-activeSessions
	static var activeSessions: String {
		L10n.resolve {
			String(
				localized: "Active Sessions",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the active sessions screen."
			)
		}
	}

	// MARK: - Edit Profile
	/// The section label above the username field on the edit profile screen.
	///
	/// - Tag: L10n-editProfileUsernameLabel
	static var editProfileUsernameLabel: String {
		L10n.resolve {
			String(
				localized: "Username",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The section label above the username field on the edit profile screen."
			)
		}
	}
	/// The section label above the display name field on the edit profile screen.
	///
	/// - Tag: L10n-editProfileDisplayNameLabel
	static var editProfileDisplayNameLabel: String {
		L10n.resolve {
			String(
				localized: "Display Name",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The section label above the display name field on the edit profile screen."
			)
		}
	}
	/// The section label above the bio field on the edit profile screen.
	///
	/// - Tag: L10n-editProfileBioLabel
	static var editProfileBioLabel: String {
		L10n.resolve {
			String(
				localized: "About Me",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The section label above the bio field on the edit profile screen."
			)
		}
	}
	/// The alert title shown when updating the profile fails.
	///
	/// - Tag: L10n-editProfileErrorTitle
	static var editProfileErrorTitle: String {
		L10n.resolve {
			String(
				localized: "Error Updating Profile",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when updating the profile fails."
			)
		}
	}

	// MARK: - Profile Image Selection
	/// The camera-menu action that captures a new photo.
	///
	/// - Tag: L10n-pickerTakePhoto
	static var pickerTakePhoto: String {
		L10n.resolve {
			String(
				localized: "Take Photo",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The camera-menu action that captures a new photo."
			)
		}
	}
	/// The camera-menu action that picks a photo from the library.
	///
	/// - Tag: L10n-pickerPhotoLibrary
	static var pickerPhotoLibrary: String {
		L10n.resolve {
			String(
				localized: "Photo Library",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The camera-menu action that picks a photo from the library."
			)
		}
	}
	/// The empty-state title prompting the user to grant photo access.
	///
	/// - Tag: L10n-photoAccessTitle
	static var photoAccessTitle: String {
		L10n.resolve {
			String(
				localized: "Access Your Photos",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state title prompting the user to grant photo access."
			)
		}
	}
	/// The empty-state detail prompting the user to grant photo access.
	///
	/// - Tag: L10n-photoAccessDetail
	static var photoAccessDetail: String {
		L10n.resolve {
			String(
				localized: "Allow access to your photo library to choose a profile picture.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail prompting the user to grant photo access."
			)
		}
	}
	/// The button that requests photo library access.
	///
	/// - Tag: L10n-photoAccessAllowButton
	static var photoAccessAllowButton: String {
		L10n.resolve {
			String(
				localized: "Allow Access",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button that requests photo library access."
			)
		}
	}
	/// The empty-state title shown when photo access has been denied.
	///
	/// - Tag: L10n-photoAccessDeniedTitle
	static var photoAccessDeniedTitle: String {
		L10n.resolve {
			String(
				localized: "Photo Access Denied",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state title shown when photo access has been denied."
			)
		}
	}
	/// The empty-state detail shown when photo access has been denied.
	///
	/// - Tag: L10n-photoAccessDeniedDetail
	static var photoAccessDeniedDetail: String {
		L10n.resolve {
			String(
				localized: "You've denied photo library access. You can change this in Settings.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail shown when photo access has been denied."
			)
		}
	}
	/// The button that opens the system settings.
	///
	/// - Tag: L10n-openSettings
	static var openSettings: String {
		L10n.resolve {
			String(
				localized: "Open Settings",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button that opens the system settings."
			)
		}
	}
	/// The empty-state title shown when photo access is restricted.
	///
	/// - Tag: L10n-photoAccessRestrictedTitle
	static var photoAccessRestrictedTitle: String {
		L10n.resolve {
			String(
				localized: "Photo Access Restricted",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state title shown when photo access is restricted."
			)
		}
	}
	/// The empty-state detail shown when photo access is restricted.
	///
	/// - Tag: L10n-photoAccessRestrictedDetail
	static var photoAccessRestrictedDetail: String {
		L10n.resolve {
			String(
				localized: "Photo library access is restricted on this device.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail shown when photo access is restricted."
			)
		}
	}
	/// The alert title shown when the image source is unavailable on the device.
	///
	/// - Tag: L10n-imagePickerUnavailableTitle
	static var imagePickerUnavailableTitle: String {
		L10n.resolve {
			String(
				localized: "Unavailable",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when the image source is unavailable on the device."
			)
		}
	}
	/// The alert message shown when the image source is unavailable on the device.
	///
	/// - Tag: L10n-imagePickerUnavailableMessage
	static var imagePickerUnavailableMessage: String {
		L10n.resolve {
			String(
				localized: "This feature is not available on your device.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert message shown when the image source is unavailable on the device."
			)
		}
	}

	// MARK: - Redeem Actions
	/// The redeem bar button on the redeem screen.
	///
	/// - Tag: L10n-redeemButton
	static var redeemButton: String {
		L10n.resolve {
			String(
				localized: "Redeem 🚀",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The redeem bar button on the redeem screen."
			)
		}
	}
	/// The success message shown after a code is redeemed.
	///
	/// - Parameter code: The redeemed code.
	///
	/// - Tag: L10n-redeemSuccessMessage
	static func redeemSuccessMessage(_ code: String) -> String {
		String(
			localized: "\(code) was successfully redeemed 🤩",
			table: "Account",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The success message shown after a code is redeemed."
		)
	}
	/// The placeholder for the manual code entry field.
	///
	/// - Tag: L10n-redeemManualPlaceholder
	static var redeemManualPlaceholder: String {
		L10n.resolve {
			String(
				localized: "Or enter your code manually",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The placeholder for the manual code entry field."
			)
		}
	}

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
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The price shown alongside its billing period."
		)
	}

	// MARK: - Subscription Period
	/// The subscription period in days.
	static func periodWordDays(_ value: Int) -> String {
		L10n.resolve {
			String(localized: "\(value) days", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The subscription period in days.")
		}
	}
	/// The subscription period in weeks.
	static func periodWordWeeks(_ value: Int) -> String {
		L10n.resolve {
			String(localized: "\(value) weeks", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The subscription period in weeks.")
		}
	}
	/// The subscription period in months.
	static func periodWordMonths(_ value: Int) -> String {
		L10n.resolve {
			String(localized: "\(value) months", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The subscription period in months.")
		}
	}
	/// The subscription period in years.
	static func periodWordYears(_ value: Int) -> String {
		L10n.resolve {
			String(localized: "\(value) years", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The subscription period in years.")
		}
	}
	/// The fallback word for an unknown subscription period unit.
	static var periodWordDefault: String {
		L10n.resolve {
			String(localized: "period", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The fallback word for an unknown subscription period unit.")
		}
	}
	/// The display phrase for a single-day subscription period.
	static var periodDisplaySingularDay: String {
		L10n.resolve {
			String(localized: "a day", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display phrase for a single-day subscription period.")
		}
	}
	/// The display phrase for a single-week subscription period.
	static var periodDisplaySingularWeek: String {
		L10n.resolve {
			String(localized: "a week", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display phrase for a single-week subscription period.")
		}
	}
	/// The display phrase for a single-month subscription period.
	static var periodDisplaySingularMonth: String {
		L10n.resolve {
			String(localized: "a month", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display phrase for a single-month subscription period.")
		}
	}
	/// The display phrase for a single-year subscription period.
	static var periodDisplaySingularYear: String {
		L10n.resolve {
			String(localized: "12 months", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display phrase for a single-year subscription period, shown as twelve months.")
		}
	}
	/// The compact subscription period in days.
	static func periodShortDays(_ value: Int) -> String {
		L10n.resolve {
			String(localized: "\(value)d", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The compact subscription period in days.")
		}
	}
	/// The compact subscription period in weeks.
	static func periodShortWeeks(_ value: Int) -> String {
		L10n.resolve {
			String(localized: "\(value)w", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The compact subscription period in weeks.")
		}
	}
	/// The compact subscription period in months.
	static func periodShortMonths(_ value: Int) -> String {
		L10n.resolve {
			String(localized: "\(value)m", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The compact subscription period in months.")
		}
	}
	/// The compact subscription period in years.
	static func periodShortYears(_ value: Int) -> String {
		L10n.resolve {
			String(localized: "\(value)y", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The compact subscription period in years.")
		}
	}
	/// The subscription saving description comparing a tier against the base price.
	static func subscriptionSavingDescription(_ unit: String, _ pricePerMonth: String, _ saved: String) -> String {
		L10n.resolve {
			String(localized: "\(unit) at \(pricePerMonth)mo. Save \(saved)", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The subscription saving description, where the placeholders are the billing period, the monthly price and the saved percentage.")
		}
	}
	/// The introductory free trial description.
	static func subscriptionTrial(_ period: String) -> String {
		L10n.resolve {
			String(localized: "Includes \(period) free trial!", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The introductory free trial description, where the placeholder is the trial period.")
		}
	}

	// MARK: - Sessions Actions
	/// The swipe action that signs out of a single session.
	///
	/// - Tag: L10n-signOutOfSession
	static var signOutOfSession: String {
		L10n.resolve {
			String(
				localized: "Sign Out of Session",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The swipe action that signs out of a single session."
			)
		}
	}

	// MARK: - Promoted Purchase
	/// The alert title prompting the user to resume a promoted purchase.
	///
	/// - Tag: L10n-continuePurchaseTitle
	static var continuePurchaseTitle: String {
		L10n.resolve {
			String(
				localized: "Continue your purchase?",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title prompting the user to resume a promoted purchase."
			)
		}
	}
	/// The alert message prompting the user to resume a promoted purchase.
	///
	/// - Parameter product: The product display name.
	///
	/// - Tag: L10n-continuePurchaseMessage
	static func continuePurchaseMessage(_ product: String) -> String {
		String(
			localized: "Resume the \(product) purchase you started in the App Store.",
			table: "Account",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The alert message prompting the user to resume a promoted purchase."
		)
	}

	// MARK: - Access Gating
	/// The alert title shown when a feature requires Kurozora+.
	///
	/// - Tag: L10n-kurozoraPlusRequiredTitle
	static var kurozoraPlusRequiredTitle: String {
		L10n.resolve {
			String(
				localized: "Kurozora+ Required",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when a feature requires Kurozora+."
			)
		}
	}
	/// The alert message shown when a feature requires Kurozora+.
	///
	/// - Tag: L10n-kurozoraPlusRequiredMessage
	static var kurozoraPlusRequiredMessage: String {
		L10n.resolve {
			String(
				localized: "This feature is only accessible to Kurozora+ users. Funds from this go to supporting Kurozora's development.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert message shown when a feature requires Kurozora+."
			)
		}
	}
	/// The alert title shown when a feature requires Pro.
	///
	/// - Tag: L10n-proRequiredTitle
	static var proRequiredTitle: String {
		L10n.resolve {
			String(
				localized: "Pro Required",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when a feature requires Pro."
			)
		}
	}
	/// The alert message shown when a feature requires Pro.
	///
	/// - Tag: L10n-proRequiredMessage
	static var proRequiredMessage: String {
		L10n.resolve {
			String(
				localized: "This feature is accessible to Pro users. Funds from this go to supporting Kurozora's development. Alternatively, this feature and all other features are also included with Kurozora+.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert message shown when a feature requires Pro."
			)
		}
	}

	// MARK: - Unlock Screen
	/// The subtext on the unlock screen on Mac Catalyst.
	///
	/// - Tag: L10n-unlockSnoopingQuit
	static var unlockSnoopingQuit: String {
		L10n.resolve {
			String(
				localized: "Use the button above to unlock Kurozora or if you're snooping around someone else's device then press ⌘ + Q to quit 😤",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subtext on the unlock screen on Mac Catalyst."
			)
		}
	}
	/// The subtext on the unlock screen on iOS.
	///
	/// - Tag: L10n-unlockSnoopingExit
	static var unlockSnoopingExit: String {
		L10n.resolve {
			String(
				localized: "Use the button above to unlock Kurozora or if you're snooping around someone else's device then exit the app 😤",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The subtext on the unlock screen on iOS."
			)
		}
	}

	// MARK: - Authentication
	/// The alert title shown when biometric authentication fails.
	///
	/// - Tag: L10n-errorAuthenticating
	static var errorAuthenticating: String {
		L10n.resolve {
			String(
				localized: "Error Authenticating",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert title shown when biometric authentication fails."
			)
		}
	}

	// MARK: - Biometric Reasons
	/// The biometric prompt reason shown when returning to the locked app.
	static var biometricReasonContinue: String {
		L10n.resolve {
			String(localized: "Welcome back! Please authenticate to continue.", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The biometric prompt reason shown when returning to the locked app.")
		}
	}
	/// The biometric prompt reason shown when returning to the locked app on Mac.
	static var biometricReasonContinueMac: String {
		L10n.resolve {
			String(localized: "authenticate to continue.", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The biometric prompt reason shown when returning to the locked app on Mac.")
		}
	}
	/// The biometric prompt reason shown when enabling app lock.
	static var biometricReasonEnableAppLock: String {
		L10n.resolve {
			String(localized: "Authenticate to enable app lock.", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The biometric prompt reason shown when enabling app lock.")
		}
	}
	/// The biometric prompt reason shown when enabling app lock on Mac.
	static var biometricReasonEnableAppLockMac: String {
		L10n.resolve {
			String(localized: "authenticate to enable app lock.", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The biometric prompt reason shown when enabling app lock on Mac.")
		}
	}
	/// The biometric prompt reason shown when disabling app lock.
	static var biometricReasonDisableAppLock: String {
		L10n.resolve {
			String(localized: "Authenticate to disable app lock.", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The biometric prompt reason shown when disabling app lock.")
		}
	}
	/// The biometric prompt reason shown when disabling app lock on Mac.
	static var biometricReasonDisableAppLockMac: String {
		L10n.resolve {
			String(localized: "authenticate to disable app lock.", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The biometric prompt reason shown when disabling app lock on Mac.")
		}
	}

	// MARK: - Authentication Errors
	/// The error shown when the device does not support biometric authentication.
	static var authErrorBiometryNotAvailable: String {
		L10n.resolve {
			String(localized: "Authentication could not start because the device does not support biometric authentication.", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when the device does not support biometric authentication.")
		}
	}
	/// The error shown when the user is locked out of biometric authentication.
	static var authErrorBiometryLockout: String {
		L10n.resolve {
			String(localized: "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times.", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when the user is locked out of biometric authentication.")
		}
	}
	/// The error shown when the user has not enrolled in biometric authentication.
	static var authErrorBiometryNotEnrolled: String {
		L10n.resolve {
			String(localized: "Authentication could not start because the user has not enrolled in biometric authentication.", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when the user has not enrolled in biometric authentication.")
		}
	}
	/// The error shown when an unrecognized authentication error code is returned.
	static var authErrorUnknownCode: String {
		L10n.resolve {
			String(localized: "Did not find error code on LAError object", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when an unrecognized authentication error code is returned.")
		}
	}
	/// The error shown when the user fails to provide valid credentials.
	static var authErrorAuthenticationFailed: String {
		L10n.resolve {
			String(localized: "The user failed to provide valid credentials", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when the user fails to provide valid credentials.")
		}
	}
	/// The error shown when authentication is cancelled by the app.
	static var authErrorAppCancel: String {
		L10n.resolve {
			String(localized: "Authentication was cancelled by application", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when authentication is cancelled by the app.")
		}
	}
	/// The error shown when the authentication context is invalid.
	static var authErrorInvalidContext: String {
		L10n.resolve {
			String(localized: "The context is invalid", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when the authentication context is invalid.")
		}
	}
	/// The error shown when authentication is not interactive.
	static var authErrorNotInteractive: String {
		L10n.resolve {
			String(localized: "Not interactive", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when authentication is not interactive.")
		}
	}
	/// The error shown when no passcode is set on the device.
	static var authErrorPasscodeNotSet: String {
		L10n.resolve {
			String(localized: "Passcode is not set on the device", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when no passcode is set on the device.")
		}
	}
	/// The error shown when authentication is cancelled by the system.
	static var authErrorSystemCancel: String {
		L10n.resolve {
			String(localized: "Authentication was cancelled by the system", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when authentication is cancelled by the system.")
		}
	}
	/// The error shown when the user cancels authentication.
	static var authErrorUserCancel: String {
		L10n.resolve {
			String(localized: "The user did cancel", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when the user cancels authentication.")
		}
	}
	/// The error shown when the user chooses the fallback option.
	static var authErrorUserFallback: String {
		L10n.resolve {
			String(localized: "The user chose to use the fallback", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The error shown when the user chooses the fallback option.")
		}
	}
	/// The confirmation message shown before permanently deleting an account.
	static var deleteAccountConfirmation: String {
		L10n.resolve {
			String(localized: "Are you sure you want to delete your account? Once your account is deleted, all of its resources and data will be permanently deleted. Please enter your password to confirm you would like to permanently delete your account.", table: "Account", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The confirmation message shown before permanently deleting an account.")
		}
	}

	// MARK: - Onboarding Placeholders
	/// The username field placeholder during sign-up.
	///
	/// - Tag: L10n-onboardingUsernamePlaceholder
	static var onboardingUsernamePlaceholder: String {
		L10n.resolve {
			String(
				localized: "Username: pick a cool one 🙈",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The username field placeholder during sign-up."
			)
		}
	}
	/// The email field placeholder during sign-up.
	///
	/// - Tag: L10n-onboardingSignUpEmailPlaceholder
	static var onboardingSignUpEmailPlaceholder: String {
		L10n.resolve {
			String(
				localized: "Email: we all forget our passwords 🙉",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The email field placeholder during sign-up."
			)
		}
	}
	/// The password field placeholder during sign-up.
	///
	/// - Tag: L10n-onboardingSignUpPasswordPlaceholder
	static var onboardingSignUpPasswordPlaceholder: String {
		L10n.resolve {
			String(
				localized: "Password: make it super secret 🙊",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The password field placeholder during sign-up."
			)
		}
	}
	/// The email field placeholder during sign-in.
	///
	/// - Tag: L10n-onboardingSignInEmailPlaceholder
	static var onboardingSignInEmailPlaceholder: String {
		L10n.resolve {
			String(
				localized: "Your cool email address 🙌",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The email field placeholder during sign-in."
			)
		}
	}
	/// The password field placeholder during sign-in.
	///
	/// - Tag: L10n-onboardingSignInPasswordPlaceholder
	static var onboardingSignInPasswordPlaceholder: String {
		L10n.resolve {
			String(
				localized: "Your super secret password 👀",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The password field placeholder during sign-in."
			)
		}
	}
	/// The email field placeholder during password reset.
	///
	/// - Tag: L10n-onboardingResetEmailPlaceholder
	static var onboardingResetEmailPlaceholder: String {
		L10n.resolve {
			String(
				localized: "Your email address to the rescue 💌",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The email field placeholder during password reset."
			)
		}
	}
	/// The footer explaining how the Kurozora account is used during onboarding.
	///
	/// - Tag: L10n-onboardingFooter
	static var onboardingFooter: String {
		L10n.resolve {
			String(
				localized: "Your Kurozora Account information is used to enable Kurozora services when you sign in. Kurozora services includes the library where you can keep track of the shows you are interested in.",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer explaining how the Kurozora account is used during onboarding."
			)
		}
	}

	// MARK: - Library Import
	/// The import bar button on the library import screen.
	///
	/// - Tag: L10n-importButton
	static var importButton: String {
		L10n.resolve {
			String(
				localized: "Import 📲",
				table: "Account",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The import bar button on the library import screen."
			)
		}
	}
}
