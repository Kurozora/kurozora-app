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
	static var defaultThemeDescription: String {
		L10n.resolve {
			String(
				localized: "The official Kurozora theme.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for default theme description."
			)
		}
	}
	/// The string for day theme description.
	///
	/// - Tag: L10n-dayThemeDescription
	static var dayThemeDescription: String {
		L10n.resolve {
			String(
				localized: "Rise and shine.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for day theme description."
			)
		}
	}
	/// The string for night theme description.
	///
	/// - Tag: L10n-nightThemeDescription
	static var nightThemeDescription: String {
		L10n.resolve {
			String(
				localized: "Easy on the eyes.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for night theme description."
			)
		}
	}
	/// The string for grass theme description.
	///
	/// - Tag: L10n-grassThemeDescription
	static var grassThemeDescription: String {
		L10n.resolve {
			String(
				localized: "Get off my lawn!",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for grass theme description."
			)
		}
	}
	/// The string for sky theme description.
	///
	/// - Tag: L10n-skyThemeDescription
	static var skyThemeDescription: String {
		L10n.resolve {
			String(
				localized: "Cloudless.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for sky theme description."
			)
		}
	}
	/// The string for sakura theme description.
	///
	/// - Tag: L10n-sakuraThemeDescription
	static var sakuraThemeDescription: String {
		L10n.resolve {
			String(
				localized: "In full bloom.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for sakura theme description."
			)
		}
	}

	// MARK: - Theme Names
	/// The display name of the Day theme.
	static var themeDay: String {
		L10n.resolve {
			String(localized: "Day", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display name of the Day theme.")
		}
	}
	/// The display name of the Night theme.
	static var themeNight: String {
		L10n.resolve {
			String(localized: "Night", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display name of the Night theme.")
		}
	}
	/// The display name of the Grass theme.
	static var themeGrass: String {
		L10n.resolve {
			String(localized: "Grass", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display name of the Grass theme.")
		}
	}
	/// The display name of the Sky theme.
	static var themeSky: String {
		L10n.resolve {
			String(localized: "Sky", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display name of the Sky theme.")
		}
	}
	/// The display name of the Sakura theme.
	static var themeSakura: String {
		L10n.resolve {
			String(localized: "Sakura", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display name of the Sakura theme.")
		}
	}

	// MARK: - Notification
	/// The string for the 'view sessions' notification action.
	///
	/// - Tag: L10n-viewSessions
	static var viewSessions: String {
		L10n.resolve {
			String(
				localized: "View Sessions",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'view sessions' notification action."
			)
		}
	}
	/// The string for the 'view show details' notification action.
	///
	/// - Tag: L10n-viewShowDetails
	static var viewShowDetails: String {
		L10n.resolve {
			String(
				localized: "View Show Details",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'view show details' notification action."
			)
		}
	}
	/// The string for the 'view profile' notification action.
	///
	/// - Tag: L10n-viewProfile
	static var viewProfile: String {
		L10n.resolve {
			String(
				localized: "View Profile",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'view profile' notification action."
			)
		}
	}
	/// The string for the 'view message reply' notification action.
	///
	/// - Tag: L10n-viewMessageReply
	static var viewMessageReply: String {
		L10n.resolve {
			String(
				localized: "View Message Reply",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'view message reply' notification action."
			)
		}
	}
	/// The string for the 'view message re-share' notification action.
	///
	/// - Tag: L10n-viewMessageReShare
	static var viewMessageReShare: String {
		L10n.resolve {
			String(
				localized: "View Message Re-share",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'view message re-share' notification action."
			)
		}
	}
	/// The string for the 'mention' notification type.
	///
	/// - Tag: L10n-mention
	static var mention: String {
		L10n.resolve {
			String(
				localized: "Mention",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'mention' notification type."
			)
		}
	}
	/// The string for the 'subscription update' notification type.
	///
	/// - Tag: L10n-subscriptionUpdate
	static var subscriptionUpdate: String {
		L10n.resolve {
			String(
				localized: "Subscription Update",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'subscription update' notification type"
			)
		}
	}
	/// The string for the 'new session' notification type.
	///
	/// - Tag: L10n-newSession
	static var newSession: String {
		L10n.resolve {
			String(
				localized: "New Session",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'new session' notification type"
			)
		}
	}
	/// The string for the 'library import' notification type.
	///
	/// - Tag: L10n-libraryImportNotification
	static var libraryImport: String {
		L10n.resolve {
			String(
				localized: "Library Import",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'library import' notification type"
			)
		}
	}
	/// The string for the 'moderation' notification type.
	///
	/// - Tag: L10n-moderation
	static var moderation: String {
		L10n.resolve {
			String(
				localized: "Moderation",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'moderation' notification type"
			)
		}
	}

	// MARK: - Settings
	/// The title string for the 'App Icon' settings.
	///
	/// - Tag: L10n-appIcon
	static var appIcon: String {
		L10n.resolve {
			String(
				localized: "App Icon",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'App Icon' settings."
			)
		}
	}
	/// The title string for the 'Theme Store' settings.
	///
	/// - Tag: L10n-themeStore
	static var themeStore: String {
		L10n.resolve {
			String(
				localized: "Theme Store",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Theme Store Grouping' settings."
			)
		}
	}
	/// The title string for the 'Allow Notifications' settings.
	///
	/// - Tag: L10n-allowNotifications
	static var allowNotifications: String {
		L10n.resolve {
			String(
				localized: "Allow Notifications",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Allow Notifications' settings."
			)
		}
	}
	/// The title string for the 'Notification Grouping' settings.
	///
	/// - Tag: L10n-notificationGrouping
	static var notificationGrouping: String {
		L10n.resolve {
			String(
				localized: "Notification Grouping",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Notification Grouping' settings."
			)
		}
	}
	/// The title string for the 'Timezone' settings.
	///
	/// - Tag: L10n-timezone
	static var timezone: String {
		L10n.resolve {
			String(
				localized: "Timezone",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Timezone' settings."
			)
		}
	}
	/// The title string for the 'Sign in with Apple' settings.
	///
	/// - Tag: L10n-signInWithApple
	static var signInWithApple: String {
		L10n.resolve {
			String(
				localized: "Sign in with Apple",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Sign in with Apple' settings."
			)
		}
	}
	/// The title string for the 'Manage Active Sessions' settings.
	///
	/// - Tag: L10n-manageActiveSessions
	static var manageActiveSessions: String {
		L10n.resolve {
			String(
				localized: "Manage Active Sessions",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Manage Active Sessions' settings."
			)
		}
	}
	/// The title string for the 'Import Library' settings.
	///
	/// - Tag: L10n-importLibrary
	static var importLibrary: String {
		L10n.resolve {
			String(
				localized: "Import Library",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Import Library' settings."
			)
		}
	}
	/// The title string for the 'Delete Library' settings.
	///
	/// - Tag: L10n-deleteLibrary
	static var deleteLibrary: String {
		L10n.resolve {
			String(
				localized: "Delete Library",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Delete Library' settings."
			)
		}
	}
	/// The placeholder shown before a library kind is chosen on the delete library screen.
	static var selectLibrary: String {
		L10n.resolve {
			String(
				localized: "Select library",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The placeholder shown before a library kind is chosen on the delete library screen."
			)
		}
	}
	/// The title string for the 'Delete Account' settings.
	///
	/// - Tag: L10n-deleteAccount
	static var deleteAccount: String {
		L10n.resolve {
			String(
				localized: "Delete Account",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Delete Account' settings button."
			)
		}
	}
	/// The title string for the 'Sign Out' settings.
	///
	/// - Tag: L10n-signOut
	static var signOut: String {
		L10n.resolve {
			String(
				localized: "Sign Out",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Sign Out' settings button."
			)
		}
	}
	/// The headline string for the account settings option.
	///
	/// - Tag: L10n-accountHeadline
	static var accountHeadline: String {
		L10n.resolve {
			String(
				localized: "Sign in to your Kurozora account",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The headline string for the account settings option."
			)
		}
	}
	/// The sub-headline string for the account settings option when not signed in.
	///
	/// - Tag: L10n-accountSubheadline
	static var accountSubheadline: String {
		L10n.resolve {
			String(
				localized: "Setup Kurozora Account and more.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The sub-headline string for the account settings option when not signed in."
			)
		}
	}
	/// The sub-headline string for the account settings option when signed in.
	///
	/// - Tag: L10n-accountSignedInSubheadline
	static var accountSignedInSubheadline: String {
		L10n.resolve {
			String(
				localized: "Kurozora Account, Sign in with Apple & Library Import",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The sub-headline string for the account settings option when signed in."
			)
		}
	}
	/// The string for the 'Switch Account' settings option.
	///
	/// - Tag: L10n-switchAccount
	static var switchAccount: String {
		L10n.resolve {
			String(
				localized: "Switch Account",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Switch Account' settings option."
			)
		}
	}
	/// The string for the 'Keys Manager' settings option.
	///
	/// - Tag: L10n-keysManager
	static var keysManager: String {
		L10n.resolve {
			String(
				localized: "Keys Manager",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Keys Manager' settings option."
			)
		}
	}
	/// The string for the 'Subscribe to Reminders' settings option.
	///
	/// - Tag: L10n-subscribeToReminders
	static var subscribeToReminders: String {
		L10n.resolve {
			String(
				localized: "Subscribe to Reminders",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Subscribe to Reminders' settings option."
			)
		}
	}
	/// The string for the 'Copy Subscription Link' calendar picker option.
	///
	/// - Tag: L10n-copySubscriptionLink
	static var copySubscriptionLink: String {
		L10n.resolve {
			String(
				localized: "Copy Subscription Link",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Copy Subscription Link' calendar picker option."
			)
		}
	}
	/// The confirmation string shown after copying the subscription link to the pasteboard.
	///
	/// - Tag: L10n-subscriptionLinkCopied
	static var subscriptionLinkCopied: String {
		L10n.resolve {
			String(
				localized: "Subscription link copied",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The confirmation string shown after copying the subscription link to the pasteboard."
			)
		}
	}
	/// The footer string for the reminder subscription picker.
	///
	/// - Tag: L10n-reminderSubscriptionFooter
	static var reminderSubscriptionFooter: String {
		L10n.resolve {
			String(
				localized: "Choose where to subscribe to your Kurozora reminders. If the selected app isn't installed, the link will open in Safari as a fallback.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the reminder subscription picker."
			)
		}
	}
	/// A short description for the reminder subscription settings header.
	///
	/// - Tag: L10n-reminderSubscriptionHeaderDescription
	static var reminderSubscriptionHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Pick a calendar app to subscribe to your Kurozora reminders, or copy the subscription link to use elsewhere.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the reminder subscription settings header."
			)
		}
	}
	/// The string for the 'Sound' settings option.
	///
	/// - Tag: L10n-sound
	static var sound: String {
		L10n.resolve {
			String(
				localized: "Sound",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Sound' settings option."
			)
		}
	}
	/// The string for the 'Sounds' settings option.
	///
	/// - Tag: L10n-sounds
	static var sounds: String {
		L10n.resolve {
			String(
				localized: "Sounds",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Sounds' settings option."
			)
		}
	}
	/// The string for the 'Sounds & Haptics' settings option.
	///
	/// - Tag: L10n-soundsAndHaptics
	static var soundsAndHaptics: String {
		L10n.resolve {
			String(
				localized: "Sounds & Haptics",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Sounds & Haptics' settings option."
			)
		}
	}
	/// The string for the 'Gestures' settings option.
	///
	/// - Tag: L10n-gestures
	static var gestures: String {
		L10n.resolve {
			String(
				localized: "Gestures",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Gestures' settings option."
			)
		}
	}
	/// The string for the 'Display & Blindness' settings option.
	///
	/// - Tag: L10n-displayBlindness
	static var displayBlindness: String {
		L10n.resolve {
			String(
				localized: "Display & Blindness",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Display & Blindness' settings option."
			)
		}
	}
	/// The string for the 'Face ID & Passcode' settings option.
	///
	/// - Tag: L10n-faceIDPasscode
	static var faceIDPasscode: String {
		L10n.resolve {
			String(
				localized: "Face ID & Passcode",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Face ID & Passcode' settings option."
			)
		}
	}
	/// The string for the 'Touch ID & Passcode' settings option.
	///
	/// - Tag: L10n-touchIDPasscode
	static var touchIDPasscode: String {
		L10n.resolve {
			String(
				localized: "Touch ID & Passcode",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Touch ID & Passcode' settings option."
			)
		}
	}
	/// The string for the 'Optic ID & Passcode' settings option.
	///
	/// - Tag: L10n-opticIDPasscode
	static var opticIDPasscode: String {
		L10n.resolve {
			String(
				localized: "Optic ID & Passcode",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Optic ID & Passcode' settings option."
			)
		}
	}
	/// The string for the 'Unlock Features' settings option.
	///
	/// - Tag: L10n-unlockFeatures
	static var unlockFeatures: String {
		L10n.resolve {
			String(
				localized: "Unlock Features",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Unlock Features' settings option."
			)
		}
	}
	/// The string for the 'Tip Jar' settings option.
	///
	/// - Tag: L10n-tipJar
	static var tipJar: String {
		L10n.resolve {
			String(
				localized: "Tip Jar",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Tip Jar' settings option."
			)
		}
	}
	/// The string for the 'Restore Purchase' settings option.
	///
	/// - Tag: L10n-restorePurchase
	static var restorePurchase: String {
		L10n.resolve {
			String(
				localized: "Restore Purchase",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Restore Purchase' settings option."
			)
		}
	}
	/// The string for the 'Request Refund' settings option.
	///
	/// - Tag: L10n-requestRefund
	static var requestRefund: String {
		L10n.resolve {
			String(
				localized: "Request Refund",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Request Refund' settings option."
			)
		}
	}
	/// The string for the 'Add Sticker to Signal' settings option.
	///
	/// - Tag: L10n-addStickerToSignal
	static var addStickerToSignal: String {
		L10n.resolve {
			String(
				localized: "Add Sticker to Signal",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Add Sticker to Signal' settings option."
			)
		}
	}
	/// The string for the 'Add Sticker to Telegram' settings option.
	///
	/// - Tag: L10n-addStickerToTelegram
	static var addStickerToTelegram: String {
		L10n.resolve {
			String(
				localized: "Add Sticker to Telegram",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Add Sticker to Telegram' settings option."
			)
		}
	}
	/// The string for the 'Add Sticker to WhatsApp' settings option.
	///
	/// - Tag: L10n-addStickerToWhatsApp
	static var addStickerToWhatsApp: String {
		L10n.resolve {
			String(
				localized: "Add Sticker to WhatsApp",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Add Sticker to WhatsApp' settings option."
			)
		}
	}
	/// The alert message shown when WhatsApp is not installed on the device.
	///
	/// - Tag: L10n-whatsAppNotInstalled
	static var whatsAppNotInstalled: String {
		L10n.resolve {
			String(
				localized: "WhatsApp doesn’t appear to be installed on this device.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The alert message shown when WhatsApp is not installed on the device."
			)
		}
	}
	/// The title of the alert shown when adding the WhatsApp sticker pack fails.
	///
	/// - Tag: L10n-stickerInstallFailedTitle
	static var stickerInstallFailedTitle: String {
		L10n.resolve {
			String(
				localized: "Couldn’t Add Sticker Pack",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the alert shown when adding the WhatsApp sticker pack fails."
			)
		}
	}
	/// The message of the alert shown when adding the WhatsApp sticker pack fails.
	///
	/// - Tag: L10n-stickerInstallFailedMessage
	static var stickerInstallFailedMessage: String {
		L10n.resolve {
			String(
				localized: "Something went wrong while preparing the Kuro-chan stickers for WhatsApp. Please try again later.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message of the alert shown when adding the WhatsApp sticker pack fails."
			)
		}
	}
	/// The string for the 'Rate us on App Store' settings option.
	///
	/// - Tag: L10n-rateAppStore
	static var rateAppStore: String {
		L10n.resolve {
			String(
				localized: "Rate us on App Store",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Rate us on App Store' settings option."
			)
		}
	}
	/// The string for the 'Join our Discord Community' settings option.
	///
	/// - Tag: L10n-joinDiscord
	static var joinDiscord: String {
		L10n.resolve {
			String(
				localized: "Join our Discord Community",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Join our Discord Community' settings option."
			)
		}
	}
	/// The string for the 'Follow us on GitHub' settings option.
	///
	/// - Tag: L10n-followGitHub
	static var followGitHub: String {
		L10n.resolve {
			String(
				localized: "Follow us on GitHub",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Follow us on GitHub' settings option."
			)
		}
	}
	/// The string for the 'Follow us on Mastodon' settings option.
	///
	/// - Tag: L10n-followMastodon
	static var followMastodon: String {
		L10n.resolve {
			String(
				localized: "Follow us on Mastodon",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Follow us on Mastodon' settings option."
			)
		}
	}
	/// The string for the 'Follow us on Twitter' settings option.
	///
	/// - Tag: L10n-followTwitter
	static var followTwitter: String {
		L10n.resolve {
			String(
				localized: "Follow us on Twitter",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Follow us on Twitter' settings option."
			)
		}
	}
	/// The title string for the 'Clear all Cache?' alert.
	///
	/// - Tag: L10n-clearAllCache
	static var clearAllCache: String {
		L10n.resolve {
			String(
				localized: "Clear all Cache?",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Clear all Cache?' alert."
			)
		}
	}
	/// The message string for the cache section footer.
	///
	/// - Tag: L10n-clearCacheFooterMessage
	static var clearCacheFooterMessage: String {
		L10n.resolve {
			String(
				localized: "The numbers you see in Kurozora might not match the one in the Settings app. That's because caches on your disk and in RAM are counted together here. Wiping both clean might make the app a bit slower at first, but things will speed up once the caches are built up again.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message string for the cache section footer."
			)
		}
	}
	/// The message string for the library cache section footer.
	///
	/// - Tag: L10n-libraryCacheFooterMessage
	static var libraryCacheFooterMessage: String {
		L10n.resolve {
			String(
				localized: "Artwork for titles in your library is stored separately and managed automatically, so your library can be viewed offline. Clearing the cache doesn't affect it.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The message string for the library cache section footer."
			)
		}
	}
	/// The title string for the 'Clear All' destructive button.
	///
	/// - Tag: L10n-clearAll
	static var clearAll: String {
		L10n.resolve {
			String(
				localized: "Clear All",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title string for the 'Clear All' destructive button."
			)
		}
	}
	/// A short description for the cache settings header.
	///
	/// - Tag: L10n-cacheHeaderDescription
	static var cacheHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Manage your app experience by clearing temporary files, downloaded content, and cached media used for faster loading and offline viewing.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the cache settings header."
			)
		}
	}
	/// A short description for the keys manager settings header.
	///
	/// - Tag: L10n-keysManagerHeaderDescription
	static var keysManagerHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "View and manage stored keychain entries and account credentials. Modifying these values may affect your sign-in sessions.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the keys manager settings header."
			)
		}
	}
	/// A short description for the browser settings header.
	///
	/// - Tag: L10n-browserHeaderDescription
	static var browserHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Set a default browser for opening web links. If the selected app isn't installed, links open in Safari as a fallback.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the browser settings header."
			)
		}
	}
	/// A short description for the library settings header.
	///
	/// - Tag: L10n-libraryHeaderDescription
	static var libraryHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Customize how your library is organized by setting the default sort order for each tracking status and media type.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the library settings header."
			)
		}
	}
	/// A short description for the gestures settings header.
	///
	/// - Tag: L10n-gesturesHeaderDescription
	static var gesturesHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Choose which swipes move you around the app, including reopening a screen you just left.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the gestures settings header."
			)
		}
	}
	/// A short description for the motion settings header.
	///
	/// - Tag: L10n-motionHeaderDescription
	static var motionHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Control animations and visual effects throughout the app, including the splash screen animation and reduced motion preferences.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the motion settings header."
			)
		}
	}
	/// A short description for the notifications settings header.
	///
	/// - Tag: L10n-notificationsHeaderDescription
	static var notificationsHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Manage in-app notification preferences including sounds, badges, and how notifications are grouped together.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the notifications settings header."
			)
		}
	}
	/// A short description for the sounds and haptics settings header.
	///
	/// - Tag: L10n-soundHeaderDescription
	static var soundHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Adjust the startup chime, UI sound effects, and haptic feedback to personalize how the app sounds and feels.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the sounds and haptics settings header."
			)
		}
	}
	/// A short description for the authentication settings header.
	///
	/// - Tag: L10n-authenticationHeaderDescription
	static var authenticationHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Require authentication to unlock the app and choose how frequently you need to verify your identity.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the authentication settings header."
			)
		}
	}
	/// A short description for the privacy settings header.
	///
	/// - Tag: L10n-privacyHeaderDescription
	static var privacyHeaderDescription: String {
		L10n.resolve {
			String(
				localized: "Review your privacy settings, manage app permissions in the Settings app, manage blocked accounts, and access legal information.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "A short description for the privacy settings header."
			)
		}
	}

	// MARK: - Gestures Settings
	/// The string for the 'Navigation' settings header.
	///
	/// - Tag: L10n-navigation
	static var navigation: String {
		L10n.resolve {
			String(
				localized: "Navigation",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Navigation' settings header."
			)
		}
	}
	/// The string for the 'Swipe Forward' settings option.
	///
	/// - Tag: L10n-swipeForward
	static var swipeForward: String {
		L10n.resolve {
			String(
				localized: "Swipe Forward",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Swipe Forward' settings option."
			)
		}
	}
	/// The footer string for the 'Swipe Forward' settings option on touch devices.
	///
	/// - Tag: L10n-swipeForwardFooter
	static var swipeForwardFooter: String {
		L10n.resolve {
			String(
				localized: "Swipe left to reopen a screen you just left.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the 'Swipe Forward' settings option on touch devices."
			)
		}
	}
	/// The footer string for the 'Swipe Forward' settings option on pointer-driven devices.
	///
	/// - Tag: L10n-forwardNavigationPointerFooter
	static var forwardNavigationPointerFooter: String {
		L10n.resolve {
			String(
				localized: "Swipe left with two fingers to reopen a screen you just left, or press ⌘]. Press ⌘[ to go back.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the 'Swipe Forward' settings option on pointer-driven devices."
			)
		}
	}
	/// The additional footer sentence naming the keyboard shortcuts on a touch device with a keyboard attached.
	///
	/// - Tag: L10n-forwardNavigationShortcutHint
	static var forwardNavigationShortcutHint: String {
		L10n.resolve {
			String(
				localized: "With a keyboard attached, press ⌘] to go forward and ⌘[ to go back.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The additional footer sentence naming the keyboard shortcuts on a touch device with a keyboard attached."
			)
		}
	}

	// MARK: - Motion Settings
	/// The string for the 'Animations' settings header.
	///
	/// - Tag: L10n-animations
	static var animations: String {
		L10n.resolve {
			String(
				localized: "Animations",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Animations' settings header."
			)
		}
	}
	/// The string for the 'Splash Screen' settings option.
	///
	/// - Tag: L10n-splashScreen
	static var splashScreen: String {
		L10n.resolve {
			String(
				localized: "Splash Screen",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Splash Screen' settings option."
			)
		}
	}
	/// The string for the 'Reduce Motion' settings option.
	///
	/// - Tag: L10n-reduceMotion
	static var reduceMotion: String {
		L10n.resolve {
			String(
				localized: "Reduce Motion",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Reduce Motion' settings option."
			)
		}
	}
	/// The string for the 'Sync With Device Settings' settings option.
	///
	/// - Tag: L10n-syncWithDeviceSettings
	static var syncWithDeviceSettings: String {
		L10n.resolve {
			String(
				localized: "Sync With Device Settings",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Sync With Device Settings' settings option."
			)
		}
	}
	/// The footer string for the 'Reduce Motion' settings option.
	///
	/// - Tag: L10n-reduceMotionFooter
	static var reduceMotionFooter: String {
		L10n.resolve {
			String(
				localized: "Reduce the intensity of animations, and motion effects throughout Kurozora.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the 'Reduce Motion' settings option."
			)
		}
	}

	// MARK: - Sounds & Haptics
	/// The string for the 'Chime & Sound Effects' settings option.
	///
	/// - Tag: L10n-chimeAndSoundEffects
	static var chimeAndSoundEffects: String {
		L10n.resolve {
			String(
				localized: "Chime & Sound Effects",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Chime & Sound Effects' settings option."
			)
		}
	}
	/// The string for the 'Chime Sound' settings option.
	///
	/// - Tag: L10n-chimeSound
	static var chimeSound: String {
		L10n.resolve {
			String(
				localized: "Chime Sound",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Chime Sound' settings option."
			)
		}
	}
	/// The string for the 'Chime on Startup' settings option.
	///
	/// - Tag: L10n-chimeOnStartup
	static var chimeOnStartup: String {
		L10n.resolve {
			String(
				localized: "Chime on Startup",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Chime on Startup' settings option."
			)
		}
	}
	/// The string for the 'User Interface Sounds' settings option.
	///
	/// - Tag: L10n-uiSounds
	static var uiSounds: String {
		L10n.resolve {
			String(
				localized: "User Interface Sounds",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'User Interface Sounds' settings option."
			)
		}
	}
	/// The string for the 'Haptics' settings option.
	///
	/// - Tag: L10n-haptics
	static var haptics: String {
		L10n.resolve {
			String(
				localized: "Haptics",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'Haptics' settings option."
			)
		}
	}
	/// The footer string for the haptics settings option.
	///
	/// - Tag: L10n-hapticsFooter
	static var hapticsFooter: String {
		L10n.resolve {
			String(
				localized: "Turning off haptics will only affect custom haptics. Default system controls, like the switches above, will still have a haptic feedback. You can disable all haptics in the Settings app.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The footer string for the haptics settings option."
			)
		}
	}

	// MARK: - Refresh Control Titles

	// MARK: - Theme Store
	/// The menu button for applying a downloaded theme.
	///
	/// - Tag: L10n-applyTheme
	static var applyTheme: String {
		L10n.resolve {
			String(
				localized: "Apply Theme",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The menu button for applying a downloaded theme."
			)
		}
	}
	/// The action sheet button for redownloading an already-purchased theme.
	///
	/// - Tag: L10n-redownloadTheme
	static var redownloadTheme: String {
		L10n.resolve {
			String(
				localized: "Redownload Theme",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The action sheet button for redownloading an already-purchased theme."
			)
		}
	}
	/// The destructive action sheet button for removing a downloaded theme.
	///
	/// - Tag: L10n-removeTheme
	static var removeTheme: String {
		L10n.resolve {
			String(
				localized: "Remove Theme",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The destructive action sheet button for removing a downloaded theme."
			)
		}
	}
	/// Error description shown when the theme storage directory cannot be resolved.
	///
	/// - Tag: L10n-themeStorageUnavailable
	static var themeStorageUnavailable: String {
		L10n.resolve {
			String(
				localized: "The theme storage directory is unavailable.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "Error description shown when the theme storage directory cannot be resolved."
			)
		}
	}

	// MARK: - Browser
	/// The name of the in-app browser option in the browser picker.
	///
	/// - Tag: L10n-browserInAppDefault
	static var browserInAppDefault: String {
		L10n.resolve {
			String(
				localized: "In-app (default)",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The name of the in-app browser option in the browser picker."
			)
		}
	}

	// MARK: - Empty States
	/// The empty-state detail shown when no themes are available in the theme store.
	///
	/// - Tag: L10n-noThemesAvailableDetail
	static var noThemesAvailableDetail: String {
		L10n.resolve {
			String(
				localized: "Themes are not available at this moment. Please check back again later.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail shown when no themes are available in the theme store."
			)
		}
	}
	/// The empty-state title for the debug keychain list when no keys remain.
	///
	/// - Tag: L10n-debugNoKeysTitle
	static var debugNoKeysTitle: String {
		L10n.resolve {
			String(
				localized: "No Keys",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state title for the debug keychain list when no keys remain."
			)
		}
	}
	/// The empty-state detail for the debug keychain list when no keys remain.
	///
	/// - Tag: L10n-debugNoKeysDetail
	static var debugNoKeysDetail: String {
		L10n.resolve {
			String(
				localized: "All keychain entries have been removed.",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The empty-state detail for the debug keychain list when no keys remain."
			)
		}
	}

	// MARK: - Sign In
	/// The string for the 'sign in' action.
	///
	/// - Tag: L10n-signIn
	static var signIn: String {
		L10n.resolve {
			String(
				localized: "Sign In",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The string for the 'sign in' action."
			)
		}
	}

	// MARK: - Appearance
	/// The title of the appearance schedule screen.
	///
	/// - Tag: L10n-appearanceSchedule
	static var appearanceSchedule: String {
		L10n.resolve {
			String(
				localized: "Appearance Schedule",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The title of the appearance schedule screen."
			)
		}
	}
	/// The settings row title for the automatic dark theme schedule start time.
	///
	/// - Tag: L10n-startsAt
	static var startsAt: String {
		L10n.resolve {
			String(
				localized: "Starts at",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The settings row title for the automatic dark theme schedule start time."
			)
		}
	}
	/// The settings switch title for the true black option.
	///
	/// - Tag: L10n-trueBlack
	static var trueBlack: String {
		L10n.resolve {
			String(
				localized: "True Black",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The settings switch title for the true black option."
			)
		}
	}
	/// The settings switch title for the large titles option.
	///
	/// - Tag: L10n-largeTitles
	static var largeTitles: String {
		L10n.resolve {
			String(
				localized: "Large Titles",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The settings switch title for the large titles option."
			)
		}
	}

	// MARK: - Theme Store Buttons
	/// The download button title for an unowned theme.
	///
	/// - Tag: L10n-themeButtonGet
	static var themeButtonGet: String {
		L10n.resolve {
			String(
				localized: "GET",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The download button title for an unowned theme."
			)
		}
	}
	/// The button title for applying a downloaded theme.
	///
	/// - Tag: L10n-themeButtonUse
	static var themeButtonUse: String {
		L10n.resolve {
			String(
				localized: "USE",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button title for applying a downloaded theme."
			)
		}
	}
	/// The button title for updating a downloaded theme.
	///
	/// - Tag: L10n-themeButtonUpdate
	static var themeButtonUpdate: String {
		L10n.resolve {
			String(
				localized: "UPDATE",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button title for updating a downloaded theme."
			)
		}
	}
	/// The button title shown for the currently applied theme.
	///
	/// - Tag: L10n-themeButtonUsing
	static var themeButtonUsing: String {
		L10n.resolve {
			String(
				localized: "USING",
				table: "Settings",
				bundle: LanguageManager.shared.bundle,
				locale: LanguageManager.shared.locale,
				comment: "The button title shown for the currently applied theme."
			)
		}
	}

	// MARK: - Theme Downloads
	/// The download count shown on a theme.
	///
	/// - Parameters:
	///   - formattedCount: The display-formatted download count.
	///   - count: The number of downloads.
	///
	/// - Tag: L10n-downloadsCount
	static func downloadsCount(_ formattedCount: String, count: Int) -> String {
		String(
			localized: "theme.downloadsCount",
			defaultValue: "\(formattedCount) \(count) Downloads",
			table: "Settings",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The download count shown on a theme."
		)
	}

	// MARK: - Settings Sections
	/// The footer for the privacy settings option.
	static var privacySettingsFooter: String {
		L10n.resolve {
			String(localized: "This will send you to Kurozora's privacy settings in the Settings app where you can adjust the app's permissions.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer for the privacy settings option.")
		}
	}
	/// The footer for the browser settings option.
	static var browserSettingsFooter: String {
		L10n.resolve {
			String(localized: "Choose a default browser in which web links will be opened. If you don't have the app installed then the links will open inside Safari as a fallback.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer for the browser settings option.")
		}
	}
	/// The footer for the appearance schedule option.
	static var appearanceScheduleFooter: String {
		L10n.resolve {
			String(localized: "Automatically transition appearance between light and dark based on time preference.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer for the appearance schedule option.")
		}
	}
	/// The footer for the in-app notifications option.
	static var inAppNotificationsFooter: String {
		L10n.resolve {
			String(localized: "Receive notifications inside Kurozora while using the app. This is separate from systemwide notifications for Kurozora.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer for the in-app notifications option.")
		}
	}
	/// The footer for the true black option.
	static var trueBlackFooter: String {
		L10n.resolve {
			String(localized: "Enable this option if you prefer a darker black color. Or if you value your eyes' health while using the app in the dark. Or those precious battery juices. Or or or…", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer for the true black option.")
		}
	}
	/// The footer for the large titles option.
	static var largeTitlesFooter: String {
		L10n.resolve {
			String(localized: "Disable this option if you hate the large titles in the navigation bar #annoying #too_ugly_for_me", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer for the large titles option.")
		}
	}
	/// The appearance schedule value for dark until sunrise.
	static var darkUntilSunrise: String {
		L10n.resolve {
			String(localized: "Dark Until Sunrise", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The appearance schedule value for dark until sunrise.")
		}
	}
	/// The appearance schedule value for light until sunset.
	static var lightUntilSunset: String {
		L10n.resolve {
			String(localized: "Light Until Sunset", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The appearance schedule value for light until sunset.")
		}
	}
	/// The appearance schedule value for dark until a specific time.
	static func darkUntil(_ date: String) -> String {
		L10n.resolve {
			String(localized: "Dark Until \(date)", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The appearance schedule value for dark until a specific time.")
		}
	}
	/// The appearance schedule value for light until a specific time.
	static func lightUntil(_ date: String) -> String {
		L10n.resolve {
			String(localized: "Light Until \(date)", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The appearance schedule value for light until a specific time.")
		}
	}
	/// The 'Appearance' settings section header.
	static var appearance: String {
		L10n.resolve {
			String(localized: "Appearance", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Appearance' settings section header.")
		}
	}
	/// The 'Blindness' settings section header.
	static var blindness: String {
		L10n.resolve {
			String(localized: "Blindness", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Blindness' settings section header.")
		}
	}
	/// The 'Light' appearance option.
	static var light: String {
		L10n.resolve {
			String(localized: "Light", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Light' appearance option.")
		}
	}
	/// The 'Dark' appearance option.
	static var dark: String {
		L10n.resolve {
			String(localized: "Dark", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Dark' appearance option.")
		}
	}
	/// The about-section credit footer.
	static func appCreditFooter(_ version: String, _ build: String) -> String {
		L10n.resolve {
			String(localized: "Built with lack of 😴, lots of 🍵 and 🌸 allergy by Kirito\nKurozora \(version) (\(build))", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The about-section credit footer.")
		}
	}

	// MARK: - Music
	/// The 'On' state value.
	static var on: String {
		L10n.resolve {
			String(localized: "On", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'On' state value.")
		}
	}
	/// The description of the music settings header.
	static var musicHeaderDescription: String {
		L10n.resolve {
			String(localized: "Customize how your music plays and lyrics appear, from blending songs together with crossfade to how far the skip controls seek while held.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The description of the music settings header.")
		}
	}
	/// The audio section title.
	static var audio: String {
		L10n.resolve {
			String(localized: "Audio", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The audio section title.")
		}
	}
	/// The title of the song transitions setting.
	static var songTransitions: String {
		L10n.resolve {
			String(localized: "Song Transitions", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the song transitions setting.")
		}
	}
	/// The footer describing the song transitions setting.
	static var songTransitionsDescription: String {
		L10n.resolve {
			String(localized: "Beginnings and endings of songs blend together seamlessly. Albums and some genres will still play without transitions. Unavailable while using AirPlay.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer describing the song transitions setting.")
		}
	}
	/// The footer describing the crossfade transition style.
	static var crossfadeDescription: String {
		L10n.resolve {
			String(localized: "Simple song transitions from one to the next for a set duration.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer describing the crossfade transition style.")
		}
	}
	/// The title of the crossfade duration setting.
	static var crossfadeDuration: String {
		L10n.resolve {
			String(localized: "Crossfade Duration", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the crossfade duration setting.")
		}
	}
	/// The label showing a duration in seconds in the music settings.
	static func secondsCount(_ count: Int) -> String {
		return String(
			localized: "\(count) seconds",
			table: "Settings",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The label showing a duration in seconds in the music settings."
		)
	}
	/// The title of the skip duration setting.
	static var skipDuration: String {
		L10n.resolve {
			String(localized: "Skip Duration", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the skip duration setting.")
		}
	}
	/// The footer describing the skip duration setting.
	static var skipDurationDescription: String {
		L10n.resolve {
			String(localized: "How far the skip buttons seek when held.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer describing the skip duration setting.")
		}
	}
	/// The title of the larger text setting.
	static var largerText: String {
		L10n.resolve {
			String(localized: "Larger Text", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the larger text setting.")
		}
	}
	/// The footer describing the larger text setting.
	static var largerTextDescription: String {
		L10n.resolve {
			String(localized: "Choose whether lyrics or pronunciation is shown larger when both appear.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer describing the larger text setting.")
		}
	}
	/// The pronunciation larger-text option.
	static var pronunciation: String {
		L10n.resolve {
			String(localized: "Pronunciation", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The pronunciation larger-text option.")
		}
	}
	/// The title of the song change notifications setting.
	static var whenSongChanges: String {
		L10n.resolve {
			String(localized: "When song changes", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the song change notifications setting.")
		}
	}

	// MARK: - Floating Lyrics
	/// The title of the floating lyrics setting.
	static var floatingLyrics: String {
		L10n.resolve {
			String(localized: "Floating Lyrics", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the floating lyrics setting.")
		}
	}
	/// A short description for the floating lyrics settings header.
	static var floatingLyricsDescription: String {
		L10n.resolve {
			String(localized: "Keep lyrics on screen in a small floating window, even when you leave the app.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "A short description for the floating lyrics settings header.")
		}
	}
	/// The title of the floating lyrics font size setting.
	static var fontSize: String {
		L10n.resolve {
			String(localized: "Font Size", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the floating lyrics font size setting.")
		}
	}
	/// The standard font size option.
	static var fontSizeStandard: String {
		L10n.resolve {
			String(localized: "Standard", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The standard font size option.")
		}
	}
	/// The big font size option.
	static var fontSizeBig: String {
		L10n.resolve {
			String(localized: "Big", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The big font size option.")
		}
	}
	/// The title of the floating lyrics display lines setting.
	static var displayLines: String {
		L10n.resolve {
			String(localized: "Display", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the floating lyrics display lines setting.")
		}
	}
	/// The display option showing one lyric line.
	static var oneLine: String {
		L10n.resolve {
			String(localized: "1 Line", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display option showing one lyric line.")
		}
	}
	/// The display option showing two lyric lines.
	static var twoLines: String {
		L10n.resolve {
			String(localized: "2 Lines", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The display option showing two lyric lines.")
		}
	}
	/// The title of the floating lyrics second-line setting when it reveals the original lyrics.
	static var showLyrics: String {
		L10n.resolve {
			String(localized: "Show Lyrics", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the floating lyrics second-line setting when it reveals the original lyrics.")
		}
	}
	/// The title of the floating lyrics translation setting.
	static var showTranslation: String {
		L10n.resolve {
			String(localized: "Show Translation", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the floating lyrics translation setting.")
		}
	}
	/// The footer describing the floating lyrics translation setting.
	static var showTranslationDescription: String {
		L10n.resolve {
			String(localized: "Shows your preferred translation or pronunciation on the second line.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer describing the floating lyrics translation setting.")
		}
	}
	/// The title of the floating lyrics auto-open setting.
	static var openAutomatically: String {
		L10n.resolve {
			String(localized: "Open Automatically", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The title of the floating lyrics auto-open setting.")
		}
	}
	/// The footer describing the floating lyrics auto-open setting.
	static var openAutomaticallyDescription: String {
		L10n.resolve {
			String(localized: "Open the floating lyrics window automatically when you leave the app while music is playing.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer describing the floating lyrics auto-open setting.")
		}
	}

	// MARK: - Library Sync
	/// The 'Sync' settings section header.
	static var sync: String {
		L10n.resolve {
			String(localized: "Sync", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Sync' settings section header.")
		}
	}
	/// The 'Default Sorting' settings section header.
	static var defaultSorting: String {
		L10n.resolve {
			String(localized: "Default Sorting", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The 'Default Sorting' settings section header.")
		}
	}
	/// The row title shown when the last sync happened moments ago.
	static var syncedJustNow: String {
		L10n.resolve {
			String(localized: "Synced just now", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The row title shown when the last sync happened moments ago.")
		}
	}
	/// The row title showing how many minutes ago the library last synced.
	///
	/// - Parameter count: The number of minutes since the last sync.
	static func lastSyncedMinutesAgo(_ count: Int) -> String {
		String(
			localized: "Last synced ^[\(count) minutes](inflect: true) ago",
			table: "Settings",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The row title showing how many minutes ago the library last synced."
		)
	}
	/// The row title showing how many hours ago the library last synced.
	///
	/// - Parameter count: The number of hours since the last sync.
	static func lastSyncedHoursAgo(_ count: Int) -> String {
		String(
			localized: "Last synced ^[\(count) hours](inflect: true) ago",
			table: "Settings",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The row title showing how many hours ago the library last synced."
		)
	}
	/// The row title showing the date the library last synced.
	///
	/// - Parameter formattedDate: The formatted last sync date.
	static func lastSyncedOnDate(_ formattedDate: String) -> String {
		String(
			localized: "Last synced on \(formattedDate)",
			table: "Settings",
			bundle: LanguageManager.shared.bundle,
			locale: LanguageManager.shared.locale,
			comment: "The row title showing the date the library last synced."
		)
	}
	/// The row title shown when the library has never synced.
	static var neverSynced: String {
		L10n.resolve {
			String(localized: "Never synced", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The row title shown when the library has never synced.")
		}
	}
	/// The action row title that forces an immediate library sync.
	static var syncNow: String {
		L10n.resolve {
			String(localized: "Sync now", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The action row title that forces an immediate library sync.")
		}
	}
	/// The detail value shown on the sync-now row while a sync is in progress.
	static var syncingNow: String {
		L10n.resolve {
			String(localized: "Syncing…", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The detail value shown on the sync-now row while a sync is in progress.")
		}
	}
	/// The footer message explaining what the sync section does.
	static var librarySyncFooterMessage: String {
		L10n.resolve {
			String(localized: "Kurozora syncs your library automatically in the background. Use Sync now to fetch changes immediately.", table: "Settings", bundle: LanguageManager.shared.bundle, locale: LanguageManager.shared.locale, comment: "The footer message explaining what the sync section does.")
		}
	}
}
