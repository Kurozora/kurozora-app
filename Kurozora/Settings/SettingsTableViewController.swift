//
//  SettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import SwiftTheme

class SettingsTableViewController: UITableViewController {
//	let FacebookPageDeepLink = "fb://profile/713541968752502"
//	let FacebookPageURL = "https://www.facebook.com/KurozoraApp"
    let twitterPageDeepLink = "twitter://user?id=991929359052177409"
    let twitterPageURL = "https://www.twitter.com/KurozoraApp"
    let mediumPageDeepLink = "medium://@kurozora"
    let mediumPageURL = "https://medium.com/@kurozora"

	// Section vars
	let sectionTitles = ["Account", "Admin", "Alerts", "General", "In-App Purchases", "Rate", "Social", "About"]

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}

    // MARK: - Functions
	/**
		Calculate the amount of data that is cached by the app.

		- Parameter successHandler: A closure that returns a string representing the amount of data that is cached by the app.
		- Parameter cacheString: The string representing the amount of data that is cached by the app.
	*/
	func calculateCache(withSuccess successHandler:@escaping (_ cacheString: String) -> Void) {
		ImageCache.default.calculateDiskStorageSize { (result) in
			switch result {
			case .success(let size):
				// Convert from bytes to mebibytes (2^20)
				let sizeInMiB = Double(size) / 1024 / 1024
				successHandler(String(format: "%.2f", sizeInMiB) + "MiB")
			case .failure(let error):
				print("Cache size calculation error: \(error)")
			}
		}
    }

    // MARK: - IBActions
    @IBAction func dismissPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension SettingsTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let numberOfRows = super.tableView(tableView, numberOfRowsInSection: section)
		if !User.isAdmin && section == 1 {
			return numberOfRows - 1
		}

		return numberOfRows
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if !User.isAdmin && section == 1 {
			return	nil
		}

		return (section != sectionTitles.count - 1) ? sectionTitles[section] : nil
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let settingsCell = super.tableView(tableView, cellForRowAt: indexPath) as! SettingsCell

		if !User.isAdmin && indexPath.section == 1 {
			return super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: indexPath.section + 1))
		}

		if settingsCell.cacheSizeLabel != nil {
			self.calculateCache(withSuccess: { (cacheSize) in
				settingsCell.cacheSizeLabel?.text = cacheSize
			})
		}

		return settingsCell
	}

//    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return nil
//        case 1:
//            var message = ""
//            if let user = User.currentUser(),
//                user.hasTrial() &&
//                    InAppController.purchasedPro() == nil &&
//                    InAppController.purchasedProPlus() == nil {
//                message = "** You're on a 15 day PRO trial **\n"
//            }
//            message += "Going PRO unlocks all features and help us keep improving the app"
//            return message
//        case 2:
//            return "If you're looking for support drop us a message on Facebook or Twitter"
//        case 3:
//            let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
//            let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
//            return "Created by Anime fans for Anime fans, enjoy!\nKurozora \(version) (\(build))"
//        default:
//            return nil
//        }
//    }
}

// MARK: - UITableViewDelegate
extension SettingsTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if !User.isAdmin && section == 1 {
			return	CGFloat.leastNormalMagnitude
		}
		return (section != sectionTitles.count - 1) ? 33 : CGFloat.leastNormalMagnitude
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if !User.isAdmin, indexPath.section == 1 {
			return CGFloat.leastNormalMagnitude
		}
		return super.tableView(tableView, heightForRowAt: indexPath)
	}

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView {
			headerView.textLabel?.font = UIFont.systemFont(ofSize: 15)
			headerView.textLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		if let footerView = view as? UITableViewHeaderFooterView {
			footerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let authenticationSettingsCell = tableView.cellForRow(at: indexPath) as? AuthenticationSettingsCell {
			authenticationSettingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			authenticationSettingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellSelectedChevronColor.rawValue

			authenticationSettingsCell.authenticationTitleLabel?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
		} else if let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell {
			settingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			settingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellSelectedChevronColor.rawValue

			settingsCell.cellTitle?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			settingsCell.cellSubTitle?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
			settingsCell.usernameLabel?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			settingsCell.cacheSizeLabel?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let authenticationSettingsCell = tableView.cellForRow(at: indexPath) as? AuthenticationSettingsCell {
			authenticationSettingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			authenticationSettingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue

			authenticationSettingsCell.authenticationTitleLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		} else if let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell {
			settingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			settingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue

			settingsCell.cellTitle?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			settingsCell.cellSubTitle?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			settingsCell.usernameLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			settingsCell.cacheSizeLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		tableView.deselectRow(at: indexPath, animated: true)
		let settingsCell = tableView.cellForRow(at: indexPath) as! SettingsCell

		switch (indexPath.section, indexPath.row) {
//		case (0, 0): break
//		case (1, 0): break
//		case (2, 0): break
//		case (3, 0): break
		case (3, 4): // Clear cache
			let alertView = SCLAlertView()
			alertView.addButton("Clear 🗑", action: {
				// Clear memory cache right away.
				KingfisherManager.shared.cache.clearMemoryCache()

				// Clear disk cache. This is an async operation.
				KingfisherManager.shared.cache.clearDiskCache()

				// Clean expired or size exceeded disk cache. This is an async operation.
				KingfisherManager.shared.cache.cleanExpiredDiskCache()

				// Refresh cacheSizeLabel
				self.calculateCache(withSuccess: { (cacheSize) in
					settingsCell.cacheSizeLabel?.text = cacheSize
				})
			})

			alertView.showWarning("Clear all cache?", subTitle: "All of your caches will be cleared and Kurozora will restart.", closeButtonTitle: "Cancel")
//		case (4, 0): // Unlock features
//		case (4, 1): // Restore purchases
//			InAppTransactionController.restorePurchases().continueWithBlock({ (task: BFTask!) -> AnyObject? in
//				if let _ = task.result {
//					let alert = UIAlertController(title: "Restored!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//					alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//
//					self.presentViewController(alert, animated: true, completion: nil)
//				}
//
//				return nil
//			})
//		case (5, 0): // Rate app
//			iRate.sharedInstance().openRatingsPageInAppStore()
		case (6, 0): // Open Twitter
			var url: URL?
			let twitterScheme = URL(string: "twitter://")!

			if UIApplication.shared.canOpenURL(twitterScheme) {
				url = URL(string: twitterPageDeepLink)
			} else {
				url = URL(string: twitterPageURL)
			}
			UIApplication.shared.open(url!, options: [:], completionHandler: nil)
		case (6, 1): // Open Medium
			var url: URL?
			let mediumScheme = URL(string: "medium://")!

			if UIApplication.shared.canOpenURL(mediumScheme) {
				url = URL(string: mediumPageDeepLink)
			} else {
				url = URL(string: mediumPageURL)
			}
			UIApplication.shared.open(url!, options: [:], completionHandler: nil)
		default: break
		}
	}
}
