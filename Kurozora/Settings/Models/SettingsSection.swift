//
//  SettingsSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension SettingsTableViewController {
	enum Accessory {
		case none
		case chevron
		case label
	}

	enum Section {
		/// The section representing the account group of cells.
		case account

		/// The section representing the admin group of cells.
		case admin

		/// The section representing the alerts group of cells.
		case alerts

		/// The section representing the general group of cells.
		case general

		/// The section representing the iap group of cells.
		case iap

		/// The section representing the rate group of cells.
		case rate

		/// The section representing the social group of cells.
		case social

		/// The section representing the about group of cells.
		case about

		/// An array containing all settings sections.
		static let all: [Section] = [.account, .admin, .alerts, .general, .iap, .rate, .social, .about]

		/// An array containing all normal user settings sections.
		static let allUser: [Section] = [.account, .alerts, .general, .iap, .rate, .social, .about]

		/// An array containing all settings rows separated by all settings sections.
		static let allRow: [Section: [Row]] = [.account: Row.allAccount, .admin: Row.allAdmin, .alerts: Row.allAlerts, .general: Row.allGeneral, .iap: Row.allIAP, .rate: Row.allRate, .social: Row.allSocial, .about: Row.allAbout]

		/// An array containing all user settings rows separated by user settings sections.
		static let allUserRow: [Section: [Row]] = [.account: Row.allAccount, .alerts: Row.allAlerts, .general: Row.allGeneral, .iap: Row.allIAP, .rate: Row.allRate, .social: Row.allSocial, .about: Row.allAbout]

		/// The string value of a settings section.
		var stringValue: String {
			switch self {
			case .account:
				return "Account"
			case .admin:
				return "Admin"
			case .alerts:
				return "Alerts"
			case .general:
				return "General"
			case .iap:
				return "In-App Purchases"
			case .rate:
				return "Rate"
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

		/// The row representing the biometrics cell.
		case biometrics

		/// The row representing the cache cell.
		case cache

		/// The row representing the privacy cell.
		case privacy

		/// The row representing the unlock features cell.
		case unlockFeatures

		/// The row representing the restore features cell.
		case restoreFeatures

		/// The row representing the rate cell.
		case rate

		/// The row representing the Twitter cell.
		case followTwitter

		/// The row representing the Medium cell.
		case followMedium

		/// An array containing all settings rows.
		static let all: [Row] = [.account, .keychain, .notifications, .displayBlindness, .theme, .icon, .biometrics, .cache, .privacy, .unlockFeatures, .restoreFeatures, .rate, .followTwitter, .followMedium]

		/// An array containing all normal user settings rows.
		static let allUser: [Row] = [.account, .notifications, .displayBlindness, .theme, .icon, .biometrics, .cache, .privacy, .unlockFeatures, .restoreFeatures, .rate, .followTwitter, .followMedium]

		/// An array containing all account section settings rows.
		static let allAccount: [Row] = [.account]

		/// An array containing all admin section settings rows.
		static let allAdmin: [Row] = [.keychain]

		/// An array containing all alerts section settings rows.
		static let allAlerts: [Row] = [.notifications]

		/// An array containing all general section settings rows.
		static let allGeneral: [Row] = [.displayBlindness, .theme, .icon, .biometrics, .cache, .privacy]

		/// An array containing all in-app purchases section settings rows.
		static let allIAP: [Row] = [.unlockFeatures, .restoreFeatures]

		/// An array containing all rate section settings rows.
		static let allRate: [Row] = [.rate]

		/// An array containing all social section settings rows.
		static let allSocial: [Row] = [.followTwitter, .followMedium]

		/// An array containing all about section settings rows.
		static let allAbout: [Row] = []

		/// The cell identifier string of a settings row.
		var identifierString: String {
			switch self {
			case .account:
				return "AccountSegue"
			case .keychain:
				return "KeysSegue"
			case .notifications:
				return "NotificationSegue"
			case .displayBlindness:
				return "DisplaySegue"
			case .theme:
				return "ThemeSegue"
			case .icon:
				return "IconSegue"
			case .biometrics:
				return "BiometricsSegue"
			case .cache:
				return "CacheSegue"
			case .privacy:
				return "PrivacySegue"
			case .unlockFeatures:
				return "IAPSegue"
			case .restoreFeatures:
				return ""
			case .rate:
				return ""
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
			case .biometrics:
				return .chevron
			case .cache:
				return .label
			case .privacy:
				return .none
			case .unlockFeatures:
				return .none
			case .restoreFeatures:
				return .none
			case .rate:
				return .none
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
				return Kurozora.shared.KDefaults["username"] ?? "Sign in to your Kurozora account"
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
			case .unlockFeatures:
				return "Unlock Features"
			case .restoreFeatures:
				return "Restore Purchase"
			case .rate:
				return "Rate us on the App Store"
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
				return User.isSignedIn ? "Kurozora ID" : "Setup Kurozora ID and more."
			default:
				return ""
			}
		}

		/// The image value of a settings row.
		var imageValue: UIImage {
			switch self {
			case .account:
				return User.currentUserProfileImage
			case .keychain:
				return #imageLiteral(resourceName: "kdefaults_icon")
			case .notifications:
				return #imageLiteral(resourceName: "notifications_icon")
			case .displayBlindness:
				return #imageLiteral(resourceName: "display_icon")
			case .theme:
				return #imageLiteral(resourceName: "theme_icon")
			case .icon:
				return #imageLiteral(resourceName: UserSettings.appIcon)
			case .biometrics:
				switch UIDevice.supportedBiomtetric {
				case .faceID:
					return #imageLiteral(resourceName: "face_id_icon")
				case .touchID:
					return #imageLiteral(resourceName: "touch_id_icon")
				case .none:
					return #imageLiteral(resourceName: "lock_icon")
				}
			case .cache:
				return #imageLiteral(resourceName: "clear_cache_icon")
			case .privacy:
				return #imageLiteral(resourceName: "privacy_icon")
			case .unlockFeatures:
				return #imageLiteral(resourceName: "unlock_icon")
			case .restoreFeatures:
				return #imageLiteral(resourceName: "restore_icon")
			case .rate:
				return #imageLiteral(resourceName: "rate_icon")
			case .followTwitter:
				return #imageLiteral(resourceName: "twitter_icon")
			case .followMedium:
				return #imageLiteral(resourceName: "medium_icon")
			}
		}
	}
}
