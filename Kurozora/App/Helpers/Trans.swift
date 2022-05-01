//
//  Trans.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation
import SwiftTheme

/// - Tag: Trans
struct Trans {
	// MARK: - Onboarding
	/// The headline string for signing up.
	///
	/// - Tag: Trans-signUpHeadline
	static let signUpHeadline: String = String(localized: "New to Kurozora?",
											   table: "Onboarding",
											   comment: "The headline string for signing up.")
	/// The subheadline string for signing up.
	///
	/// - Tag: Trans-signUpSubheadline
		static let signUpSubheadline: String = String(localized: "Create an account and join the community.",
													  table: "Onboarding",
													  comment: "")
	/// The button string for signing up.
	///
	/// - Tag: Trans-signUpButton
	static let signUpButton: String = String(localized: "Join 🤗",
											 table: "Onboarding",
											 comment: "The button string for signing up.")
	/// The headline string for signing in.
	///
	/// - Tag: Trans-signInHeadline
	static let signInHeadline: String = String(localized: "Kurozora ID",
											   table: "Onboarding",
											   comment: "The headline string for signing in.")
	/// The subheadline string for signing in.
	///
	/// - Tag: Trans-signInSubheadline
	static let signInSubheadline: String = String(localized: "Sign in with your Kurozora ID to use the library and other Kurozora services.",
												  table: "Onboarding",
												  comment: "The subheadline string for signing in.")
	/// The button string for signing in.
	///
	/// - Tag: Trans-signInButton
	static let signInButton: String = String(localized: "Open sesame 👐",
											 table: "Onboarding",
											 comment: "The button string for signing in.")
	/// The headline string for Sign in with Apple.
	///
	/// - Tag: Trans-siwaHeadline
	static let siwaHeadline: String = String(localized: "Setup Account",
											 table: "Onboarding",
											 comment: "The headline string for Sign in with Apple.")
	/// The subheadline string for Sign in with Apple.
	///
	/// - Tag: Trans-siwaSubheadline
	static let siwaSubheadline: String = String(localized: "Finish setting up your account and join the comminty.",
												table: "Onboarding",
												comment: "")
	/// The button string for sign in with Apple.
	///
	/// - Tag: Trans-siwaButton
	static let siwaButton: String = String(localized: "Join 🤗",
										   table: "Onboarding",
										   comment: "The button string for sign in with Apple.")
	/// The headline string for resetting password.
	///
	/// - Tag: Trans-forgotPasswordHeadline
	static let forgotPasswordHeadline: String = String(localized: "Forgot Password?",
													   table: "Onboarding",
													   comment: "The headline string for resetting password.")
	/// The subheadline string for resetting password.
	///
	/// - Tag: Trans-forgotPasswordSubheadline
	static let forgotPasswordSubheadline: String = String(localized: "Enter your Kurozora ID to continue.",
														  table: "Onboarding",
														  comment: "The subheadline string for resetting password.")
	/// The button string for resetting password.
	///
	/// - Tag: Trans-resetButton
	static let forgotPasswordButton: String = String(localized: "Send ✨",
													 table: "Onboarding",
													 comment: "The button string for resetting password.")

	// MARK: - MAL
	/// The headline string for the MAL Improt view.
	///
	/// - Tag: Trans-malImportHeadline
	static let malImportHeadline: String = String(localized: "Move from MyAnimeList",
												  table: "Services",
												  comment: "The headline string for the MAL Improt view")
	/// The subheadline string for the MAL Improt view.
	///
	/// - Tag: Trans-malImportSubheadline
	static let malImportSubheadline: String = String(localized: "If you have an export of your anime library from MyAnimeList you can select it below.",
													 table: "Services",
													 comment: "The subheadline string for the MAL Improt view.")
	/// The footer string for the MAL Improt view.
	///
	/// - Tag: Trans-malImportFooter
	static let malImportFooter: String = String(localized: "Kurozora does not guarantee all shows will be imported to your library. Once the request has been processed a notification which contains the status of the import request will be sent. Furthermore the uploaded file is deleted as soon as the import request has been processed.",
												table: "Services",
												comment: "The footer string for the MAL Improt view.")

	// MARK: - Redeem
	/// The headline string for the Redeem view.
	///
	/// - Tag: Trans-redeemHeadline
	static let redeemHeadline: String = String(localized: "Redeem your code using the camera on your device.",
											   table: "Redeem",
											   comment: "The headline string for the Redeem view.")
	/// The subheadline string for the Redeem view.
	///
	/// - Tag: Trans-redeemSubheadline
	static let redeemSubheadline: String = String(localized: "Found a Kurozora code in the wild? This is the place to redeem it!",
												  table: "Redeem",
												  comment: "The subheadline string for the Redeem view.")
	/// The footer string for the Redeem view.
	///
	/// - Tag: Trans-redeemFooter
	static let redeemFooter: String = String(localized: "Redeeming a code will immediately apply the credits onto your account. Please keep in mind Kurozora codes are redeemable only once per account and expire after one use.",
											 table: "Redeem",
											 comment: "The footer string for the Redeem view.")
	/// The headline string for the redeem error pop-up.
	///
	/// - Tag: Trans-redeemErrorHeadline
	static let redeemErrorHeadline: String = String(localized: "Error Redeeming Code",
													table: "Redeem",
													comment: "The headline string for the redeem error pop-up.")
	/// The subheadline string for the redeem error pop-up.
	///
	/// - Tag: Trans-redeemErrorSubheadline
	static let redeemErrorSubheadline: String = String(localized: "The code entered is not valid.",
													   table: "Redeem",
													   comment: "The subheadline string for the redeem error pop-up.")
	/// The headline string for the redeem processing pop-up.
	///
	/// - Tag: Trans-redeemProcessingHeadline
	static let redeemProcessingHeadline: String = String(localized: "Processing redeem code.",
														 table: "Redeem",
														 comment: "The headline string for the redeem processing pop-up.")
	/// The headline string for the redeem success pop-up.
	///
	/// - Tag: Trans-redeemSuccessHeadline
	static let redeemSuccessHeadline: String = String(localized: "Zoop, badoop, fruitloop!",
													  table: "Redeem",
													  comment: "The headline string for the redeem success pop-up.")
	/// The subheadline string for the redeem success pop-up.
	///
	/// - Tag: Trans-redeemSuccessSubheadline
	static let redeemSuccessSubheadline: String = String(localized: "%d was successfully redeemed 🤩",
														 table: "Redeem",
														 comment: "The subheadline string for the redeem success pop-up.")

	// MARK: - SiwA
	/// The headline string for the Sign in with Apple view.
	///
	/// - Tag: Trans-signInWithAppleHeadline
	static let signInWithAppleHeadline: String = String(localized: "Start using Sign in with Apple",
														table: "Services",
														comment: "The headline string for the Sign in with Apple view.")
	/// The subheadline string for the Sign in with Apple view.
	///
	/// - Tag: Trans-signInWithAppleSubheadline
	static let signInWithAppleSubheadline: String = String(localized: "Sign in with Apple is the fast, easy way for you to sign in to Kurozora using the Apple ID you already have.",
														   table: "Services",
														   comment: "The subheadline string for the Sign in with Apple view.")
	/// The footer string for the Sign in with Apple view.
	///
	/// - Tag: Trans-signInWithAppleFooter
	static let signInWithAppleFooter: String = String(localized: "Kurozora offers Sign in with Apple for users who want the extra peace of mind when it comes to security and privacy. Sign in with Apple is a convenient way to sign in to apps and sites while having more control over the information you share. Kurozora is restricted to asking only for your name and email address, and Apple won’t track your app activity or build a profile of you.",
													  table: "Services",
													  comment: "The footer string for the Sign in with Apple view.")

	// MARK: - In-App Purchases
	/// The message string for the product not found.
	///
	/// - Tag: Trans-productIDsNotSet
	static let productIDsNotSet: String = String(localized: "Product ids not set, call setProductIDs method!",
												 table: "IAP",
												 comment: "The message string for the product not found.")
	/// The message string for IAP is disabled.
	///
	/// - Tag: Trans-iapDisabled
	static let iapDisabled: String = String(localized: "You are not authorized to make payments. In-App Purchases may be restricted on your device.",
											table: "IAP",
											comment: "The message string for IAP is disabled.")
	/// The message string for restoring IAP has failed.
	///
	/// - Tag: Trans-iapRestoreFailed
	static let iapRestoreFailed: String = String(localized: "There are no restorable purchases.\nOnly previously bought non-consumable products and auto-renewable subscriptions can be restored.",
												 table: "IAP",
												 comment: "The message string for restoring IAP has failed.")
	/// The message string for restoring IAP has succeeded.
	///
	/// - Tag: Trans-iapRestoreSucceeded
	static let iapRestoreSucceeded: String = String(localized: "All purchases have been restored.\nPlease remember that only previously bought non-consumable products and auto-renewable subscriptions can be restored.",
													table: "IAP",
													comment: "The message string for restoring IAP has succeeded.")
	// MARK: - Subscription
	/// The footer string for the Subscription view.
	///
	/// - Tag: Trans-subscriptionFooter
	static let subscriptionFooter: String = String(localized: "Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.",
												   table: "IAP",
												   comment: "The footer string for the Subscription view.")
	/// The string for the 'manage subscriptions' settings option.
	///
	/// - Tag: Trans-manageSubscriptions
	static let manageSubscriptions: String = String(localized: "Manage Subscriptions",
													table: "IAP",
													comment: "The string for the 'manage subscriptions' settings option.")

	// MARK: - Tip Jar
	/// The footer string for the Tip Jar view.
	///
	/// - Tag: Trans-tipJarFooter
	static let tipJarFooter: String = String(localized: "Payment will be charged to your Apple ID account at the confirmation of purchase. Unlike Kurozora+ subscription, tips are a one time purchase. Your account will be charged only once every time you tip.",
											 table: "IAP",
											 comment: "The footer string for the Tip Jar view.")

	// MARK: - Privacy Policy
	/// The string for the word privacy policy.
	///
	/// - Tag: Trans-privacyPolicy
	static let privacyPolicy: String = String(localized: "Privacy Policy",
											  table: "Legal",
											  comment: "The string for the word privacy policy.")
	/// The footer string to visit privacy policy.
	///
	/// - Tag: Trans-forMoreInfo
	static let forMoreInfo: String = String(localized: "For more information, please visit our ",
											table: "Legal",
											comment: "The footer string to visit privacy policy.")
	/// The footer string to visit privacy policy.
	///
	/// - Tag: Trans-visitPrivacyPolicy
	static var visitPrivacyPolicy: ThemeAttributedStringPicker = {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		let themeAttributedString = ThemeAttributedStringPicker {
			let attributedString = NSMutableAttributedString(string: Trans.forMoreInfo, attributes: [.foregroundColor: KThemePicker.subTextColor.colorValue, .paragraphStyle: paragraphStyle])
			attributedString.append(NSAttributedString(string: Trans.privacyPolicy, attributes: [.foregroundColor: KThemePicker.tintColor.colorValue, .paragraphStyle: paragraphStyle]))
			return attributedString
		}
		return themeAttributedString
	}()

	// MARK: - Authentication
	/// The string for authenticating immediatly.
	///
	/// - Tag: Trans-immediately
	static let immediately: String = String(localized: "Immediately",
											table: "Authentication",
											comment: "The string for authenticating immediatly.")
	/// The string for authenticating after 30 seconds.
	///
	/// - Tag: Trans-thirtySeconds
	static let thirtySeconds: String = String(localized: "30 Seconds",
											  table: "Authentication",
											  comment: "The string for authenticating after 30 seconds.")
	/// The string for authenticating after 1 minute.
	///
	/// - Tag: Trans-oneMinute
	static let oneMinute: String = String(localized: "1 Minute",
										  table: "Authentication",
										  comment: "The string for authenticating after 1 minute.")
	/// The string for authenticating after 2 minutes.
	///
	/// - Tag: Trans-twoMinutes
	static let twoMinutes: String = String(localized: "2 Minutes",
										   table: "Authentication",
										   comment: "The string for authenticating after 2 minutes.")
	/// The string for authenticating after 3 minutes.
	///
	/// - Tag: Trans-threeMinutes
	static let threeMinutes: String = String(localized: "3 Minutes",
											 table: "Authentication",
											 comment: "The string for authenticating after 3 minutes.")
	/// The string for authenticating after 4 minutes.
	///
	/// - Tag: Trans-fourMinutes
	static let fourMinutes: String = String(localized: "4 Minutes",
											table: "Authentication",
											comment: "The string for authenticating after 4 minutes.")
	/// The string for authenticating after 5 minutes.
	///
	/// - Tag: Trans-fiveMinutes
	static let fiveMinutes: String = String(localized: "5 Minutes",
											table: "Authentication",
											comment: "The string for authenticating after 5 minutes.")

	// MARK: - Feed
	/// The placeholder string for creating a new feed message.
	///
	/// - Tag: Trans-whatsOnYourMind
	static let whatsOnYourMind: String = String(localized: "What's on your mind...",
												table: "Feed",
												comment: "The placeholder string for creating a new feed message.")
	/// The placeholder string for creating a new comment.
	///
	/// - Tag: Trans-writeAComment
	static let writeAComment: String = String(localized: "Write a comment...",
											  table: "Feed",
											  comment: "The placeholder string for creating a new comment.")
	/// The headline string for the character limit reached error pop-up.
	///
	/// - Tag: Trans-characterLimitReachedHeadline
	static let characterLimitReachedHeadline: String = String(localized: "Limit Reached",
															  table: "Feed",
															  comment: "The headline string for the character limit reached error pop-up")
	/// The subheadline string for the character limit reached error pop-up.
	///
	/// - Tag: Trans-characterLimitReachedSubheadline
	static let characterLimitReachedSubheadline: String = String(localized: "You have exceeded the character limit for a message.",
																 table: "Feed",
																 comment: "The subheadline string for the character limit reached error pop-up")

	// MARK: - Theme
	/// The string for default theme description.
	///
	/// - Tag: Trans-defaultThemeDescription
	static let defaultThemeDescription: String = String(localized: "The official Kurozora theme.",
														table: "Theme",
														comment: "The string for default theme description.")
	/// The string for day theme description.
	///
	/// - Tag: Trans-dayThemeDescription
	static let dayThemeDescription: String = String(localized: "Rise and shine.",
													table: "Theme",
													comment: "The string for day theme description.")
	/// The string for night theme description.
	///
	/// - Tag: Trans-nightThemeDescription
	static let nightThemeDescription: String = String(localized: "Easy on the eyes.",
													  table: "Theme",
													  comment: "The string for night theme description.")
	/// The string for grass theme description.
	///
	/// - Tag: Trans-grassThemeDescription
	static let grassThemeDescription: String = String(localized: "Get off my lawn!",
													  table: "Theme",
													  comment: "The string for grass theme description.")
	/// The string for sky theme description.
	///
	/// - Tag: Trans-skyThemeDescription
	static let skyThemeDescription: String = String(localized: "Cloudless.",
													table: "Theme",
													comment: "The string for sky theme description.")
	/// The string for sakura theme description.
	///
	/// - Tag: Trans-sakuraThemeDescription
	static let sakuraThemeDescription: String = String(localized: "In full bloom.",
													   table: "Theme",
													   comment: "The string for sakura theme description.")

	// MARK: - Browse
	/// The string for the 'top anime' browse option.
	///
	/// - Tag: Trans-topAnime
	static let topAnime: String = String(localized: "Top Anime",
										 table: "Browse",
										 comment: "The string for the 'top anime' browse option.")
	/// The string for the 'top airing' browse option.
	///
	/// - Tag: Trans-topAiring
	static let topAiring: String = String(localized: "Top Airing",
										  table: "Browse",
										  comment: "The string for the 'top airing' browse option.")
	/// The string for the 'top upcoming' browse option.
	///
	/// - Tag: Trans-topUpcoming
	static let topUpcoming: String = String(localized: "Top Upcoming",
											table: "Browse",
											comment: "The string for the 'top upcoming' browse option.")
	/// The string for the 'top tv series' browse option.
	///
	/// - Tag: Trans-topTVSeries
	static let topTVSeries: String = String(localized: "Top TV Series",
											table: "Browse",
											comment: "The string for the 'top tv series' browse option.")
	/// The string for the 'top movies' browse option.
	///
	/// - Tag: Trans-topMovies
	static let topMovies: String = String(localized: "Top Movies",
										  table: "Browse",
										  comment: "The string for the 'top movies' browse option.")
	/// The string for the 'top ova' browse option.
	///
	/// - Tag: Trans-topOVA
	static let topOVA: String = String(localized: "Top OVA",
									   table: "Browse",
									   comment: "The string for the 'top ova' browse option.")
	/// The string for the 'top specials' browse option.
	///
	/// - Tag: Trans-topSpecials
	static let topSpecials: String = String(localized: "Top Specials",
											table: "Browse",
											comment: "The string for the 'top specials' browse option.")
	/// The string for the 'just added' browse option.
	///
	/// - Tag: Trans-justAdded
	static let justAdded: String = String(localized: "Just Added",
										  table: "Browse",
										  comment: "The string for the 'just added' browse option.")
	/// The string for the 'most popular' browse option.
	///
	/// - Tag: Trans-mostPopular
	static let mostPopular: String = String(localized: "Most Popular",
											table: "Browse",
											comment: "The string for the 'most popular' browse option.")
	/// The string for the 'advanced search' browse option.
	///
	/// - Tag: Trans-advancedSearch
	static let advancedSearch: String = String(localized: "Advanced Search",
											   table: "Browse",
											   comment: "The string for the 'advanced search' browse option.")

	// MARK: - Notification
	/// The string for the 'view sessions' notification action.
	///
	/// - Tag: Trans-viewSessions
	static let viewSessions: String = String(localized: "View Sessions",
											 table: "Notification",
											 comment: "The string for the 'view sessions' notification action.")
	/// The string for the 'view show details' notification action.
	///
	/// - Tag: Trans-viewShowDetails
	static let viewShowDetails: String = String(localized: "View Show Details",
												table: "Notification",
												comment: "The string for the 'view show details' notification action.")
	/// The string for the 'view profile' notification action.
	///
	/// - Tag: Trans-viewProfile
	static let viewProfile: String = String(localized: "View Profile",
											table: "Notification",
											comment: "The string for the 'view profile' notification action.")
	/// The string for the 'view message reply' notification action.
	///
	/// - Tag: Trans-viewMessageReply
	static let viewMessageReply: String = String(localized: "View Message Reply",
												 table: "Notification",
												 comment: "The string for the 'view message reply' notification action.")
	/// The string for the 'view message re-share' notification action.
	///
	/// - Tag: Trans-viewShowDetails
	static let viewMessageReShare: String = String(localized: "View Message Re-share",
												   table: "Notification",
												   comment: "The string for the 'view message re-share' notification action.")
	/// The string for the 'subscription update' notification type.
	///
	/// - Tag: Trans-subscriptionUpdate
	static let subscriptionUpdate: String = String(localized: "Subscription Update",
												   table: "Notification",
												   comment: "The string for the 'subscription update' notification type")
	/// The string for the 'new session' notification type.
	///
	/// - Tag: Trans-subscriptionUpdate
	static let newSession: String = String(localized: "New Session",
										   table: "Notification",
										   comment: "The string for the 'new session' notification type")
	/// The string for the 'library import' notification type.
	///
	/// - Tag: Trans-subscriptionUpdate
	static let libraryImport: String = String(localized: "Library Import",
											  table: "Notification",
											  comment: "The string for the 'library import' notification type")

	// MARK: - Settings
	/// The headline string for the account settings option.
	///
	/// - Tag: Trans-accountHeadline
	static let accountHeadline: String = String(localized: "Sign in to your Kurozora account",
												table: "Settings",
												comment: "The headline string for the account settings option.")
	/// The sub-headline string for the account settings option when not signed in.
	///
	/// - Tag: Trans-accountSignedInSubheadline
	static let accountSubheadline: String = String(localized: "Setup Kurozora ID and more.",
												   table: "Settings",
												   comment: "The sub-headline string for the account settings option when not signed in.")
	/// The sub-headline string for the account settings option when signed in.
	///
	/// - Tag: Trans-accountSignedInSubheadline
	static let accountSignedInSubheadline: String = String(localized: "Kurozora ID, Sign in with Apple & MAL Import",
														   table: "Settings",
														   comment: "The sub-headline string for the account settings option when signed in.")
	/// The string for the 'switch account' settings option.
	///
	/// - Tag: Trans-switchAccount
	static let switchAccount: String = String(localized: "Switch Account",
											  table: "Settings",
											  comment: "The string for the 'switch account' settings option.")
	/// The string for the 'keys manager' settings option.
	///
	/// - Tag: Trans-keysManager
	static let keysManager: String = String(localized: "Keys Manager",
											table: "Settings",
											comment: "The string for the 'keys manager' settings option.")
	/// The string for the 'subscribe to reminders' settings option.
	///
	/// - Tag: Trans-subscribeToReminders
	static let subscribeToReminders: String = String(localized: "Subscribe to Reminders",
													 table: "Settings",
													 comment: "The string for the 'subscribe to reminders' settings option.")
	/// The string for the 'display & blindness' settings option.
	///
	/// - Tag: Trans-displayBlindness
	static let displayBlindness: String = String(localized: "Display & Blindness",
												 table: "Settings",
												 comment: "The string for the 'display & blindness' settings option.")

	/// The string for the 'face id & passcode' settings option.
	///
	/// - Tag: Trans-faceIDPasscode
	static let faceIDPasscode: String = String(localized: "Face ID & Passcode",
											   table: "Settings",
											   comment: "The string for the 'face id & passcode' settings option.")
	/// The string for the 'touch id & passcode' settings option.
	///
	/// - Tag: Trans-touchIDPasscode
	static let touchIDPasscode: String = String(localized: "Touch ID & Passcode",
												table: "Settings",
												comment: "The string for the 'touch id & passcode' settings option.")
	/// The string for the 'unlock features' settings option.
	///
	/// - Tag: Trans-unlockfeatures
	static let unlockFeatures: String = String(localized: "Unlock Features",
											   table: "Settings",
											   comment: "The string for the 'unlock features' settings option.")
	/// The string for the 'tip jar' settings option.
	///
	/// - Tag: Trans-tipJar
	static let tipJar: String = String(localized: "Tip Jar",
									   table: "Settings",
									   comment: "The string for the 'tip jar' settings option.")
	/// The string for the 'restore purchase' settings option.
	///
	/// - Tag: Trans-restorePurchase
	static let restorePurchase: String = String(localized: "Restore Purchase",
												table: "Settings",
												comment: "The string for the 'restore purchase' settings option.")
	/// The string for the 'request refund' settings option.
	///
	/// - Tag: Trans-requestRefund
	static let requestRefund: String = String(localized: "Request Refund",
											  table: "Settings",
											  comment: "The string for the 'request refund' settings option.")
	/// The string for the 'rate us on App Store' settings option.
	///
	/// - Tag: Trans-rateAppStore
	static let rateAppStore: String = String(localized: "Rate us on App Store",
											 table: "Settings",
											 comment: "The string for the 'rate us on App Store' settings option.")
	/// The string for the 'join our Discord community' settings option.
	///
	/// - Tag: Trans-joinDiscord
	static let joinDiscord: String = String(localized: "Join our Discord Community",
											table: "Settings",
											comment: "The string for the 'join our Discord community' settings option.")
	/// The string for the 'follow us on Twitter' settings option.
	///
	/// - Tag: Trans-followTwitter
	static let followTwitter: String = String(localized: "Follow us on Twitter",
											  table: "Settings",
											  comment: "The string for the 'follow us on Twitter' settings option.")
	/// The string for the 'follow our story on Medium' settings option.
	///
	/// - Tag: Trans-followMedium
	static let followMedium: String = String(localized: "Follow our story on Medium",
											 table: "Settings",
											 comment: "The string for the 'follow our story on Medium' settings option.")

	// MARK: - Misc
	/// The string for the word 'header'.
	///
	/// - Tag: Trans-header
	static let header: String = String(localized: "Header",
									   comment: "The string for the word 'header'.")
	/// The string for the word 'about'.
	///
	/// - Tag: Trans-about
	static let about: String = String(localized: "About",
									  comment: "The string for the word 'about'.")
	/// The string for the word 'information'.
	///
	/// - Tag: Trans-information
	static let information: String = String(localized: "Information",
											comment: "The string for the word 'information'.")
	/// The string for the word 'shows'.
	///
	/// - Tag: Trans-shows
	static let shows: String = String(localized: "Shows",
									  comment: "The string for the word 'shows'.")
	/// The string for the word 'characters'.
	///
	/// - Tag: Trans-characters
	static let characters: String = String(localized: "Characters",
									  comment: "The string for the word 'characters'.")
	/// The string for the word 'people'.
	///
	/// - Tag: Trans-people
	static let people: String = String(localized: "People",
									   comment: "The string for the word 'people'.")
	/// The string for the word 'debut'.
	///
	/// - Tag: Trans-debut
	static let debut: String = String(localized: "Debut",
									  comment: "The string for the word 'debut'.")
	/// The string for the word 'age'.
	///
	/// - Tag: Trans-age
	static let age: String = String(localized: "Age",
									comment: "The string for the word 'age'.")
	/// The string for the word 'measurments'.
	///
	/// - Tag: Trans-measurments
	static let measurments: String = String(localized: "Measurments",
											comment: "The string for the word 'measurments'.")
	/// The string for the word 'characteristics'.
	///
	/// - Tag: Trans-characteristics
	static let characteristics: String = String(localized: "Characteristics",
												comment: "The string for the word 'characteristics'.")
	/// The string for the word 'aliases'.
	///
	/// - Tag: Trans-aliases
	static let aliases: String = String(localized: "Aliases",
										comment: "The string for the word 'aliases'.")
	/// The string for the word 'websites'.
	///
	/// - Tag: Trans-websites
	static let websites: String = String(localized: "Websites",
										 comment: "The string for the word 'websites'.")
	/// The string for the word 'new'.
	///
	/// - Tag: Trans-new
	static let new: String = String(localized: "New",
									comment: "The string for the word 'new'.")
	/// The string for the word 'off'.
	///
	/// - Tag: Trans-off
	static let off: String = String(localized: "Off",
									comment: "The string for the word 'off'.")
	/// The string for the word 'automatic'.
	///
	/// - Tag: Trans-automatic
	static let automatic: String = String(localized: "Automatic",
										  comment: "The string for the word 'automatic'.")
	/// The string for the word 'by type'.
	///
	/// - Tag: Trans-byType
	static let byType: String = String(localized: "By Type",
									   comment: "The string for the word 'by type'.")
	/// The string for the word 'other'.
	///
	/// - Tag: Trans-other
	static let other: String = String(localized: "Other",
									  comment: "The string for the word 'other'.")
	/// The string for the word 'follower'.
	///
	/// - Tag: Trans-follower
	static let follower: String = String(localized: "Follower",
										 comment: "The string for the word 'follower'.")
	/// The string for the word 'message'.
	///
	/// - Tag: Trans-message
	static let message: String = String(localized: "Message",
										comment: "The string for the word 'message'.")
	/// The string for the word 'anime'.
	///
	/// - Tag: Trans-anime
	static let anime: String = String(localized: "Anime",
									  comment: "The string for the word 'anime'.")
	/// The string for the word 'library'.
	///
	/// - Tag: Trans-library
	static let library: String = String(localized: "Library",
										comment: "The string for the word 'library'.")
	/// The string for the word 'user'.
	///
	/// - Tag: Trans-user
	static let user: String = String(localized: "User",
									 comment: "The string for the word 'user'.")
	/// The string for the word 'account'.
	///
	/// - Tag: Trans-account
	static let account: String = String(localized: "Account",
										comment: "The string for the word 'account'.")
	/// The string for the word 'debug'.
	///
	/// - Tag: Trans-debug
	static let debug: String = String(localized: "Debug",
									  comment: "The string for the word 'debug'.")
	/// The string for the word 'pro'.
	///
	/// - Tag: Trans-pro
	static let pro: String = String(localized: "Pro",
									comment: "The string for the word 'pro'.")
	/// The string for the word 'alerts'.
	///
	/// - Tag: Trans-alerts
	static let alerts: String = String(localized: "Alerts",
									   comment: "The string for the word 'alerts'.")
	/// The string for the word 'general'.
	///
	/// - Tag: Trans-general
	static let general: String = String(localized: "General",
										comment: "The string for the word 'general'.")
	/// The string for the word 'notifications'.
	///
	/// - Tag: Trans-notifications
	static let notifications: String = String(localized: "Notifications",
											  comment: "The string for the word 'notifications'.")
	/// The string for the word 'support us'.
	///
	/// - Tag: Trans-supportUs
	static let supportUs: String = String(localized: "Support Us",
										  comment: "The string for the word 'support us'.")
	/// The string for the word 'social'.
	///
	/// - Tag: Trans-social
	static let social: String = String(localized: "Social",
									   comment: "The string for the word 'social'.")
	/// The string for the word 'theme'.
	///
	/// - Tag: Trans-theme
	static let theme: String = String(localized: "Theme",
									  comment: "The string for the word 'theme'.")
	/// The string for the word 'icon'.
	///
	/// - Tag: Trans-icon
	static let icon: String = String(localized: "Icon",
									 comment: "The string for the word 'icon'.")
	/// The string for the word 'browser'.
	///
	/// - Tag: Trans-browser
	static let browser: String = String(localized: "Browser",
										comment: "The string for the word 'browser'.")
	/// The string for the word 'passcode'.
	///
	/// - Tag: Trans-passcode
	static let passcode: String = String(localized: "Passcode",
										 comment: "The string for the word 'passcode'.")
	/// The string for the word 'cache'.
	///
	/// - Tag: Trans-cache
	static let cache: String = String(localized: "Cache",
									  comment: "The string for the word 'cache'.")
	/// The string for the word 'privacy'.
	///
	/// - Tag: Trans-privacy
	static let privacy: String = String(localized: "Privacy",
										comment: "The string for the word 'privacy'.")
	/// The string for the word 'founded'.
	///
	/// - Tag: Trans-founded
	static let founded: String = String(localized: "Founded",
										comment: "The string for the word 'founded'.")
	/// The string for the word 'headquarters'.
	///
	/// - Tag: Trans-headquarters
	static let headquarters: String = String(localized: "Headquarters",
											 comment: "The string for the word 'headquarters'.")
	/// The string for the word 'synopsis'.
	///
	/// - Tag: Trans-synopsis
	static let synopsis: String = String(localized: "Synopsis",
										 comment: "The string for the word 'synopsis'.")
	/// The string for the word 'explore'.
	///
	/// - Tag: Trans-explore
	static let explore: String = String(localized: "Explore",
										comment: "The string for the word 'explore'.")
	/// The string for the word 'feed'.
	///
	/// - Tag: Trans-feed
	static let feed: String = String(localized: "Feed",
									 comment: "The string for the word 'feed'.")
	/// The string for the word 'search'.
	///
	/// - Tag: Trans-search
	static let search: String = String(localized: "Search",
									   comment: "The string for the word 'search'.")
	/// The string for the word 'subscribe'.
	///
	/// - Tag: Trans-subscribe
	static let subscribe: String = String(localized: "Subscribe",
										  comment: "The string for the word 'subscribe'.")
	/// The string for the word 'send'.
	///
	/// - Tag: Trans-send
	static let send: String = String(localized: "Send",
									 comment: "The string for the word 'send'.")
	/// The string for the word 'discard'.
	///
	/// - Tag: Trans-discard
	static let discard: String = String(localized: "Discard",
										comment: "The string for the word 'discard'.")
	/// The string for the word 'done'.
	///
	/// - Tag: Trans-done
	static let done: String = String(localized: "Done",
									 comment: "The string for the word 'done'.")
	/// The string for the word 'cancel'.
	///
	/// - Tag: Trans-cancel
	static let cancel: String = String(localized: "Cancel",
									   comment: "The string for the word 'cancel'.")
	/// The string for the word 'share'.
	///
	/// - Tag: Trans-share
	static let share: String = String(localized: "Share",
									  comment: "The string for the word 'share'.")
	/// The string for the word 'password'.
	///
	/// - Tag: Trans-password
	static let password: String = String(localized: "Password",
										 comment: "The string for the word 'password'.")
	/// The string for the word 'download'.
	///
	/// - Tag: Trans-download
	static let download: String = String(localized: "Download",
										 comment: "The string for the word 'download'.")
}
