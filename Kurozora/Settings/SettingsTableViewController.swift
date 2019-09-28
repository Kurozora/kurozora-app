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
	// MARK: - Properties
    let twitterPageDeepLink = "twitter://user?id=991929359052177409"
    let twitterPageURL = "https://www.twitter.com/KurozoraApp"
    let mediumPageDeepLink = "medium://@kurozora"
    let mediumPageURL = "https://medium.com/@kurozora"

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .KUserIsSignedInDidChange, object: nil)

		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension
	}

    // MARK: - Functions
	@objc private func reloadData() {
		tableView.reloadData()
	}

    // MARK: - IBActions
    @IBAction func dismissPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension SettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return User.isAdmin ? Section.all.count : Section.allUser.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let numberOfRowsInSection = User.isAdmin ? Section.allRow[Section.all[section]] : Section.allUserRow[Section.allUser[section]]
		return numberOfRowsInSection?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = User.isAdmin ? Section.all[section] : Section.allUser[section]
		return section == .about ? nil : section.stringValue
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = indexPath == [0, 0] ? "AccountCell" : "SettingsCell"
		let settingsCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SettingsCell
		let sectionRow = User.isAdmin ? Section.allRow[Section.all[indexPath.section]] : Section.allUserRow[Section.allUser[indexPath.section]]
		settingsCell.sectionRow = sectionRow?[indexPath.row]
		return settingsCell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		let settingsSection = User.isAdmin ? Section.all : Section.allUser

		switch settingsSection[section] {
		case .iap:
			return """
			Going pro unlocks lots of awesome features and helps us keep improving the app 🚀
			"""
		case .about:
			return """
			Built with lack of 😴, lots of 🍵 and 🌸 allergy by Kirito
			Kurozora \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "1.0.0") (\(Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) ?? "0"))
			"""
		default:
			return nil
		}
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
//            return "If you're looking for support drop us a message on Twitter"
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
		if let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell {
			settingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
			settingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellSelectedChevronColor.rawValue

			settingsCell.primaryLabel?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			settingsCell.secondaryLabel?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell {
			settingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			settingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue

			settingsCell.primaryLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			settingsCell.secondaryLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let sectionRow = User.isAdmin ? Section.allRow[Section.all[indexPath.section]]?[indexPath.row] : Section.allUserRow[Section.allUser[indexPath.section]]?[indexPath.row]
		var shouldPerformSegue = true

		switch sectionRow {
		case .account:
			WorkflowController.shared.isSignedIn()
			shouldPerformSegue = User.isSignedIn
		case .notifications:
			WorkflowController.shared.isSignedIn()
			shouldPerformSegue = User.isSignedIn
		case .cache:
			let alertView = SCLAlertView()
			alertView.addButton("Clear 🗑", action: {
				// Clear memory cache right away.
				KingfisherManager.shared.cache.clearMemoryCache()

				// Clear disk cache. This is an async operation.
				KingfisherManager.shared.cache.clearDiskCache()

				// Clean expired or size exceeded disk cache. This is an async operation.
				KingfisherManager.shared.cache.cleanExpiredDiskCache()

				// Refresh cacheSizeLabel
				tableView.reloadData()
			})

			alertView.showWarning("Clear all cache?", subTitle: "All of your caches will be cleared and Kurozora will restart.", closeButtonTitle: "Cancel")
			return
//		case .restoreFeatures:
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
		case .followTwitter:
			var url: URL?
			let twitterScheme = URL(string: "twitter://")!

			if UIApplication.shared.canOpenURL(twitterScheme) {
				url = URL(string: twitterPageDeepLink)
			} else {
				url = URL(string: twitterPageURL)
			}
			UIApplication.shared.open(url!, options: [:], completionHandler: nil)
			return
		case .followMedium:
			var url: URL?
			let mediumScheme = URL(string: "medium://")!

			if UIApplication.shared.canOpenURL(mediumScheme) {
				url = URL(string: mediumPageDeepLink)
			} else {
				url = URL(string: mediumPageURL)
			}
			UIApplication.shared.open(url!, options: [:], completionHandler: nil)
			return
		default: break
		}

		guard let identifierString = sectionRow?.identifierString, !identifierString.isEmpty else { return }
		if shouldPerformSegue {
			performSegue(withIdentifier: identifierString, sender: nil)
		}
	}
}
