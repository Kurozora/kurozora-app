//
//  Trans.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

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
	/// The headline string for sign up alert.
	///
	/// - Tag: Trans-signUpAlertHeadline
	static let signUpAlertHeadline: String = String(localized: "Hooray!",
													comment: "The headline string for sign up alert.")
	/// The subheadline string for sign up alert.
	///
	/// - Tag: Trans-signUpAlertSubheadline
	static let signUpAlertSubheadline: String = String(localized: "Account created successfully! Please check your email for confirmation.",
													   comment: "The subheadline string for sign up alert.")
	/// The headline string for sign up alert.
	///
	/// - Tag: Trans-signUpErrorAlertHeadline
	static let signUpErrorAlertHeadline: String = String(localized: "Can't Sign Up 😔",
														 comment: "The headline string for sign up alert.")
	/// The headline string for signing in.
	///
	/// - Tag: Trans-signInHeadline
	static let signInHeadline: String = String(localized: "Kurozora Account",
											   table: "Onboarding",
											   comment: "The headline string for signing in.")
	/// The subheadline string for signing in.
	///
	/// - Tag: Trans-signInSubheadline
	static let signInSubheadline: String = String(localized: "Sign in with your Kurozora Account to use the library and other Kurozora services.",
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
	static let siwaSubheadline: String = String(localized: "Finish setting up your account and join the community.",
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
	static let forgotPasswordSubheadline: String = String(localized: "Enter your Kurozora Account to continue.",
														  table: "Onboarding",
														  comment: "The subheadline string for resetting password.")
	/// The button string for resetting password.
	///
	/// - Tag: Trans-resetButton
	static let forgotPasswordButton: String = String(localized: "Send ✨",
													 table: "Onboarding",
													 comment: "The button string for resetting password.")
	/// The headline string for resetting password alert.
	///
	/// - Tag: Trans-forgotPasswordAlertHeadline
	static let forgotPasswordAlertHeadline: String = String(localized: "Success!",
															comment: "The headline string for resetting password alert.")
	/// The subheadline string for resetting password alert.
	///
	/// - Tag: Trans-forgotPasswordAlertSubheadline
	static let forgotPasswordAlertSubheadline: String = String(localized: "If an account exists with this Kurozora Account, you should receive an email with your reset link shortly.",
															   comment: "The subheadline string for resetting password alert.")
	/// The headline string for resetting password alert.
	///
	/// - Tag: Trans-forgotPasswordErrorAlertHeadline
	static let forgotPasswordErrorAlertHeadline: String = String(localized: "Errr...",
																 comment: "The headline string for resetting password alert.")
	/// The subheadline string for resetting password alert.
	///
	/// - Tag: Trans-forgotPasswordErrorAlertSubheadline
	static let forgotPasswordErrorAlertSubheadline: String = String(localized: "Please type a valid Kurozora Account 😣",
																	comment: "The subheadline string for resetting password alert.")

	// MARK: - Library Delete
	/// The headline string for the Library Delete view.
	///
	/// - Tag: Trans-libraryDeleteHeadline
	static let libraryDeleteHeadline: String = String(localized: "Delete Library",
													  table: "Services",
													  comment: "The headline string for the Library Delete view")
	/// The subheadline string for the Library Delete view.
	///
	/// - Tag: Trans-libraryDeleteSubheadline
	static let libraryDeleteSubheadline: String = String(localized: "Permanently delete your library.",
														 table: "Services",
														 comment: "The subheadline string for the Library Delete view.")
	/// The footer string for the Library Delete view.
	///
	/// - Tag: Trans-libraryDeleteFooter
	static let libraryDeleteFooter: String = String(localized: "Once your library is deleted, all of its resources and data will be permanently deleted. This includes ratings, favorites, reminders, watched episodes, and You will be asked for your password to confirm the deletion.",
													table: "Services",
													comment: "The footer string for the Library Delete view.")

	// MARK: - Library Import
	/// The placeholder string for selecting the import service.
	///
	/// Tag: Trans-selectService
	static let selectService: String = String(localized: "Select service",
											  table: "Services",
											  comment: "The placeholder string for selecting the import service.")
	/// The placeholder string for selecting the import behavior.
	///
	/// Tag: Trans-selectBehavior
	static let selectBehavior: String = String(localized: "Select behavior",
											   table: "Services",
											   comment: "The placeholder string for selecting the import behavior.")
	/// The button string for selecting a file to import.
	///
	/// - Tag: Trans-selectFile
	static let selectFile: String = String(localized: "Select File",
										   table: "Services",
										   comment: "The button string for selecting a file to import.")
	/// The placeholder string for the library xml file name.
	///
	/// - Tag: Trans-libraryXML
	static let libraryXML: String = String(localized: "Library.xml",
										   table: "Services",
										   comment: "The placeholder string for the library xml file name.")
	/// The headline string for the Library Import view.
	///
	/// - Tag: Trans-libraryImportHeadline
	static let libraryImportHeadline: String = String(localized: "Move From Another Service",
													  table: "Services",
													  comment: "The headline string for the Library Import view")
	/// The subheadline string for the Library Import view.
	///
	/// - Tag: Trans-libraryImportSubheadline
	static let libraryImportSubheadline: String = String(localized: "If you have an export of your anime or manga library from other services, such as MyAnimeList, you can select it below.",
														 table: "Services",
														 comment: "The subheadline string for the Library Import view.")
	/// The footer string for the Library Import view.
	///
	/// - Tag: Trans-libraryImportFooter
	static let libraryImportFooter: String = String(localized: "Kurozora does not guarantee all shows and mangas will be imported to your library. Once the request has been processed, a notification which contains the status of the import request will be sent. Furthermore, the uploaded file is deleted as soon as the import request has been processed.\n\nSelecting \"overwrite\" will replace your Kurozora library with the imported one from the file.\nSelecting \"merge\" will add missing items to your Kurozora library. If an item exists then the tracking information in your Kurozora library will be updated with the imported one from the file.",
													table: "Services",
													comment: "The footer string for the Library Import view.")

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
	static let redeemFooter: String = String(localized: "Redeeming a code will unlock special badges and achievements, as well as increase your reputation points. Please keep in mind Kurozora codes are redeemable only once per account and expire after one use.",
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
	/// The string for the phrase 'Kurozora & Privacy'.
	///
	/// - Tag: Trans-kurozoraAndPrivacy
	static let kurozoraAndPrivacy: String = String(localized: "Kurozora & Privacy",
												   table: "Legal",
												   comment: "The string for the phrase 'Kurozora & Privacy'.")
	/// The string for the word terms of use.
	///
	/// - Tag: Trans-termsOfUse
	static let termsOfUse: String = String(localized: "Terms of Use",
										   table: "Legal",
										   comment: "The string for the word terms of use.")
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
		return ThemeAttributedStringPicker {
			let attributedString = NSMutableAttributedString(string: Trans.forMoreInfo, attributes: [.foregroundColor: KThemePicker.subTextColor.colorValue, .paragraphStyle: paragraphStyle])
			attributedString.append(NSAttributedString(string: Trans.privacyPolicy, attributes: [.foregroundColor: KThemePicker.tintColor.colorValue, .paragraphStyle: paragraphStyle]))
			return attributedString
		}
	}()

	// MARK: - Authentication
	/// The string for authenticating immediately.
	///
	/// - Tag: Trans-immediately
	static let immediately: String = String(localized: "Immediately",
											table: "Authentication",
											comment: "The string for authenticating immediately.")
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

	// MARK: - Episodes
	/// The string for the 'Up Next' view title.
	///
	/// - Tag: Trans-upNext
	static let upNext: String = String(localized: "Up Next",
									   table: "Episodes",
									   comment: "The string for the 'Up Next' view title.")
	/// The string for the 'Go To' bar button item.
	///
	/// - Tag: Trans-goTo
	static let goTo: String = String(localized: "Go To",
									 table: "Episodes",
									 comment: "The string for the 'Go To' context menu option.")
	/// The string for the 'Go to first episode' context menu option.
	///
	/// - Tag: Trans-goToFirstEpisode
	static let goToFirstEpisode: String = String(localized: "Go to first episode",
												 table: "Episodes",
												 comment: "The string for the 'Go to first episode' context menu option.")
	/// The string for the 'Go to last episode' context menu option.
	///
	/// - Tag: Trans-goToLastEpisode
	static let goToLastEpisode: String = String(localized: "Go to last episode",
												table: "Episodes",
												comment: "The string for the 'Go to last episode' context menu option.")
	/// The string for the 'Go to last watched episode' context menu option.
	///
	/// - Tag: Trans-goToLastWatchedEpisode
	static let goToLastWatchedEpisode: String = String(localized: "Go to last watched episode",
													   table: "Episodes",
													   comment: "The string for the 'Go to last watched episode' context menu option.")
	/// The string for the 'Show fillers' context menu option.
	///
	/// - Tag: Trans-showFillers
	static let showFillers: String = String(localized: "Show fillers",
											table: "Episodes",
											comment: "The string for the 'Show fillers' context menu option.")
	/// The string for the 'Hide fillers' context menu option.
	///
	/// - Tag: Trans-hideFillers
	static let hideFillers: String = String(localized: "Hide fillers",
											table: "Episodes",
											comment: "The string for the 'Hide fillers' context menu option.")

	// MARK: - Feed
	/// The placeholder string for creating a new feed message.
	///
	/// - Tag: Trans-whatsOnYourMind
	static let whatsOnYourMind: String = String(localized: "What’s on your mind?",
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
	/// The headline string for the pin message pop-up.
	///
	/// - Tag: Trans-pinMessageHeadline
	static let pinMessageHeadline: String = String(localized: "Pin this message",
												   table: "Feed",
												   comment: "The headline string for the pin message pop-up")
	/// The subheadline string for the pin message pop-up.
	///
	/// - Tag: Trans-pinMessageSubheadline
	static let pinMessageSubheadline: String = String(localized: "This will appear at the top of your profile and replace any previously pinned message. Are you sure?",
													  table: "Feed",
													  comment: "The subheadline string for the pin message pop-up")
	/// The headline string for the unpin message pop-up.
	///
	/// - Tag: Trans-unpinMessageHeadline
	static let unpinMessageHeadline: String = String(localized: "Unpin from your profile",
													 table: "Feed",
													 comment: "The headline string for the unpin message pop-up")
	/// The subheadline string for the unpin message pop-up.
	///
	/// - Tag: Trans-unpinMessageSubheadline
	static let unpinMessageSubheadline: String = String(localized: "Are you sure?",
														table: "Feed",
														comment: "The subheadline string for the unpin message pop-up")
	/// The headline string for the reshare message error pop-up.
	///
	/// - Tag: Trans-reshareMessageErrorHeadline
	static let reshareMessageErrorHeadline: String = String(localized: "Can't Re-Share",
															table: "Feed",
															comment: "The headline string for the reshare message error pop-up")
	/// The subheadline string for the reshare message error pop-up.
	///
	/// - Tag: Trans-reshareMessageErrorSubheadline
	static let reshareMessageErrorSubheadline: String = String(localized: "You are not allowed to re-share a message more than once.",
															   table: "Feed",
															   comment: "The subheadline string for the reshare message error pop-up")
	/// The subheadline string for the delete message pop-up.
	///
	/// - Tag: Trans-deleteMessageSubheadline
	static let deleteMessageSubheadline: String = String(localized: "Message will be deleted permanently.",
														 table: "Feed",
														 comment: "The subheadline string for the delete message pop-up")
	/// The subheadline string for blocking a user.
	///
	/// - Tag: Trans-blockMessageSubheadline
	static let blockMessageSubheadline: String = String(localized: "They will be able to see your public messages, but will no longer be able to engange with them. They will also not be able to follow or message you, and you wil not see notifications from them.",
														table: "Feed",
														comment: "The subheadline string for the blocing a user")
	/// The headline string for the report message pop-up.
	///
	/// - Tag: Trans-messageReportedHeadline
	static let messageReportedHeadline: String = String(localized: "Message Reported",
														table: "Feed",
														comment: "The headline string for the report message pop-up")
	/// The subheadline string for the report message pop-up.
	///
	/// - Tag: Trans-messageReportedSubheadline
	static let messageReportedSubheadline: String = String(localized: "Thank you for helping keep the community safe.",
														   table: "Feed",
														   comment: "The subheadline string for the report message pop-up")
	/// The string for the 'Show Profile' context menu option.
	///
	/// - Tag: Trans-showProfile
	static let showProfile: String = String(localized: "Show Profile",
											table: "Feed",
											comment: "The string for the 'Show Profile' context menu option.")
	/// The string for the 'Reply' context menu option.
	///
	/// - Tag: Trans-reply
	static let reply: String = String(localized: "Reply",
									  table: "Feed",
									  comment: "The string for the 'Reply' context menu option.")
	/// The string for the 'Re-share' context menu option.
	///
	/// - Tag: Trans-reshare
	static let reshare: String = String(localized: "Re-share",
										table: "Feed",
										comment: "The string for the 'Re-share' context menu option.")
	/// The string for the 'Post Message' context menu option.
	///
	/// - Tag: Trans-postMessage
	static let postMessage: String = String(localized: "Post Message",
											table: "Feed",
											comment: "The string for the 'Post Message' context menu option.")
	/// The string for the 'Delete Message' context menu option.
	///
	/// - Tag: Trans-deleteMessage
	static let deleteMessage: String = String(localized: "Delete Message",
											  table: "Feed",
											  comment: "The string for the 'Delete Message' context menu option.")
	/// The string for the 'Show Replies' context menu option.
	///
	/// - Tag: Trans-showReplies
	static let showReplies: String = String(localized: "Show Replies",
											table: "Feed",
											comment: "The string for the 'Show Replies' context menu option.")
	/// The string for the 'Share Message' context menu option.
	///
	/// - Tag: Trans-shareMessage
	static let shareMessage: String = String(localized: "Share Message",
											 table: "Feed",
											 comment: "The string for the 'Share Message' context menu option.")
	/// The string for the 'Report Message' context menu option.
	///
	/// - Tag: Trans-reportMessage
	static let reportMessage: String = String(localized: "Report Message",
											  table: "Feed",
											  comment: "The string for the 'Report Message' context menu option.")

	// MARK: - Review
	/// The headline string for the report review pop-up.
	///
	/// - Tag: Trans-reviewReportedHeadline
	static let reviewReportedHeadline: String = String(localized: "Review Reported",
													   table: "Review",
													   comment: "The headline string for the report review pop-up")
	/// The subheadline string for the report review pop-up.
	///
	/// - Tag: Trans-reviewReportedSubheadline
	static let reviewReportedSubheadline: String = String(localized: "Thank you for helping keep the community safe.",
														  table: "Review",
														  comment: "The subheadline string for the report review pop-up")
	/// The subheadline string for the delete review pop-up.
	///
	/// - Tag: Trans-deleteReviewSubheadline
	static let deleteReviewSubheadline: String = String(localized: "Review will be deleted permanently.",
														table: "Review",
														comment: "The subheadline string for the delete review pop-up")
	/// The string for the 'Delete Review' context menu option.
	///
	/// - Tag: Trans-deleteReview
	static let deleteReview: String = String(localized: "Delete Review",
											 table: "Review",
											 comment: "The string for the 'Delete Review' context menu option.")
	/// The string for the 'Share Review' context menu option.
	///
	/// - Tag: Trans-shareReview
	static let shareReview: String = String(localized: "Share Review",
											table: "Review",
											comment: "The string for the 'Share Review' context menu option.")
	/// The string for the 'Report Review' context menu option.
	///
	/// - Tag: Trans-reportReview
	static let reportReview: String = String(localized: "Report Review",
											 table: "Review",
											 comment: "The string for the 'Report Review' context menu option.")

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

	// MARK: - Episode
	/// The string for the 'see also' section.
	///
	/// - Tag: Trans-seeAlso
	static let seeAlso: String = String(localized: "See Also",
										table: "Episode",
										comment: "The string for the 'see also' section.")

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

	// MARK: - Rating
	/// The string for the rating failed title.
	///
	/// - Tag: Trans-ratingFailed
	static let ratingFailed: String = String(localized: "Rating Failed",
											 table: "Rating",
											 comment: "The string for the 'rating failed' section.")
	/// The string for can't save review description.
	///
	/// - Tag: Trans-cantSaveReview
	static let cantSaveReview: String = String(localized: "Can’t Save Review 😔",
											   table: "Rating",
											   comment: "The string for can't save review description.")
	/// The string for the rating submitted description.
	///
	/// - Tag: Trans-thankYouForRating
	static let thankYouForRating: String = String(localized: "Thank you for rating.",
												  table: "Rating",
												  comment: "The string for the rating submitted description.")

	// MARK: - Sessions
	/// The string for the 'current session' section.
	///
	/// - Tag: Trans-currentSession
	static let currentSession: String = String(localized: "Current Session",
											   table: "Sessions",
											   comment: "The string for the 'current session' section.")
	/// The string for the 'other session' section.
	///
	/// - Tag: Trans-otherSessions
	static let otherSessions: String = String(localized: "Other Sessions",
											  table: "Sessions",
											  comment: "The string for the 'other sessions' section.")
	/// The string for 'this device'.
	///
	/// - Tag: Trans-thisDevice
	static let thisDevice: String = String(localized: "This device",
										   table: "Sessions",
										   comment: "The string for 'this device'.")

	// MARK: - Settings
	/// The title string or the 'App Icon' settings.
	///
	/// - Tag: Trans-appIcon
	static let appIcon: String = String(localized: "App Icon",
										table: "Settings",
										comment: "The title string or the 'App Icon' settings.")
	/// The title string or the 'Theme Store' settings.
	///
	/// - Tag: Trans-themeStore
	static let themeStore: String = String(localized: "Theme Store",
										   table: "Settings",
										   comment: "The title string or the 'Theme Store Grouping' settings.")
	/// The title string or the 'Notification Grouping' settings.
	///
	/// - Tag: Trans-notificationGrouping
	static let notificationGrouping: String = String(localized: "Notification Grouping",
													 table: "Settings",
													 comment: "The title string or the 'Notification Grouping' settings.")
	/// The title string or the 'Timezone' settings.
	///
	/// - Tag: Trans-timezone
	static let timezone: String = String(localized: "Timezone",
										 table: "Settings",
										 comment: "The title string or the 'Timezone' settings.")
	/// The headline string for the account settings option.
	///
	/// - Tag: Trans-accountHeadline
	static let accountHeadline: String = String(localized: "Sign in to your Kurozora account",
												table: "Settings",
												comment: "The headline string for the account settings option.")
	/// The sub-headline string for the account settings option when not signed in.
	///
	/// - Tag: Trans-accountSignedInSubheadline
	static let accountSubheadline: String = String(localized: "Setup Kurozora Account and more.",
												   table: "Settings",
												   comment: "The sub-headline string for the account settings option when not signed in.")
	/// The sub-headline string for the account settings option when signed in.
	///
	/// - Tag: Trans-accountSignedInSubheadline
	static let accountSignedInSubheadline: String = String(localized: "Kurozora Account, Sign in with Apple & Library Import",
														   table: "Settings",
														   comment: "The sub-headline string for the account settings option when signed in.")
	/// The string for the 'Switch Account' settings option.
	///
	/// - Tag: Trans-switchAccount
	static let switchAccount: String = String(localized: "Switch Account",
											  table: "Settings",
											  comment: "The string for the 'Switch Account' settings option.")
	/// The string for the 'Keys Manager' settings option.
	///
	/// - Tag: Trans-keysManager
	static let keysManager: String = String(localized: "Keys Manager",
											table: "Settings",
											comment: "The string for the 'Keys Manager' settings option.")
	/// The string for the 'Subscribe to Reminders' settings option.
	///
	/// - Tag: Trans-subscribeToReminders
	static let subscribeToReminders: String = String(localized: "Subscribe to Reminders",
													 table: "Settings",
													 comment: "The string for the 'Subscribe to Reminders' settings option.")
	/// The string for the 'Sound' settings option.
	///
	/// - Tag: Trans-sound
	static let sound: String = String(localized: "Sound",
									  table: "Settings",
									  comment: "The string for the 'Sound' settings option.")
	/// The string for the 'Sounds & Haptics' settings option.
	///
	/// - Tag: Trans-soundsAndHaptics
	static let soundsAndHaptics: String = String(localized: "Sounds & Haptics",
												 table: "Settings",
												 comment: "The string for the 'Sounds & Haptics' settings option.")
	/// The string for the 'Display & Blindness' settings option.
	///
	/// - Tag: Trans-displayBlindness
	static let displayBlindness: String = String(localized: "Display & Blindness",
												 table: "Settings",
												 comment: "The string for the 'Display & Blindness' settings option.")
	/// The string for the 'Face ID & Passcode' settings option.
	///
	/// - Tag: Trans-faceIDPasscode
	static let faceIDPasscode: String = String(localized: "Face ID & Passcode",
											   table: "Settings",
											   comment: "The string for the 'Face ID & Passcode' settings option.")
	/// The string for the 'Touch ID & Passcode' settings option.
	///
	/// - Tag: Trans-touchIDPasscode
	static let touchIDPasscode: String = String(localized: "Touch ID & Passcode",
												table: "Settings",
												comment: "The string for the 'Touch ID & Passcode' settings option.")
	/// The string for the 'Optic ID & Passcode' settings option.
	///
	/// - Tag: Trans-opticIDPasscode
	static let opticIDPasscode: String = String(localized: "Optic ID & Passcode",
												table: "Settings",
												comment: "The string for the 'Optic ID & Passcode' settings option.")
	/// The string for the 'Unlock Features' settings option.
	///
	/// - Tag: Trans-unlockFeatures
	static let unlockFeatures: String = String(localized: "Unlock Features",
											   table: "Settings",
											   comment: "The string for the 'Unlock Features' settings option.")
	/// The string for the 'Tip Jar' settings option.
	///
	/// - Tag: Trans-tipJar
	static let tipJar: String = String(localized: "Tip Jar",
									   table: "Settings",
									   comment: "The string for the 'Tip Jar' settings option.")
	/// The string for the 'Restore Purchase' settings option.
	///
	/// - Tag: Trans-restorePurchase
	static let restorePurchase: String = String(localized: "Restore Purchase",
												table: "Settings",
												comment: "The string for the 'Restore Purchase' settings option.")
	/// The string for the 'Request Refund' settings option.
	///
	/// - Tag: Trans-requestRefund
	static let requestRefund: String = String(localized: "Request Refund",
											  table: "Settings",
											  comment: "The string for the 'Request Refund' settings option.")
	/// The string for the 'Add Sticker to Signal' settings option.
	///
	/// - Tag: Trans-addStickerToSignal
	static let addStickerToSignal: String = String(localized: "Add Sticker to Signal",
												   table: "Settings",
												   comment: "The string for the 'Add Sticker to Signal' settings option.")
	/// The string for the 'Add Sticker to Telegram' settings option.
	///
	/// - Tag: Trans-addStickerToTelegram
	static let addStickerToTelegram: String = String(localized: "Add Sticker to Telegram",
													 table: "Settings",
													 comment: "The string for the 'Add Sticker to Telegram' settings option.")
	/// The string for the 'Rate us on App Store' settings option.
	///
	/// - Tag: Trans-rateAppStore
	static let rateAppStore: String = String(localized: "Rate us on App Store",
											 table: "Settings",
											 comment: "The string for the 'Rate us on App Store' settings option.")
	/// The string for the 'Join our Discord Community' settings option.
	///
	/// - Tag: Trans-joinDiscord
	static let joinDiscord: String = String(localized: "Join our Discord Community",
											table: "Settings",
											comment: "The string for the 'Join our Discord Community' settings option.")
	/// The string for the 'Follow our story on Medium' settings option.
	///
	/// - Tag: Trans-followGitHub
	static let followGitHub: String = String(localized: "Follow us on GitHub",
											 table: "Settings",
											 comment: "The string for the 'Follow us on GitHub' settings option.")
	/// The string for the 'Follow us on Mastodon' settings option.
	///
	/// - Tag: Trans-followMastodon
	static let followMastodon: String = String(localized: "Follow us on Mastodon",
											   table: "Settings",
											   comment: "The string for the 'Follow us on Mastodon' settings option.")
	/// The string for the 'Follow us on Twitter' settings option.
	///
	/// - Tag: Trans-followTwitter
	static let followTwitter: String = String(localized: "Follow us on Twitter",
											  table: "Settings",
											  comment: "The string for the 'Follow us on Twitter' settings option.")

	// MARK: - Motion Settings
	/// The string for the 'Animations' settings header.
	///
	/// - Tag: Trans-animations
	static let animations: String = String(localized: "Animations",
										   table: "Motion Settings",
										   comment: "The string for the 'Animations' settings header.")
	/// The string for the 'Splash Screen' settings option.
	///
	/// - Tag: Trans-splashScreen
	static let splashScreen: String = String(localized: "Splash Screen",
											 table: "Motion Settings",
											 comment: "The string for the 'Splash Screen' settings option.")
	/// The string for the 'Reduce Motion' settings option.
	///
	/// - Tag: Trans-reduceMotion
	static let reduceMotion: String = String(localized: "Reduce Motion",
											 table: "Motion Settings",
											 comment: "The string for the 'Reduce Motion' settings option.")
	/// The string for the 'Sync With Device Settings' settings option.
	///
	/// - Tag: Trans-syncWithDeviceSettings
	static let syncWithDeviceSettings: String = String(localized: "Sync With Device Settings",
													   table: "Motion Settings",
													   comment: "The string for the 'Sync With Device Settings' settings option.")
	/// The footer string for the 'Reduce Motion' settings option.
	///
	/// - Tag: Trans-reduceMotionFooter
	static let reduceMotionFooter: String = String(localized: "Reduce the intensity of animations, and motion effects throughout Kurozora.",
												   table: "Sounds & Haptics",
												   comment: "The footer string for the 'Reduce Motion' settings option.")

	// MARK: - Sounds & Haptics
	/// The string for the 'Chime Sound' settings option.
	///
	/// - Tag: Trans-chimeSound
	static let chimeSound: String = String(localized: "Chime Sound",
										   table: "Sounds & Haptics",
										   comment: "The string for the 'Chime Sound' settings option.")
	/// The string for the 'Chime on Startup' settings option.
	///
	/// - Tag: Trans-chimeOnStartup
	static let chimeOnStartup: String = String(localized: "Chime on Startup",
											   table: "Sounds & Haptics",
											   comment: "The string for the 'Chime on Startup' settings option.")
	/// The string for the 'User Interface Sounds' settings option.
	///
	/// - Tag: Trans-uiSounds
	static let uiSounds: String = String(localized: "User Interface Sounds",
										 table: "Sounds & Haptics",
										 comment: "The string for the 'User Interface Sounds' settings option.")
	/// The string for the 'Haptics' settings option.
	///
	/// - Tag: Trans-haptics
	static let haptics: String = String(localized: "Haptics",
										table: "Sounds & Haptics",
										comment: "The string for the 'Haptics' settings option.")
	/// The footer string for the haptics settings option.
	///
	/// - Tag: Trans-hapticsFooter
	static let hapticsFooter: String = String(localized: "Turning off haptics will only affect custom haptics. Default system controls, like the switches above, will still have a haptic feedback. You can disable all haptics in the Settings app.",
											  table: "Sounds & Haptics",
											  comment: "The footer string for the haptics settings option.")

	// MARK: - Misc
	/// The string for the word 'today'.
	///
	/// - Tag: Trans-today
	static let today: String = String(localized: "Today",
									  comment: "The string for the word 'today'.")
	/// The string for the word 'submitted'.
	///
	/// - Tag: Trans-submitted
	static let submitted: String = String(localized: "Submitted",
										  comment: "The string for the word 'submitted'.")
	/// The string for the word 'add'.
	///
	/// - Tag: Trans-add
	static let add: String = String(localized: "Add",
									comment: "The string for the word 'add'.")
	/// The string for the word 'apply'.
	///
	/// - Tag: Trans-apply
	static let apply: String = String(localized: "Apply",
									  comment: "The string for the word 'apply'.")
	/// The string for the word 'reset'.
	///
	/// - Tag: Trans-reset
	static let reset: String = String(localized: "Reset",
									  comment: "The string for the word 'reset'.")
	/// The string for the word 'discover'.
	///
	/// - Tag: Trans-discover
	static let discover: String = String(localized: "Discover",
										 comment: "The string for the word 'discover'.")
	/// The string for the word 'browse'.
	///
	/// - Tag: Trans-browse
	static let browse: String = String(localized: "Browse",
									   comment: "The string for the word 'browse'.")
	/// The string for the word 'browse genres'.
	///
	/// - Tag: Trans-browseGenres
	static let browseGenres: String = String(localized: "Browse Genres",
											 comment: "The string for the word 'browse genres'.")
	/// The string for the word 'browse themes'.
	///
	/// - Tag: Trans-browseThemes
	static let browseThemes: String = String(localized: "Browse Themes",
											 comment: "The string for the word 'browse themes'.")
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
	/// The string for the word 'number'.
	///
	/// - Tag: Trans-number
	static let number: String = String(localized: "Number",
									   comment: "The string for the word 'number'.")
	/// The string for the word 'duration'.
	///
	/// - Tag: Trans-duration
	static let duration: String = String(localized: "Duration",
										 comment: "The string for the word 'duration'.")
	/// The string for the word 'aired'.
	///
	/// - Tag: Trans-aired
	static let aired: String = String(localized: "Aired",
									  comment: "The string for the word 'aired'.")
	/// The string for the word 'tba'.
	///
	/// - Tag: Trans-tba
	static let tba: String = String(localized: "TBA",
									comment: "The string for the word 'tba'.")
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
	/// The string for the word 'episodes'.
	///
	/// - Tag: Trans-episodes
	static let episodes: String = String(localized: "Episodes",
										 comment: "The string for the word 'episodes'.")
	/// The string for the word 'people'.
	///
	/// - Tag: Trans-people
	static let people: String = String(localized: "People",
									   comment: "The string for the word 'people'.")
	/// The string for the word 'more'.
	///
	/// - Tag: Trans-more
	static let more: String = String(localized: "More",
									 comment: "The string for the word 'more'.")
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
	/// The string for the word 'measurements'.
	///
	/// - Tag: Trans-measurements
	static let measurements: String = String(localized: "Measurements",
											 comment: "The string for the word 'measurements'.")
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
	/// The string for the word 'socials'.
	///
	/// - Tag: Trans-socials
	static let socials: String = String(localized: "Socials",
										comment: "The string for the word 'socials'.")
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
	/// The string for the word 'following'.
	///
	/// - Tag: Trans-following
	static let following: String = String(localized: "Following",
										  comment: "The string for the word 'following'.")
	/// The string for the word 'follow'.
	///
	/// - Tag: Trans-follow
	static let follow: String = String(localized: "Follow",
									   comment: "The string for the word 'follow'.")
	/// The string for the word 'unfollow'.
	///
	/// - Tag: Trans-unfollow
	static let unfollow: String = String(localized: "Unfollow",
										 table: "Feed",
										 comment: "The string for the word 'unfollow'.")
	/// The string for the word 'block'.
	///
	/// - Tag: Trans-block
	static let block: String = String(localized: "Block",
									  table: "Feed",
									  comment: "The string for the word 'block'.")
	/// The string for the word 'unpin'.
	///
	/// - Tag: Trans-unpin
	static let unpin: String = String(localized: "Unpin",
									  table: "Feed",
									  comment: "The string for the word 'unpin'.")
	/// The string for the word 'pin'.
	///
	/// - Tag: Trans-pin
	static let pin: String = String(localized: "Pin",
									table: "Feed",
									comment: "The string for the word 'pin'.")
	/// The string for the word 'unlike'.
	///
	/// - Tag: Trans-unlike
	static let unlike: String = String(localized: "Unlike",
									   table: "Feed",
									   comment: "The string for the word 'unlike'.")
	/// The string for the word 'like'.
	///
	/// - Tag: Trans-like
	static let like: String = String(localized: "Like",
									 table: "Feed",
									 comment: "The string for the word 'like'.")
	/// The string for the word 'edit'.
	///
	/// - Tag: Trans-edit
	static let edit: String = String(localized: "Edit",
									 table: "Feed",
									 comment: "The string for the word 'edit'.")
	/// The string for the word 'delete'.
	///
	/// - Tag: Trans-delete
	static let delete: String = String(localized: "Delete",
									   table: "Feed",
									   comment: "The string for the word 'delete'.")
	/// The string for the word 'report'.
	///
	/// - Tag: Trans-report
	static let report: String = String(localized: "Report",
									   table: "Feed",
									   comment: "The string for the word 'report'.")
	/// The string for the word 'message'.
	///
	/// - Tag: Trans-message
	static let message: String = String(localized: "Message",
										comment: "The string for the word 'message'.")
	/// The string for the word 'catalog'.
	///
	/// - Tag: Trans-catalog
	static let catalog: String = String(localized: "Catalog",
										comment: "The string for the word 'catalog'.")
	/// The string for the word 'library'.
	///
	/// - Tag: Trans-library
	static let library: String = String(localized: "Library",
										comment: "The string for the word 'library'.")
	/// The string for the word 'your library'.
	///
	/// - Tag: Trans-yourLibrary
	static let yourLibrary: String = String(localized: "Your Library",
											comment: "The string for the word 'your library'.")
	/// The string for the word 'add to library'.
	///
	/// - Tag: Trans-addToLibrary
	static let addToLibrary: String = String(localized: "Add to Library",
											 comment: "The string for the word 'add to library'.")
	/// The string for the word 'update library status'.
	///
	/// - Tag: Trans-updateLibraryStatus
	static let updateLibraryStatus: String = String(localized: "Update Library Status",
													comment: "The string for the word 'update library status'.")
	/// The string for the word 'remove from library'.
	///
	/// - Tag: Trans-removeFromLibrary
	static let removeFromLibrary: String = String(localized: "Remove from Library",
												  comment: "The string for the word 'remove from library'.")
	/// The string for the word 'Can’t delete library 😔'.
	///
	/// - Tag: Trans-removeFromLibrary
	static let cantDeleteLibrary: String = String(localized: "Can’t delete library 😔",
												  comment: "The string for the sentence 'Can’t delete library 😔'.")
	/// The string for the phrase 'Delete Permanently'.
	///
	/// - Tag: Trans-deletePermanently
	static let deletePermanently: String = String(localized: "Delete Permanently",
												  comment: "The string for the phrase 'Delete Permanently'.")
	/// The string for the phrase 'hide from public'.
	///
	/// - Tag: Trans-hideFromPublic
	static let hideFromPublic: String = String(localized: "Hide from Public",
											   comment: "The string for the phrase 'hide from public'.")
	/// The string for the phrase 'show to public'.
	///
	/// - Tag: Trans-showToPublic
	static let showToPublic: String = String(localized: "Show to Public",
											 comment: "The string for the phrase 'show to public'.")
	/// The string for the word 'watched'.
	///
	/// - Tag: Trans-watched
	static let watched: String = String(localized: "Watched",
										comment: "The string for the word 'watched'.")
	/// The string for the phrase 'mark as watched'.
	///
	/// - Tag: Trans-markAsWatched
	static let markAsWatched: String = String(localized: "Mark as Watched",
											  comment: "The string for the phrase 'mark as watched'.")
	/// The string for the phrase 'mark as unwatched'.
	///
	/// - Tag: Trans-markAsUnwatched
	static let markAsUnwatched: String = String(localized: "Mark as Unwatched",
												comment: "The string for the phrase 'mark as unwatched'.")
	/// The string for the phrase 'mark all watched'.
	///
	/// - Tag: Trans-markAllWatched
	static let markAllWatched: String = String(localized: "Mark All Watched",
											   comment: "The string for the phrase 'mark all watched'.")
	/// The string for the phrase 'mark all unwatched'.
	///
	/// - Tag: Trans-markAllUnwatched
	static let markAllUnwatched: String = String(localized: "Mark All Unwatched",
												 comment: "The string for the phrase 'mark all unwatched'.")
	/// The string for the phrase 'Mark all'.
	///
	/// - Tag: Trans-markAll
	static let markAll: String = String(localized: "Mark all",
										comment: "The string for the phrase 'Mark all'.")
	/// The string for the phrase 'Mark all as read'.
	///
	/// - Tag: Trans-markAllAsRead
	static let markAllAsRead: String = String(localized: "Mark all as read",
											  comment: "The string for the phrase 'Mark all as read'.")
	/// The string for the phrase 'Mark all as unread'.
	///
	/// - Tag: Trans-markAllAsUnread
	static let markAllAsUnread: String = String(localized: "Mark all as unread",
												comment: "The string for the phrase 'Mark all as unread'.")
	/// The string for the phrase 'Mark as read'.
	///
	/// - Tag: Trans-markAsRead
	static let markAsRead: String = String(localized: "Mark as read",
										   comment: "The string for the phrase 'Mark as read'.")
	/// The string for the phrase 'Mark as unread'.
	///
	/// - Tag: Trans-markAsUnread
	static let markAsUnread: String = String(localized: "Mark as unread",
											 comment: "The string for the phrase 'Mark as unread'.")
	/// The string for the word 'next'.
	///
	/// - Tag: Trans-next
	static let next: String = String(localized: "Next",
									 comment: "The string for the word 'next'.")
	/// The string for the word 'previous'.
	///
	/// - Tag: Trans-previous
	static let previous: String = String(localized: "Previous",
										 comment: "The string for the word 'previous'.")
	/// The string for the word 'chart'.
	///
	/// - Tag: Trans-chart
	static let chart: String = String(localized: "Chart",
									  comment: "The string for the word 'chart'.")
	/// The string for the word 'anime'.
	///
	/// - Tag: Trans-anime
	static let anime: String = String(localized: "Anime",
									  comment: "The string for the word 'anime'.")
	/// The string for the word 'literatures'.
	///
	/// - Tag: Trans-literatures
	static let literatures: String = String(localized: "Literatures",
											comment: "The string for the word 'literatures'.")
	/// The string for the word 'game'.
	///
	/// - Tag: Trans-games
	static let games: String = String(localized: "Games",
									  comment: "The string for the word 'games'.")
	/// The string for the word 'user'.
	///
	/// - Tag: Trans-user
	static let user: String = String(localized: "User",
									 comment: "The string for the word 'user'.")
	/// The string for the word 'users'.
	///
	/// - Tag: Trans-users
	static let users: String = String(localized: "Users",
									  comment: "The string for the word 'users'.")
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
	/// The string for the word 'profile'.
	///
	/// - Tag: Trans-profile
	static let profile: String = String(localized: "Profile",
										comment: "The string for the word 'profile'.")
	/// The string for the word 'stickers'.
	///
	/// - Tag: Trans-stickers
	static let stickers: String = String(localized: "Stickers",
										 comment: "The string for the word 'stickers'.")
	/// The string for the word 'security'.
	///
	/// - Tag: Trans-security
	static let security: String = String(localized: "Security",
										 comment: "The string for the word 'security'.")
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
	/// The string for the word 'motion'.
	///
	/// - Tag: Trans-motion
	static let motion: String = String(localized: "Motion",
									   comment: "The string for the word 'motion'.")
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
	/// The string for the word 'defunct'.
	///
	/// - Tag: Trans-defunct
	static let defunct: String = String(localized: "Defunct",
										comment: "The string for the word 'defunct'.")
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
	/// The string for the word 'schedule'.
	///
	/// - Tag: Trans-schedule
	static let schedule: String = String(localized: "Schedule",
										 comment: "The string for the word 'schedule'.")
	/// The string for the word 'feed'.
	///
	/// - Tag: Trans-feed
	static let feed: String = String(localized: "Feed",
									 comment: "The string for the word 'feed'.")
	/// The string for the word 'reviews'.
	///
	/// - Tag: Trans-reviews
	static let reviews: String = String(localized: "Reviews",
										comment: "The string for the word 'reviews'.")
	/// The string for the word 'search'.
	///
	/// - Tag: Trans-search
	static let search: String = String(localized: "Search",
									   comment: "The string for the word 'search'.")
	/// The string for the word 'sort'.
	///
	/// - Tag: Trans-sort
	static let sort: String = String(localized: "Sort",
									 comment: "The string for the word 'sort'.")
	/// The string for the word 'filter'.
	///
	/// - Tag: Trans-filter
	static let filter: String = String(localized: "Filter",
									   comment: "The string for the word 'filter'.")
	/// The string for the word 'filters'.
	///
	/// - Tag: Trans-filters
	static let filters: String = String(localized: "Filters",
										comment: "The string for the word 'filters'.")
	/// The string for the word 'settings'.
	///
	/// - Tag: Trans-settings
	static let settings: String = String(localized: "Settings",
										 comment: "The string for the word 'settings'.")
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
	/// The string for the word 'remove'.
	///
	/// - Tag: Trans-remove
	static let remove: String = String(localized: "Remove",
									   comment: "The string for the word 'remove'.")
	/// The string for the word 'share'.
	///
	/// - Tag: Trans-share
	static let share: String = String(localized: "Share",
									  comment: "The string for the word 'share'.")
	/// The string for the word 'update'.
	///
	/// - Tag: Trans-update
	static let update: String = String(localized: "Update!",
									   comment: "The string for the word 'update'.")
	/// The string for the word 'reconnect'.
	///
	/// - Tag: Trans-reconnect
	static let reconnect: String = String(localized: "Reconnect!",
										  comment: "The string for the word 'reconnect'.")
	/// The string for the word 'Lyrics'.
	///
	/// - Tag: Trans-lyrics
	static let lyrics: String = String(localized: "Lyrics",
									   comment: "The string for the word 'Lyrics'.")
	/// The string for the word 'asHeardOn'.
	///
	/// - Tag: Trans-asHeardOn
	static let asHeardOn: String = String(localized: "As Heard On",
										  comment: "The string for the word 'As Heard On'.")
	/// The string for the word 'view on Amazon Music'.
	///
	/// - Tag: Trans-viewOnAmazonMusic
	static let viewOnAmazonMusic: String = String(localized: "View on Amazon Music",
												  comment: "The string for the word 'View on Amazon Music'.")
	/// The string for the word 'view on Apple Music'.
	///
	/// - Tag: Trans-viewOnAppleMusic
	static let viewOnAppleMusic: String = String(localized: "View on Apple Music",
												 comment: "The string for the word 'View on Apple Music'.")
	/// The string for the word 'view on Deezer'.
	///
	/// - Tag: Trans-viewOnDeezer
	static let viewOnDeezer: String = String(localized: "View on Deezer",
											 comment: "The string for the word 'View on Deezer'.")
	/// The string for the word 'view on Spotify'.
	///
	/// - Tag: Trans-viewOnSpotify
	static let viewOnSpotify: String = String(localized: "View on Spotify",
											  comment: "The string for the word 'View on Spotify'.")
	/// The string for the word 'view on YouTube'.
	///
	/// - Tag: Trans-viewOnYouTube
	static let viewOnYouTube: String = String(localized: "View on YouTube",
											  comment: "The string for the word 'View on YouTube'.")
	/// The string for the word 'preview'.
	///
	/// - Tag: Trans-preview
	static let preview: String = String(localized: "Preview",
										comment: "The string for the word 'preview'.")
	/// The string for the word 'play'.
	///
	/// - Tag: Trans-play
	static let play: String = String(localized: "Play",
									 comment: "The string for the word 'play'.")
	/// The string for the word 'pauze'.
	///
	/// - Tag: Trans-pauze
	static let pauze: String = String(localized: "Pauze",
									  comment: "The string for the word 'pauze'.")
	/// The string for the word 'stop'.
	///
	/// - Tag: Trans-stop
	static let stop: String = String(localized: "Stop",
									 comment: "The string for the word 'stop'.")
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
	/// The string for the word 'coming soon'.
	///
	/// - Tag: Trans-comingSoon
	static let comingSoon: String = String(localized: "Coming Soon",
										   comment: "The string for the word 'coming soon'.")
	/// The string for the word 'expected'.
	///
	/// - Tag: Trans-expected
	static let expected: String = String(localized: "Expected",
										 comment: "The string for the word 'expected'.")
	/// The string for the word 'achievements'.
	///
	/// - Tag: Trans-achievements
	static let achievements: String = String(localized: "Achievements",
											 comment: "The string for the word 'achievements'.")
	/// The string for the word 'badges'.
	///
	/// - Tag: Trans-badges
	static let badges: String = String(localized: "Badges",
									   comment: "The string for the word 'badges'.")
	/// The string for the word 'rank'.
	///
	/// - Tag: Trans-rank
	static let rank: String = String(localized: "Rank",
									 comment: "The string for the word 'rank'.")
	/// The string for the word 'language'.
	///
	/// - Tag: Trans-language
	static let language: String = String(localized: "Languages",
										 comment: "The string for the word 'language'.")
	/// The string for the word 'country'.
	///
	/// - Tag: Trans-country
	static let country: String = String(localized: "Country",
										comment: "The string for the word 'country'.")
	/// The string for the word 'tv rating'.
	///
	/// - Tag: Trans-tvRating
	static let tvRating: String = String(localized: "TV Rating",
										 comment: "The string for the word 'TV rating'.")
	/// The string for the word 'seasons'.
	///
	/// - Tag: Trans-seasons
	static let seasons: String = String(localized: "Seasons",
										comment: "The string for the word 'seasons'.")
	/// The string for the word 'season'.
	///
	/// - Tag: Trans-season
	static let season: String = String(localized: "Season",
									   comment: "The string for the word 'season'.")
	/// The string for the word 'studios'.
	///
	/// - Tag: Trans-studios
	static let studios: String = String(localized: "Studios",
										comment: "The string for the word 'studios'.")
	/// The string for the word 'studio'.
	///
	/// - Tag: Trans-studio
	static let studio: String = String(localized: "Studio",
									   comment: "The string for the word 'studio'.")
	/// The string for the word 'successor'.
	///
	/// - Tag: Trans-successor
	static let successor: String = String(localized: "Successor",
										  comment: "The string for the word 'successor'.")
	/// The string for the word 'cast'.
	///
	/// - Tag: Trans-cast
	static let cast: String = String(localized: "Cast",
									 comment: "The string for the word 'cast'.")
	/// The string for the word 'songs'.
	///
	/// - Tag: Trans-songs
	static let songs: String = String(localized: "Songs",
									  comment: "The string for the word 'songs'.")
	/// The string for the word 'more by'.
	///
	/// - Tag: Trans-moreBy
	static let moreBy: String = String(localized: "More by",
									   comment: "The string for the word 'more by'.")
	/// The string for the word 'related shows'.
	///
	/// - Tag: Trans-relatedShows
	static let relatedShows: String = String(localized: "Related Shows",
											 comment: "The string for the word 'related shows'.")
	/// The string for the word 'related literatures'.
	///
	/// - Tag: Trans-relatedLiteratures
	static let relatedLiteratures: String = String(localized: "Related Literatures",
												   comment: "The string for the word 'related literatures'.")
	/// The string for the word 'related games'.
	///
	/// - Tag: Trans-relatedGames
	static let relatedGames: String = String(localized: "Related Games",
											 comment: "The string for the word 'related games'.")
	/// The string for the word 'copyright'.
	///
	/// - Tag: Trans-copyright
	static let copyright: String = String(localized: "Copyright",
										  comment: "The string for the word 'copyright'.")
	/// The string for the word 'Open Twitter'.
	///
	/// - Tag: Trans-openTwitter
	static let openTwitter: String = String(localized: "Open Twitter",
											comment: "The string for the word 'Open Twitter'.")
	/// The string for the word 'Redeem'.
	///
	/// - Tag: Trans-redeem
	static let redeem: String = String(localized: "Redeem",
									   comment: "The string for the word 'Redeem'.")
	/// The string for the word 'View Subscription'.
	///
	/// - Tag: Trans-viewSubscription
	static let viewSubscription: String = String(localized: "View Subscription",
												 comment: "The string for the word 'View Subscription'.")
	/// The string for the word 'Become a Subscriber'.
	///
	/// - Tag: Trans-becomeASubscriber
	static let becomeASubscriber: String = String(localized: "Become a Subscriber",
												  comment: "The string for the word 'Become a Subscriber'.")
	/// The string for the word 'Continue'.
	///
	/// - Tag: Trans-continue
	static let `continue`: String = String(localized: "Continue",
										   comment: "The string for the word 'Continue'.")
	/// The string for the word 'What’s New'.
	///
	/// - Tag: Trans-whatsNew
	static let whatsNew: String = String(localized: "What’s New in Kurozora",
										 comment: "The string for the word 'What’s New'.")
	/// The string for the word 'Favorites'.
	///
	/// - Tag: Trans-favorites
	static let favorites: String = String(localized: "Favorites",
										  comment: "The string for the word 'Favorites'")
	/// The string for the word 'My Favorites'.
	///
	/// - Tag: Trans-myFavorites
	static let myFavorites: String = String(localized: "My Favorites",
											comment: "The string for the word 'My Favorites'")
	/// The string for the word 'Reminders'.
	///
	/// - Tag: Trans-reminders
	static let reminders: String = String(localized: "Reminders",
										  comment: "The string for the word 'Reminders'")
	/// The string for the word 'Remind Me'.
	///
	/// - Tag: Trans-remindMe
	static let remindMe: String = String(localized: "Remind Me",
										 comment: "The string for the word 'Remind Me'")
	/// The string for the word 'My Reminders'.
	///
	/// - Tag: Trans-myReminders
	static let myReminders: String = String(localized: "My Reminders",
											comment: "The string for the word 'My Reminders'")

	// MARK: - Ratings
	/// The string for the word 'ratings'.
	///
	/// - Tag: Trans-ratings
	static let ratings: String = String(localized: "Ratings",
										comment: "The string for the word 'ratings'.")
	/// The string for the word 'rating'.
	///
	/// - Tag: Trans-rating
	static let rating: String = String(localized: "Rating",
									   comment: "The string for the word 'rating'.")
	/// The string for the word 'ratings & reviews'.
	///
	/// - Tag: Trans-ratingsAndReviews
	static let ratingsAndReviews: String = String(localized: "Ratings & Reviews",
												  comment: "The string for the word 'ratings & reviews'.")
	/// The string for the word 'tap to rate'.
	///
	/// - Tag: Trans-tapToRate
	static let tapToRate: String = String(localized: "Tap to Rate:",
										  comment: "The string for the word 'tap to rate'.")
	/// The string for the word 'click to rate'.
	///
	/// - Tag: Trans-clickToRate
	static let clickToRate: String = String(localized: "Click to Rate:",
											comment: "The string for the word 'click to rate'.")
	/// The string for the word 'write a review'.
	///
	/// - Tag: Trans-writeAReview
	static let writeAReview: String = String(localized: "Write a Review",
											 comment: "The string for the word 'write a review'.")

	// MARK: - ReCap
	/// The string for the word 'Re:Cap'.
	///
	/// - Tag: Trans-reCAP
	static let reCAP: String = String(localized: "Re:CAP",
									  comment: "The string for the word 'Re:CAP'.")
	/// The string for the word 'Milestones'.
	///
	/// - Tag: Trans-milestones
	static let milestones: String = String(localized: "Milestones",
										   comment: "The string for the word 'Milestones'.")
	/// The string for the word 'Top %@'.
	///
	/// - Tag: Trans-topX
	static func top(_ string: String) -> String {
		return String(localized: "Top \(string)",
					  comment: "The string for the word 'Top %@'.")
	}

	/// The string for the word '%@ total series'.
	///
	/// - Tag: Trans-totalSeries
	static func totalSeries(_ string: String) -> String {
		return String(localized: "\(string) total series",
					  comment: "The string for the word '%@ total series'.")
	}

	// MARK: - Warnings
	/// The string for the no signal warning title.
	///
	/// - Tag: Trans-noSignalTitle
	static let noSignalTitle: String = String(localized: "Network Unavailable",
											  comment: "The string for the no signal warning title.")
	/// The string for the no signal warning message.
	///
	/// - Tag: Trans-noSignalMessage
	static let noSignalMessage: String = String(localized: "You must connect to a Wi-Fi network or have a cellular data plan to use Kurozora.",
												comment: "The string for the no signal warning message.")
	/// The string for the force update warning title.
	///
	/// - Tag: Trans-forceUpdateTitle
	static let forceUpdateTitle: String = String(localized: "Update Available",
												 comment: "The string for the force update warning title.")
	/// The string for the force update warning message.
	///
	/// - Tag: Trans-forceUpdateMessage
	static let forceUpdateMessage: String = String(localized: "Kurozora was updated with breaking changes. To avoid the app from crashing, you must update it to continue using it as usual. The update should be available soon on the App Store.",
												   comment: "The string for the force update warning message.")
	/// The string for the maintenance warning title.
	///
	/// - Tag: Trans-maintenanceModeTitle
	static let maintenanceModeTitle: String = String(localized: "Scheduled Maintenance",
													 comment: "The string for the maintenance warning title.")
	/// The string for the maintenance warning message.
	///
	/// - Tag: Trans-maintenanceModeMessage
	static let maintenanceModeMessage: String = String(localized: "Kurozora is currently under maintenance. All services will be available shortly. If this continues for more than an hour, you can follow the status on Twitter.",
													   comment: "The string for the maintenance warning message.")
}
