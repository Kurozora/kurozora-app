//
//  L10n+Settings.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

extension L10n {
	// MARK: - Theme
	/// The string for default theme description.
	///
	/// - Tag: L10n-defaultThemeDescription
	static let defaultThemeDescription: String = String(
		localized: "The official Kurozora theme.",
		table: "Settings",
		comment: "The string for default theme description."
	)
	/// The string for day theme description.
	///
	/// - Tag: L10n-dayThemeDescription
	static let dayThemeDescription: String = String(
		localized: "Rise and shine.",
		table: "Settings",
		comment: "The string for day theme description."
	)
	/// The string for night theme description.
	///
	/// - Tag: L10n-nightThemeDescription
	static let nightThemeDescription: String = String(
		localized: "Easy on the eyes.",
		table: "Settings",
		comment: "The string for night theme description."
	)
	/// The string for grass theme description.
	///
	/// - Tag: L10n-grassThemeDescription
	static let grassThemeDescription: String = String(
		localized: "Get off my lawn!",
		table: "Settings",
		comment: "The string for grass theme description."
	)
	/// The string for sky theme description.
	///
	/// - Tag: L10n-skyThemeDescription
	static let skyThemeDescription: String = String(
		localized: "Cloudless.",
		table: "Settings",
		comment: "The string for sky theme description."
	)
	/// The string for sakura theme description.
	///
	/// - Tag: L10n-sakuraThemeDescription
	static let sakuraThemeDescription: String = String(
		localized: "In full bloom.",
		table: "Settings",
		comment: "The string for sakura theme description."
	)

	// MARK: - Notification
	/// The string for the 'view sessions' notification action.
	///
	/// - Tag: L10n-viewSessions
	static let viewSessions: String = String(
		localized: "View Sessions",
		table: "Settings",
		comment: "The string for the 'view sessions' notification action."
	)
	/// The string for the 'view show details' notification action.
	///
	/// - Tag: L10n-viewShowDetails
	static let viewShowDetails: String = String(
		localized: "View Show Details",
		table: "Settings",
		comment: "The string for the 'view show details' notification action."
	)
	/// The string for the 'view profile' notification action.
	///
	/// - Tag: L10n-viewProfile
	static let viewProfile: String = String(
		localized: "View Profile",
		table: "Settings",
		comment: "The string for the 'view profile' notification action."
	)
	/// The string for the 'view message reply' notification action.
	///
	/// - Tag: L10n-viewMessageReply
	static let viewMessageReply: String = String(
		localized: "View Message Reply",
		table: "Settings",
		comment: "The string for the 'view message reply' notification action."
	)
	/// The string for the 'view message re-share' notification action.
	///
	/// - Tag: L10n-viewMessageReShare
	static let viewMessageReShare: String = String(
		localized: "View Message Re-share",
		table: "Settings",
		comment: "The string for the 'view message re-share' notification action."
	)
	/// The string for the 'subscription update' notification type.
	///
	/// - Tag: L10n-subscriptionUpdate
	static let subscriptionUpdate: String = String(
		localized: "Subscription Update",
		table: "Settings",
		comment: "The string for the 'subscription update' notification type"
	)
	/// The string for the 'new session' notification type.
	///
	/// - Tag: L10n-newSession
	static let newSession: String = String(
		localized: "New Session",
		table: "Settings",
		comment: "The string for the 'new session' notification type"
	)
	/// The string for the 'library import' notification type.
	///
	/// - Tag: L10n-libraryImportNotification
	static let libraryImport: String = String(
		localized: "Library Import",
		table: "Settings",
		comment: "The string for the 'library import' notification type"
	)

	// MARK: - Settings
	/// The title string for the 'App Icon' settings.
	///
	/// - Tag: L10n-appIcon
	static let appIcon: String = String(
		localized: "App Icon",
		table: "Settings",
		comment: "The title string for the 'App Icon' settings."
	)
	/// The title string for the 'Theme Store' settings.
	///
	/// - Tag: L10n-themeStore
	static let themeStore: String = String(
		localized: "Theme Store",
		table: "Settings",
		comment: "The title string for the 'Theme Store Grouping' settings."
	)
	/// The title string for the 'Allow Notifications' settings.
	///
	/// - Tag: L10n-allowNotifications
	static let allowNotifications: String = String(
		localized: "Allow Notifications",
		table: "Settings",
		comment: "The title string for the 'Allow Notifications' settings."
	)
	/// The title string for the 'Notification Grouping' settings.
	///
	/// - Tag: L10n-notificationGrouping
	static let notificationGrouping: String = String(
		localized: "Notification Grouping",
		table: "Settings",
		comment: "The title string for the 'Notification Grouping' settings."
	)
	/// The title string for the 'Timezone' settings.
	///
	/// - Tag: L10n-timezone
	static let timezone: String = String(
		localized: "Timezone",
		table: "Settings",
		comment: "The title string for the 'Timezone' settings."
	)
	/// The title string for the 'Sign in with Apple' settings.
	///
	/// - Tag: L10n-signInWithApple
	static let signInWithApple: String = String(
		localized: "Sign in with Apple",
		table: "Settings",
		comment: "The title string for the 'Sign in with Apple' settings."
	)
	/// The title string for the 'Manage Active Sessions' settings.
	///
	/// - Tag: L10n-manageActiveSessions
	static let manageActiveSessions: String = String(
		localized: "Manage Active Sessions",
		table: "Settings",
		comment: "The title string for the 'Manage Active Sessions' settings."
	)
	/// The title string for the 'Import Library' settings.
	///
	/// - Tag: L10n-importLibrary
	static let importLibrary: String = String(
		localized: "Import Library",
		table: "Settings",
		comment: "The title string for the 'Import Library' settings."
	)
	/// The title string for the 'Delete Library' settings.
	///
	/// - Tag: L10n-deleteLibrary
	static let deleteLibrary: String = String(
		localized: "Delete Library",
		table: "Settings",
		comment: "The title string for the 'Delete Library' settings."
	)
	/// The title string for the 'Delete Account' settings.
	///
	/// - Tag: L10n-deleteAccount
	static let deleteAccount: String = String(
		localized: "Delete Account",
		table: "Settings",
		comment: "The title string for the 'Delete Account' settings button."
	)
	/// The title string for the 'Sign Out' settings.
	///
	/// - Tag: L10n-signOut
	static let signOut: String = String(
		localized: "Sign Out",
		table: "Settings",
		comment: "The title string for the 'Sign Out' settings button."
	)
	/// The headline string for the account settings option.
	///
	/// - Tag: L10n-accountHeadline
	static let accountHeadline: String = String(
		localized: "Sign in to your Kurozora account",
		table: "Settings",
		comment: "The headline string for the account settings option."
	)
	/// The sub-headline string for the account settings option when not signed in.
	///
	/// - Tag: L10n-accountSubheadline
	static let accountSubheadline: String = String(
		localized: "Setup Kurozora Account and more.",
		table: "Settings",
		comment: "The sub-headline string for the account settings option when not signed in."
	)
	/// The sub-headline string for the account settings option when signed in.
	///
	/// - Tag: L10n-accountSignedInSubheadline
	static let accountSignedInSubheadline: String = String(
		localized: "Kurozora Account, Sign in with Apple & Library Import",
		table: "Settings",
		comment: "The sub-headline string for the account settings option when signed in."
	)
	/// The string for the 'Switch Account' settings option.
	///
	/// - Tag: L10n-switchAccount
	static let switchAccount: String = String(
		localized: "Switch Account",
		table: "Settings",
		comment: "The string for the 'Switch Account' settings option."
	)
	/// The string for the 'Keys Manager' settings option.
	///
	/// - Tag: L10n-keysManager
	static let keysManager: String = String(
		localized: "Keys Manager",
		table: "Settings",
		comment: "The string for the 'Keys Manager' settings option."
	)
	/// The string for the 'Subscribe to Reminders' settings option.
	///
	/// - Tag: L10n-subscribeToReminders
	static let subscribeToReminders: String = String(
		localized: "Subscribe to Reminders",
		table: "Settings",
		comment: "The string for the 'Subscribe to Reminders' settings option."
	)
	/// The string for the 'Sound' settings option.
	///
	/// - Tag: L10n-sound
	static let sound: String = String(
		localized: "Sound",
		table: "Settings",
		comment: "The string for the 'Sound' settings option."
	)
	/// The string for the 'Sounds' settings option.
	///
	/// - Tag: L10n-sounds
	static let sounds: String = String(
		localized: "Sounds",
		table: "Settings",
		comment: "The string for the 'Sounds' settings option."
	)
	/// The string for the 'Sounds & Haptics' settings option.
	///
	/// - Tag: L10n-soundsAndHaptics
	static let soundsAndHaptics: String = String(
		localized: "Sounds & Haptics",
		table: "Settings",
		comment: "The string for the 'Sounds & Haptics' settings option."
	)
	/// The string for the 'Display & Blindness' settings option.
	///
	/// - Tag: L10n-displayBlindness
	static let displayBlindness: String = String(
		localized: "Display & Blindness",
		table: "Settings",
		comment: "The string for the 'Display & Blindness' settings option."
	)
	/// The string for the 'Face ID & Passcode' settings option.
	///
	/// - Tag: L10n-faceIDPasscode
	static let faceIDPasscode: String = String(
		localized: "Face ID & Passcode",
		table: "Settings",
		comment: "The string for the 'Face ID & Passcode' settings option."
	)
	/// The string for the 'Touch ID & Passcode' settings option.
	///
	/// - Tag: L10n-touchIDPasscode
	static let touchIDPasscode: String = String(
		localized: "Touch ID & Passcode",
		table: "Settings",
		comment: "The string for the 'Touch ID & Passcode' settings option."
	)
	/// The string for the 'Optic ID & Passcode' settings option.
	///
	/// - Tag: L10n-opticIDPasscode
	static let opticIDPasscode: String = String(
		localized: "Optic ID & Passcode",
		table: "Settings",
		comment: "The string for the 'Optic ID & Passcode' settings option."
	)
	/// The string for the 'Unlock Features' settings option.
	///
	/// - Tag: L10n-unlockFeatures
	static let unlockFeatures: String = String(
		localized: "Unlock Features",
		table: "Settings",
		comment: "The string for the 'Unlock Features' settings option."
	)
	/// The string for the 'Tip Jar' settings option.
	///
	/// - Tag: L10n-tipJar
	static let tipJar: String = String(
		localized: "Tip Jar",
		table: "Settings",
		comment: "The string for the 'Tip Jar' settings option."
	)
	/// The string for the 'Restore Purchase' settings option.
	///
	/// - Tag: L10n-restorePurchase
	static let restorePurchase: String = String(
		localized: "Restore Purchase",
		table: "Settings",
		comment: "The string for the 'Restore Purchase' settings option."
	)
	/// The string for the 'Request Refund' settings option.
	///
	/// - Tag: L10n-requestRefund
	static let requestRefund: String = String(
		localized: "Request Refund",
		table: "Settings",
		comment: "The string for the 'Request Refund' settings option."
	)
	/// The string for the 'Add Sticker to Signal' settings option.
	///
	/// - Tag: L10n-addStickerToSignal
	static let addStickerToSignal: String = String(
		localized: "Add Sticker to Signal",
		table: "Settings",
		comment: "The string for the 'Add Sticker to Signal' settings option."
	)
	/// The string for the 'Add Sticker to Telegram' settings option.
	///
	/// - Tag: L10n-addStickerToTelegram
	static let addStickerToTelegram: String = String(
		localized: "Add Sticker to Telegram",
		table: "Settings",
		comment: "The string for the 'Add Sticker to Telegram' settings option."
	)
	/// The string for the 'Rate us on App Store' settings option.
	///
	/// - Tag: L10n-rateAppStore
	static let rateAppStore: String = String(
		localized: "Rate us on App Store",
		table: "Settings",
		comment: "The string for the 'Rate us on App Store' settings option."
	)
	/// The string for the 'Join our Discord Community' settings option.
	///
	/// - Tag: L10n-joinDiscord
	static let joinDiscord: String = String(
		localized: "Join our Discord Community",
		table: "Settings",
		comment: "The string for the 'Join our Discord Community' settings option."
	)
	/// The string for the 'Follow us on GitHub' settings option.
	///
	/// - Tag: L10n-followGitHub
	static let followGitHub: String = String(
		localized: "Follow us on GitHub",
		table: "Settings",
		comment: "The string for the 'Follow us on GitHub' settings option."
	)
	/// The string for the 'Follow us on Mastodon' settings option.
	///
	/// - Tag: L10n-followMastodon
	static let followMastodon: String = String(
		localized: "Follow us on Mastodon",
		table: "Settings",
		comment: "The string for the 'Follow us on Mastodon' settings option."
	)
	/// The string for the 'Follow us on Twitter' settings option.
	///
	/// - Tag: L10n-followTwitter
	static let followTwitter: String = String(
		localized: "Follow us on Twitter",
		table: "Settings",
		comment: "The string for the 'Follow us on Twitter' settings option."
	)
	/// The title string for the 'Clear all Cache?' alert.
	///
	/// - Tag: L10n-clearAllCache
	static let clearAllCache: String = String(
		localized: "Clear all Cache?",
		table: "Settings",
		comment: "The title string for the 'Clear all Cache?' alert."
	)
	/// The message string for the cache section footer.
	///
	/// - Tag: L10n-clearCacheFooterMessage
	static let clearCacheFooterMessage: String = String(
		localized: "The numbers you see in Kurozora might not match the one in the Settings app. That's because caches on your disk and in RAM are counted together here. Wiping both clean might make the app a bit slower at first, but things will speed up once the caches are built up again.",
		table: "Settings",
		comment: "The message string for the cache section footer."
	)
	/// The title string for the 'Clear All' destructive button.
	///
	/// - Tag: L10n-clearAll
	static let clearAll: String = String(
		localized: "Clear All",
		table: "Settings",
		comment: "The title string for the 'Clear All' destructive button."
	)
	/// A short description for the cache settings header.
	///
	/// - Tag: L10n-cacheHeaderDescription
	static let cacheHeaderDescription: String = String(
		localized: "Manage your app experience by clearing temporary files, downloaded content, and cached media used for faster loading and offline viewing.",
		table: "Settings",
		comment: "A short description for the cache settings header."
	)
	/// A short description for the keys manager settings header.
	///
	/// - Tag: L10n-keysManagerHeaderDescription
	static let keysManagerHeaderDescription: String = String(
		localized: "View and manage stored keychain entries and account credentials. Modifying these values may affect your sign-in sessions.",
		table: "Settings",
		comment: "A short description for the keys manager settings header."
	)
	/// A short description for the browser settings header.
	///
	/// - Tag: L10n-browserHeaderDescription
	static let browserHeaderDescription: String = String(
		localized: "Set a default browser for opening web links. If the selected app isn't installed, links open in Safari as a fallback.",
		table: "Settings",
		comment: "A short description for the browser settings header."
	)
	/// A short description for the library settings header.
	///
	/// - Tag: L10n-libraryHeaderDescription
	static let libraryHeaderDescription: String = String(
		localized: "Customize how your library is organized by setting the default sort order for each tracking status and media type.",
		table: "Settings",
		comment: "A short description for the library settings header."
	)
	/// A short description for the motion settings header.
	///
	/// - Tag: L10n-motionHeaderDescription
	static let motionHeaderDescription: String = String(
		localized: "Control animations and visual effects throughout the app, including the splash screen animation and reduced motion preferences.",
		table: "Settings",
		comment: "A short description for the motion settings header."
	)
	/// A short description for the notifications settings header.
	///
	/// - Tag: L10n-notificationsHeaderDescription
	static let notificationsHeaderDescription: String = String(
		localized: "Manage in-app notification preferences including sounds, badges, and how notifications are grouped together.",
		table: "Settings",
		comment: "A short description for the notifications settings header."
	)
	/// A short description for the sounds and haptics settings header.
	///
	/// - Tag: L10n-soundHeaderDescription
	static let soundHeaderDescription: String = String(
		localized: "Adjust the startup chime, UI sound effects, and haptic feedback to personalize how the app sounds and feels.",
		table: "Settings",
		comment: "A short description for the sounds and haptics settings header."
	)
	/// A short description for the authentication settings header.
	///
	/// - Tag: L10n-authenticationHeaderDescription
	static let authenticationHeaderDescription: String = String(
		localized: "Require authentication to unlock the app and choose how frequently you need to verify your identity.",
		table: "Settings",
		comment: "A short description for the authentication settings header."
	)
	/// A short description for the privacy settings header.
	///
	/// - Tag: L10n-privacyHeaderDescription
	static let privacyHeaderDescription: String = String(
		localized: "Review your privacy settings, manage app permissions in the Settings app, and access legal information.",
		table: "Settings",
		comment: "A short description for the privacy settings header."
	)

	// MARK: - Motion Settings
	/// The string for the 'Animations' settings header.
	///
	/// - Tag: L10n-animations
	static let animations: String = String(
		localized: "Animations",
		table: "Settings",
		comment: "The string for the 'Animations' settings header."
	)
	/// The string for the 'Splash Screen' settings option.
	///
	/// - Tag: L10n-splashScreen
	static let splashScreen: String = String(
		localized: "Splash Screen",
		table: "Settings",
		comment: "The string for the 'Splash Screen' settings option."
	)
	/// The string for the 'Reduce Motion' settings option.
	///
	/// - Tag: L10n-reduceMotion
	static let reduceMotion: String = String(
		localized: "Reduce Motion",
		table: "Settings",
		comment: "The string for the 'Reduce Motion' settings option."
	)
	/// The string for the 'Sync With Device Settings' settings option.
	///
	/// - Tag: L10n-syncWithDeviceSettings
	static let syncWithDeviceSettings: String = String(
		localized: "Sync With Device Settings",
		table: "Settings",
		comment: "The string for the 'Sync With Device Settings' settings option."
	)
	/// The footer string for the 'Reduce Motion' settings option.
	///
	/// - Tag: L10n-reduceMotionFooter
	static let reduceMotionFooter: String = String(
		localized: "Reduce the intensity of animations, and motion effects throughout Kurozora.",
		table: "Settings",
		comment: "The footer string for the 'Reduce Motion' settings option."
	)

	// MARK: - Sounds & Haptics
	/// The string for the 'Chime & Sound Effects' settings option.
	///
	/// - Tag: L10n-chimeAndSoundEffects
	static let chimeAndSoundEffects: String = String(
		localized: "Chime & Sound Effects",
		table: "Settings",
		comment: "The string for the 'Chime & Sound Effects' settings option."
	)
	/// The string for the 'Chime Sound' settings option.
	///
	/// - Tag: L10n-chimeSound
	static let chimeSound: String = String(
		localized: "Chime Sound",
		table: "Settings",
		comment: "The string for the 'Chime Sound' settings option."
	)
	/// The string for the 'Chime on Startup' settings option.
	///
	/// - Tag: L10n-chimeOnStartup
	static let chimeOnStartup: String = String(
		localized: "Chime on Startup",
		table: "Settings",
		comment: "The string for the 'Chime on Startup' settings option."
	)
	/// The string for the 'User Interface Sounds' settings option.
	///
	/// - Tag: L10n-uiSounds
	static let uiSounds: String = String(
		localized: "User Interface Sounds",
		table: "Settings",
		comment: "The string for the 'User Interface Sounds' settings option."
	)
	/// The string for the 'Haptics' settings option.
	///
	/// - Tag: L10n-haptics
	static let haptics: String = String(
		localized: "Haptics",
		table: "Settings",
		comment: "The string for the 'Haptics' settings option."
	)
	/// The footer string for the haptics settings option.
	///
	/// - Tag: L10n-hapticsFooter
	static let hapticsFooter: String = String(
		localized: "Turning off haptics will only affect custom haptics. Default system controls, like the switches above, will still have a haptic feedback. You can disable all haptics in the Settings app.",
		table: "Settings",
		comment: "The footer string for the haptics settings option."
	)

	// MARK: - Refresh Control Titles
	/// Pull-to-refresh title for the notifications list.
	///
	/// - Tag: L10n-pullToRefreshNotifications
	static let pullToRefreshNotifications: String = String(
		localized: "Pull to refresh your notifications!",
		table: "Settings",
		comment: "Pull-to-refresh title for the notifications list."
	)
	/// Refresh-in-progress title for the notifications list.
	///
	/// - Tag: L10n-refreshingNotifications
	static let refreshingNotifications: String = String(
		localized: "Refreshing notifications...",
		table: "Settings",
		comment: "Refresh-in-progress title for the notifications list."
	)
	/// Pull-to-refresh title for the themes list in the Theme Store.
	///
	/// - Tag: L10n-pullToRefreshThemesList
	static let pullToRefreshThemesList: String = String(
		localized: "Pull to refresh themes list!",
		table: "Settings",
		comment: "Pull-to-refresh title for the themes list in the Theme Store."
	)
	/// Refresh-in-progress title for the themes list in the Theme Store.
	///
	/// - Tag: L10n-refreshingThemesList
	static let refreshingThemesList: String = String(
		localized: "Refreshing themes list...",
		table: "Settings",
		comment: "Refresh-in-progress title for the themes list in the Theme Store."
	)

	// MARK: - Theme Store
	/// The action sheet button for redownloading an already-purchased theme.
	///
	/// - Tag: L10n-redownloadTheme
	static let redownloadTheme: String = String(
		localized: "Redownload Theme",
		table: "Settings",
		comment: "The action sheet button for redownloading an already-purchased theme."
	)
	/// The destructive action sheet button for removing a downloaded theme.
	///
	/// - Tag: L10n-removeTheme
	static let removeTheme: String = String(
		localized: "Remove Theme",
		table: "Settings",
		comment: "The destructive action sheet button for removing a downloaded theme."
	)
}
