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
	var settingsSection = User.isAdmin ? Section.all : Section.allUser
	var sectionRow = User.isAdmin ? Section.allRow : Section.allUserRow

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .KUserIsSignedInDidChange, object: nil)

		// Setup table view
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension
	}

    // MARK: - Functions
	/// Reload the table view data.
	@objc private func reloadData() {
		tableView.reloadData()
	}

    // MARK: - IBActions
    @IBAction func dismissPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SubscriptionSegue" {
			let kNavigationController = segue.destination as? KNavigationController
			(kNavigationController?.viewControllers.first as? PurchaseTableViewController)?.leftNavigationBarButtonIsHidden = true
		}
	}
}

// MARK: - UITableViewDataSource
extension SettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return settingsSection.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let numberOfRowsInSection = sectionRow[settingsSection[section]]
		return numberOfRowsInSection?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = settingsSection[section]
		return section == .about ? nil : section.stringValue
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var identifier = "SettingsCell"
		switch indexPath {
		case [0, 0]:
			identifier = "AccountCell"
		default: break
		}

		let settingsCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SettingsCell
		let sectionRows = sectionRow[settingsSection[indexPath.section]]
		settingsCell.sectionRow = sectionRows?[indexPath.row]
		return settingsCell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch settingsSection[section] {
		case .about:
			return """
			Built with lack of 😴, lots of 🍵 and 🌸 allergy by Kirito
			Kurozora \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "1.0.0") (\(Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) ?? "0"))
			"""
		default:
			return nil
		}
	}
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
		let sectionRows = sectionRow[settingsSection[indexPath.section]]?[indexPath.row]
		var shouldPerformSegue = true

		switch sectionRows {
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
		case .rate:
			UIApplication.shared.kOpen(.rateURL, nil, options: [:], completionHandler: nil)
			return
		case .restoreFeatures:
			KStoreObserver.shared.restorePurchase()
			return
		case .tipjar:
			shouldPerformSegue = true
		case .followTwitter:
			UIApplication.shared.kOpen(.twitterPageURL, .twitterPageDeepLink, options: [:], completionHandler: nil)
			return
		case .followMedium:
			UIApplication.shared.kOpen(.mediumPageURL, .mediumPageDeepLink, options: [:], completionHandler: nil)
			return
		default: break
		}

		guard let identifierString = sectionRows?.segueIdentifier, !identifierString.isEmpty else { return }
		if shouldPerformSegue {
			performSegue(withIdentifier: identifierString, sender: nil)
		}
	}
}
