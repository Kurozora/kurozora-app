//
//  SettingsSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension SettingsTableViewController {
	enum Accessory {
		// MARK: - Cases
		/// Indicates the cell has no accessory views.
		case none
		/// Indicates the cell has a chevron as accessory.
		case chevron
		/// Indicates the cell has a label as accessory.
		case label
		/// Indicates the cell has a label and a chevron as accessory.
		case labelAndChevron
	}

	enum Section {
		// MARK: - Cases
		/// The section representing the account group of cells.
		case account

		/// The section representing the debug group of cells.
		case debug

		/// The section representing the alerts group of cells.
		case alerts

		/// The section representing the general group of cells.
		case general

		/// The section representing the stickers group of cells.
		case stickers

		/// The section representing the security group of cells.
		case security

		/// The section representing the support group of cells.
		case support

		/// The section representing the social group of cells.
		case social

		/// The section representing the about group of cells.
		case about

		// MARK: - Properties
		/// An array containing all settings sections.
		static var all: [Section] {
			var sections: [Section] = [.account]

			#if DEBUG
			sections.append(.debug)
			#endif

			sections.append(contentsOf: [.general, .alerts, .stickers, .security, .support, .social, .about])
			return sections
		}

		/// The row values of a settings section.
		var rowsValue: [Row] {
			switch self {
			case .account:
				return Row.allAccount
			case .debug:
				return Row.allDebug
			case .alerts:
				return Row.allAlerts
			case .general:
				return Row.allGeneral
			case .stickers:
				return Row.allStickers
			case .security:
				return Row.allSecurity
			case .support:
				return Row.allSupport
			case .social:
				return Row.allSocial
			case .about:
				return Row.allAbout
			}
		}

		/// The string value of a settings section.
		var stringValue: String {
			switch self {
			case .account:
				return Trans.account
			case .debug:
				return Trans.debug
			case .alerts:
				return Trans.alerts
			case .general:
				return Trans.general
			case .stickers:
				return Trans.stickers
			case .security:
				return Trans.security
			case .support:
				return Trans.supportUs
			case .social:
				return Trans.social
			case .about:
				return Trans.about
			}
		}
	}
}

extension SettingsTableViewController {
	enum Row {
		/// The row representing the account cell.
		case account

		/// The row representing the switch account cell.
		case switchAccount

		/// The row representing the keychain cell.
		case keychain

		/// The row representing the browser cell.
		case browser

		/// The row representing the cache cell.
		case cache

		/// The row representing the display and blindness cell.
		case displayBlindness

		/// The row representing the icon cell.
		case icon

		/// The row representing the library cell.
		case library

		/// The row representing the motion cell.
		case motion

		/// The row representing the theme cell.
		case theme

		/// The row representing the notifications cell.
		case notifications

		/// The row representing the reminder cell.
		case reminder

		/// The row representing the sounds and haptics cell.
		case soundsAndHaptics

		/// The row representing the Signal sticker cell.
		case signalSticker

		/// The row representing the Telegram sticker cell.
		case telegramSticker

//		/// The row representing the WhatsApp sticker cell.
//		case whatsAppSticker

		/// The row representing the biometrics cell.
		case biometrics

		/// The row representing the privacy cell.
		case privacy

		/// The row representing the unlock features cell.
		case unlockFeatures

		/// The row representing the tip jar cell.
		case tipjar

		/// The row representing the manage subscriptions cell.
		case manageSubscriptions

		/// The row representing the restore cell.
		case restoreFeatures

//		/// The row representing the refund request cell.
//		case requestRefund

		/// The row representing the rate cell.
		case rate

		/// The row representing the Discord cell.
		case joinDiscord

		/// The row representing the GitHub cell.
		case followGitHub

		/// The row representing the Mastodon cell.
		case followMastodon

		/// The row representing the Twitter cell.
		case followTwitter

		#if DEBUG
		/// An array containing all settings rows.
		static let all: [Row] = [.account, .switchAccount, .keychain, .notifications, .reminder, .soundsAndHaptics, .browser, .cache, .displayBlindness, .icon, .library, .motion, .theme, .biometrics, .privacy, .signalSticker, .telegramSticker, .unlockFeatures, .tipjar, .restoreFeatures, .rate, .joinDiscord, .followGitHub, .followMastodon, .followTwitter]
		#else
		/// An array containing all normal user settings rows.
		static let all: [Row] = [.account, .switchAccount, .notifications, .reminder, .soundsAndHaptics, .browser, .cache, .displayBlindness, .icon, .library, .motion, .theme, .biometrics, .privacy, .signalSticker, .telegramSticker, .unlockFeatures, .tipjar, .restoreFeatures, .rate, .joinDiscord, .followGitHub, .followMastodon, .followTwitter]
		#endif

		/// An array containing all account section settings rows.
		static var allAccount: [Row] {
			if User.isSignedIn || !SharedDelegate.shared.keychain.allKeys().isEmpty {
				return [.account, .switchAccount]
			}

			return [.account]
		}

		/// An array containing all debug section settings rows.
		static let allDebug: [Row] = [.keychain]

		/// An array containing all alerts section settings rows.
		static var allAlerts: [Row] = [.notifications, .reminder, .soundsAndHaptics]

		/// An array containing all general section settings rows.
		static var allGeneral: [Row] {
			#if targetEnvironment(macCatalyst)
			return [.cache, .displayBlindness, .library, .motion, .theme]
			#else
			return [.browser, .cache, .displayBlindness, .icon, .library, .motion, .theme]
			#endif
		}

		/// An array containing all general section settings rows.
		static var allStickers: [Row] = [.signalSticker, .telegramSticker]

		/// An array containing all support section settings rows.
		static var allSupport: [Row] {
			#if targetEnvironment(macCatalyst)
			return [.unlockFeatures, .tipjar, .restoreFeatures]
			#else
			if ProcessInfo.processInfo.isiOSAppOnMac {
				return [.unlockFeatures, .tipjar, .restoreFeatures]
			} else {
				return [.unlockFeatures, .tipjar, .restoreFeatures]
			}
			#endif
		}

		/// An array containing all security section settings rows.
		static let allSecurity: [Row] = [.biometrics, .privacy]

		/// An array containing all social section settings rows.
		static let allSocial: [Row] = [.rate, .joinDiscord, .followGitHub, .followMastodon, .followTwitter]

		/// An array containing all about section settings rows.
		static let allAbout: [Row] = []

		/// The segue identifier string of a settings row.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .cache, .reminder,
			     .signalSticker, .telegramSticker, // .whatsAppSticker,
			     .manageSubscriptions, .restoreFeatures, // .requestRefund,
			     .rate, .joinDiscord, .followGitHub, .followMastodon, .followTwitter:
				return nil
			case .account:
				return .accountSegue
			case .switchAccount:
				return .switchAccountSegue
			case .keychain:
				return .keysSegue
			case .browser:
				return .browserSegue
			case .displayBlindness:
				return .displaySegue
			case .icon:
				return .iconSegue
			case .library:
				return .librarySegue
			case .motion:
				return .motionSegue
			case .theme:
				return .themeSegue
			case .notifications:
				return .notificationSegue
			case .soundsAndHaptics:
				return .soundSegue
			case .biometrics:
				return .biometricsSegue
			case .privacy:
				return .privacySegue
			case .unlockFeatures:
				return .subscriptionSegue
			case .tipjar:
				return .tipJarSegue
			}
		}

		/// The accessory value of a settings row.
		var accessoryValue: SettingsTableViewController.Accessory {
			switch self {
			case .account:
				return User.isSignedIn ? .chevron : .none
			case .switchAccount:
				return .chevron
			case .keychain:
				return .chevron
			case .browser:
				return .labelAndChevron
			case .cache:
				return .label
			case .displayBlindness:
				return .chevron
			case .icon:
				return .labelAndChevron
			case .library:
				return .chevron
			case .motion:
				return .labelAndChevron
			case .theme:
				return .labelAndChevron
			case .notifications:
				return .chevron
			case .reminder:
				return .none
			case .soundsAndHaptics:
				return .chevron
			case .signalSticker:
				return .chevron
			case .telegramSticker:
				return .chevron
//			case .whatsAppSticker:
//				return .chevron
			case .biometrics:
				return .chevron
			case .privacy:
				return .chevron
			case .unlockFeatures:
				return .chevron
			case .tipjar:
				return .chevron
			case .manageSubscriptions:
				return .none
			case .restoreFeatures:
				return .none
//			case .requestRefund:
//				return .none
			case .rate:
				return .none
			case .joinDiscord:
				return .none
			case .followGitHub:
				return .none
			case .followMastodon:
				return .none
			case .followTwitter:
				return .none
			}
		}

		/// The primary string value of a settings row.
		var primaryStringValue: String {
			switch self {
			case .account:
				return User.current?.attributes.username ?? Trans.accountHeadline
			case .switchAccount:
				return Trans.switchAccount
			case .keychain:
				return Trans.keysManager
			case .browser:
				return Trans.browser
			case .cache:
				return Trans.cache
			case .displayBlindness:
				return Trans.displayBlindness
			case .icon:
				return Trans.icon
			case .library:
				return Trans.library
			case .motion:
				return Trans.motion
			case .theme:
				return Trans.theme
			case .notifications:
				return Trans.notifications
			case .reminder:
				return Trans.subscribeToReminders
			case .soundsAndHaptics:
				#if targetEnvironment(macCatalyst)
				return Trans.sound
				#else
				return Trans.soundsAndHaptics
				#endif
			case .signalSticker:
				return Trans.addStickerToSignal
			case .telegramSticker:
				return Trans.addStickerToTelegram
//			case .whatsAppStickers:
//				return "Add Sticker to WhatsApp"
			case .biometrics:
				return UIDevice.supportedBiometric.localizedSettingsName
			case .privacy:
				return Trans.privacy
			case .unlockFeatures:
				return Trans.unlockFeatures
			case .tipjar:
				return Trans.tipJar
			case .manageSubscriptions:
				return Trans.manageSubscriptions
			case .restoreFeatures:
				return Trans.restorePurchase
//			case .requestRefund:
//				return Trans.RequestRefund
			case .rate:
				return Trans.rateAppStore
			case .joinDiscord:
				return Trans.joinDiscord
			case .followGitHub:
				return Trans.followGitHub
			case .followMastodon:
				return Trans.followMastodon
			case .followTwitter:
				return Trans.followTwitter
			}
		}

		/// The secondary string value of a settings row.
		var secondaryStringValue: String {
			switch self {
			case .account:
				return User.isSignedIn ? Trans.accountSignedInSubheadline : Trans.accountSubheadline
			case .browser:
				return UserSettings.defaultBrowser.shortStringValue
			case .icon:
				return UserSettings.appIcon.replacingOccurrences(of: " Preview", with: "")
			case .motion:
				return UserSettings.currentSplashScreenAnimation.titleValue
			case .theme:
				return UserSettings.currentThemeName
			default:
				return ""
			}
		}

		/// The image value of a settings row.
		var imageValue: UIImage? {
			switch self {
			case .account:
                return User.current?.attributes.profileImageView.image ?? .Placeholders.userProfile
			case .switchAccount:
                return .Icons.accountSwitch
			case .keychain:
                return .Icons.kDefaults
			case .browser:
                return .Icons.browser
			case .cache:
                return .Icons.clearCache
			case .displayBlindness:
                return .Icons.textformatSize
			case .icon:
				return UIImage(named: UserSettings.appIcon)
			case .library:
                return .Icons.library
			case .motion:
                return .Icons.motion
			case .theme:
                return .Icons.theme
			case .notifications:
                return .Icons.notifications
			case .reminder:
                return .Icons.reminder
			case .soundsAndHaptics:
                return .Icons.sound
			case .signalSticker:
                return .Icons.kuroChanStickerSignal
			case .telegramSticker:
                return .Icons.kuroChanStickerTelegram
//			case .whatsAppSticker:
//				return .Icons.kuroChanStickerWhatsApp
			case .biometrics:
				return UIDevice.supportedBiometric.imageValue
			case .privacy:
                return .Icons.privacy
			case .unlockFeatures:
                return .Icons.unlock
			case .tipjar:
                return .Icons.tipJar
			case .manageSubscriptions:
                return .Icons.manageSubscriptions
			case .restoreFeatures:
                return .Icons.restore
//			case .requestRefund:
//				return .Icons.refund
			case .rate:
                return .Icons.rate
			case .joinDiscord:
                return .Icons.Brands.discord
			case .followGitHub:
                return .Icons.Brands.gitHub
			case .followMastodon:
                return .Icons.Brands.mastodon
			case .followTwitter:
                return .Icons.Brands.twitter
			}
		}
	}
}
