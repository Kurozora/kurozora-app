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
		case none
		case chevron
		case label
	}

	enum Section {
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

		/// An array containing all settings sections.
		static let all: [Section] = [.account, .debug, .alerts, .general, .support, .social, .about]

		/// An array containing all normal user settings sections.
		static let allUser: [Section] = [.account, .alerts, .general, .support, .social, .about]

		/// An array containing all settings rows separated by all settings sections.
		static let allRow: [Section: [Row]] = [.account: Row.allAccount, .debug: Row.allDebug, .alerts: Row.allAlerts, .general: Row.allGeneral, .support: Row.allSupport, .social: Row.allSocial, .about: Row.allAbout]

		/// An array containing all user settings rows separated by user settings sections.
		static let allUserRow: [Section: [Row]] = [.account: Row.allAccount, .alerts: Row.allAlerts, .general: Row.allGeneral, .support: Row.allSupport, .social: Row.allSocial, .about: Row.allAbout]

		/// The string value of a settings section.
		var stringValue: String {
			switch self {
			case .account:
				return "Account"
			case .debug:
				return "Debug"
			case .alerts:
				return "Alerts"
			case .general:
				return "General"
			case .support:
				return "Support Us"
			case .social:
				return "Social"
			case .about:
				return "About"
			}
		}
	}
}

extension SettingsTableViewController {
	enum Row {
		/// The row representing the account cell.
		case account

		/// The row representing the keychain cell.
		case keychain

		/// The row representing the notifications cell.
		case notifications

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

		/// The row representing the rate cell.
		case rate

		/// The row representing the unlock features cell.
		case unlockFeatures

		/// The row representing the restore features cell.
		case restoreFeatures

		/// The row representing the tip jar cell.
		case tipjar

		/// The row representing the Twitter cell.
		case followTwitter

		/// The row representing the Medium cell.
		case followMedium

		/// An array containing all settings rows.
		static let all: [Row] = [.account, .keychain, .notifications, .displayBlindness, .theme, .icon, .browser, .biometrics, .cache, .privacy, .rate, .unlockFeatures, .restoreFeatures, .tipjar, .followTwitter, .followMedium]

		/// An array containing all normal user settings rows.
		static let allUser: [Row] = [.account, .notifications, .displayBlindness, .theme, .icon, .browser, .biometrics, .cache, .privacy, .rate, .unlockFeatures, .restoreFeatures, .tipjar, .followTwitter, .followMedium]

		/// An array containing all account section settings rows.
		static let allAccount: [Row] = [.account]

		/// An array containing all debug section settings rows.
		static let allDebug: [Row] = [.keychain]

		/// An array containing all alerts section settings rows.
		static let allAlerts: [Row] = [.notifications]

		/// An array containing all general section settings rows.
		static var allGeneral: [Row] {
			#if targetEnvironment(macCatalyst)
			return [.displayBlindness, .theme, .biometrics, .cache, .privacy]
			#else
			return [.displayBlindness, .theme, .icon, .browser, .biometrics, .cache, .privacy]
			#endif
		}

		/// An array containing all support section settings rows.
		static let allSupport: [Row] = [.rate, .unlockFeatures, .restoreFeatures, .tipjar]

		/// An array containing all social section settings rows.
		static let allSocial: [Row] = [.followTwitter, .followMedium]

		/// An array containing all about section settings rows.
		static let allAbout: [Row] = []

		/// The segue identifier string of a settings row.
		var segueIdentifier: String {
			switch self {
			case .account:
				return R.segue.settingsTableViewController.accountSegue.identifier
			case .keychain:
				return R.segue.settingsTableViewController.keysSegue.identifier
			case .notifications:
				return R.segue.settingsTableViewController.notificationSegue.identifier
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
			case .rate:
				return ""
			case .unlockFeatures:
				return R.segue.settingsTableViewController.subscriptionSegue.identifier
			case .restoreFeatures:
				return ""
			case .tipjar:
				return R.segue.settingsTableViewController.tipJarSegue.identifier
			case .followTwitter:
				return ""
			case .followMedium:
				return ""
			}
		}

		/// The accessory value of a settings row.
		var accessoryValue: SettingsTableViewController.Accessory {
			switch self {
			case .account:
				return User.isSignedIn ? .chevron : .none
			case .keychain:
				return .chevron
			case .notifications:
				return .chevron
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
			case .rate:
				return .none
			case .unlockFeatures:
				return .chevron
			case .restoreFeatures:
				return .none
			case .tipjar:
				return .chevron
			case .followTwitter:
				return .none
			case .followMedium:
				return .none
			}
		}

		/// The primary string value of a settings row.
		var primaryStringValue: String {
			switch self {
			case .account:
				return User.current?.username ?? "Sign in to your Kurozora account"
			case .keychain:
				return "Keys Manager"
			case .notifications:
				return "Notifications"
			case .displayBlindness:
				return "Display & Blindness"
			case .theme:
				return "Theme"
			case .icon:
				return "Icon"
			case .browser:
				return "Browser"
			case .biometrics:
				var primaryStringValue = "Passcode"
				switch UIDevice.supportedBiomtetric {
				case .faceID:
					primaryStringValue = "Face ID & Passcode"
				case .touchID:
					primaryStringValue = "Touch ID & Passcode"
				case .none: break
				}
				return primaryStringValue
			case .cache:
				return "Cache"
			case .privacy:
				return "Privacy"
			case .rate:
				return "Rate on App Store"
			case .unlockFeatures:
				return "Unlock Features"
			case .restoreFeatures:
				return "Restore Purchase"
			case .tipjar:
				return "Tip Jar"
			case .followTwitter:
				return "Follow us on Twitter"
			case .followMedium:
				return "Follow our story on Medium"
			}
		}

		/// The secondary string value of a settings row.
		var secondaryStringValue: String {
			switch self {
			case .account:
				return User.isSignedIn ? "Kurozora ID, Sign in with Apple & MAL Import" : "Setup Kurozora ID and more."
			default:
				return ""
			}
		}

		/// The image value of a settings row.
		var imageValue: UIImage? {
			switch self {
			case .account:
				return User.current?.profileImage ?? R.image.placeholders.userProfile()
			case .keychain:
				return R.image.icons.kDefaults()
			case .notifications:
				return R.image.icons.notifications()
			case .displayBlindness:
				return R.image.icons.display()
			case .theme:
				return R.image.icons.theme()
			case .icon:
				return #imageLiteral(resourceName: UserSettings.appIcon)
			case .browser:
				return R.image.icons.browser()
			case .biometrics:
				switch UIDevice.supportedBiomtetric {
				case .faceID:
					return R.image.icons.faceID()
				case .touchID:
					return R.image.icons.touchID()
				case .none:
					return R.image.icons.lock()
				}
			case .cache:
				return R.image.icons.clearCache()
			case .privacy:
				return R.image.icons.privacy()
			case .rate:
				return R.image.icons.rate()
			case .unlockFeatures:
				return R.image.icons.unlock()
			case .restoreFeatures:
				return R.image.icons.restore()
			case .tipjar:
				return R.image.icons.tipJar()
			case .followTwitter:
				return R.image.icons.brands.twitter()
			case .followMedium:
				return R.image.icons.brands.medium()
			}
		}
	}
}
