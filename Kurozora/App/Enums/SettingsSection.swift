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
		/// Indicates the cell has a cheevron as accessory.
		case chevron
		/// Indicates the cell has a label as accessory.
		case label
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

			sections.append(contentsOf: [.alerts, .general, .support, .social, .about])
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

		/// The row representing the notifications cell.
		case notifications

		/// The row representing the sounds and haptics cell.
		case soundsAndHaptics

		/// The row representing the reminder cell.
		case reminder

		/// The row representing the display and blindness cell.
		case displayBlindness

		/// The row representing the theme cell.
		case theme

		/// The row representing the icon cell.
		case icon

		/// The row representing the browser cell.
		case browser

		/// The row representing the biometrics cell.
		case biometrics

		/// The row representing the cache cell.
		case cache

		/// The row representing the privacy cell.
		case privacy

		/// The row representing the unlock features cell.
		case unlockFeatures

		/// The row representing the tip jar cell.
		case tipjar

		/// The row representing the manage subsctions cell.
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
		static let all: [Row] = [.account, .switchAccount, .keychain, .notifications, .soundsAndHaptics, .reminder, .displayBlindness, .theme, .icon, .browser, .biometrics, .cache, .privacy, .unlockFeatures, .tipjar, .restoreFeatures, .rate, .joinDiscord, .followGitHub, .followMastodon, .followTwitter]
		#else
		/// An array containing all normal user settings rows.
		static let all: [Row] = [.account, .switchAccount, .notifications, .soundsAndHaptics, .reminder, .displayBlindness, .theme, .icon, .browser, .biometrics, .cache, .privacy, .unlockFeatures, .tipjar, .restoreFeatures, .rate, .joinDiscord, .followGitHub, .followMastodon, .followTwitter]
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
		static var allAlerts: [Row] = [.notifications, .soundsAndHaptics, .reminder]

		/// An array containing all general section settings rows.
		static var allGeneral: [Row] {
			#if targetEnvironment(macCatalyst)
			return [.displayBlindness, .theme, .biometrics, .cache, .privacy]
			#else
			return [.displayBlindness, .theme, .icon, .browser, .biometrics, .cache, .privacy]
			#endif
		}

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

		/// An array containing all social section settings rows.
		static let allSocial: [Row] = [.rate, .joinDiscord, .followGitHub, .followMastodon, .followTwitter]

		/// An array containing all about section settings rows.
		static let allAbout: [Row] = []

		/// The segue identifier string of a settings row.
		var segueIdentifier: String {
			switch self {
			case .account:
				return R.segue.settingsTableViewController.accountSegue.identifier
			case .switchAccount:
				return R.segue.settingsTableViewController.switchAccountSegue.identifier
			case .keychain:
				return R.segue.settingsTableViewController.keysSegue.identifier
			case .notifications:
				return R.segue.settingsTableViewController.notificationSegue.identifier
			case .soundsAndHaptics:
				return R.segue.settingsTableViewController.soundSegue.identifier
			case .reminder:
				return ""
			case .displayBlindness:
				return R.segue.settingsTableViewController.displaySegue.identifier
			case .theme:
				return R.segue.settingsTableViewController.themeSegue.identifier
			case .icon:
				return R.segue.settingsTableViewController.iconSegue.identifier
			case .browser:
				return R.segue.settingsTableViewController.broswerSegue.identifier
			case .biometrics:
				return R.segue.settingsTableViewController.biometricsSegue.identifier
			case .cache:
				return ""
			case .privacy:
				return R.segue.settingsTableViewController.privacySegue.identifier
			case .unlockFeatures:
				return R.segue.settingsTableViewController.subscriptionSegue.identifier
			case .tipjar:
				return R.segue.settingsTableViewController.tipJarSegue.identifier
			case .manageSubscriptions:
				return ""
			case .restoreFeatures:
				return ""
//			case .requestRefund:
//				return ""
			case .rate:
				return ""
			case .joinDiscord:
				return ""
			case .followGitHub:
				return ""
			case .followMastodon:
				return ""
			case .followTwitter:
				return ""
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
			case .notifications:
				return .chevron
			case .soundsAndHaptics:
				return .chevron
			case .reminder:
				return .none
			case .displayBlindness:
				return .chevron
			case .theme:
				return .chevron
			case .icon:
				return .chevron
			case .browser:
				return .chevron
			case .biometrics:
				return .chevron
			case .cache:
				return .label
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
			case .notifications:
				return Trans.notifications
			case .soundsAndHaptics:
				#if targetEnvironment(macCatalyst)
				return Trans.sound
				#else
				return Trans.soundsAndHaptics
				#endif
			case .reminder:
				return Trans.subscribeToReminders
			case .displayBlindness:
				return Trans.displayBlindness
			case .theme:
				return Trans.theme
			case .icon:
				return Trans.icon
			case .browser:
				return Trans.browser
			case .biometrics:
				switch UIDevice.supportedBiomtetric {
				case .faceID:
					return Trans.faceIDPasscode
				case .touchID:
					return Trans.touchIDPasscode
				case .opticID:
					return Trans.opticIDPasscode
				default:
					return Trans.passcode
				}
			case .cache:
				return Trans.cache
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
			default:
				return ""
			}
		}

		/// The image value of a settings row.
		var imageValue: UIImage? {
			switch self {
			case .account:
				return User.current?.attributes.profileImageView.image ?? R.image.placeholders.userProfile()
			case .switchAccount:
				return R.image.icons.accountSwitch()
			case .keychain:
				return R.image.icons.kDefaults()
			case .notifications:
				return R.image.icons.notifications()
			case .soundsAndHaptics:
				return R.image.icons.sound()
			case .reminder:
				return R.image.icons.reminder()
			case .displayBlindness:
				return R.image.icons.display()
			case .theme:
				return R.image.icons.theme()
			case .icon:
				return UIImage(named: UserSettings.appIcon)
			case .browser:
				return R.image.icons.browser()
			case .biometrics:
				switch UIDevice.supportedBiomtetric {
				case .faceID:
					return R.image.icons.faceID()
				case .touchID:
					return R.image.icons.touchID()
				default:
					return R.image.icons.lock()
				}
			case .cache:
				return R.image.icons.clearCache()
			case .privacy:
				return R.image.icons.privacy()
			case .unlockFeatures:
				return R.image.icons.unlock()
			case .tipjar:
				return R.image.icons.tipJar()
			case .manageSubscriptions:
				return R.image.icons.manageSubscriptions()
			case .restoreFeatures:
				return R.image.icons.restore()
//			case .requestRefund:
//				return R.image.icons.refund()
			case .rate:
				return R.image.icons.rate()
			case .joinDiscord:
				return R.image.icons.brands.discord()
			case .followGitHub:
				return R.image.icons.brands.gitHub()
			case .followMastodon:
				return R.image.icons.brands.mastodon()
			case .followTwitter:
				return R.image.icons.brands.twitter()
			}
		}
	}
}
