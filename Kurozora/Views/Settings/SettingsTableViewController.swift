//
//  SettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Kingfisher
import SCLAlertView

class SettingsTableViewController: KTableViewController {
	// MARK: - Properties
	var settingsSection: [Section] {
		return Section.all
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		tableView.reloadData()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator as it's not needed for now.
		_prefersActivityIndicatorHidden = true
	}

    // MARK: - IBActions
    @IBAction func dismissPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.settingsTableViewController.subscriptionSegue.identifier {
			let kNavigationController = segue.destination as? KNavigationController
			(kNavigationController?.viewControllers.first as? SubscriptionTableViewController)?.leftNavigationBarButtonIsHidden = true
		}
	}
}

// MARK: - UITableViewDataSource
extension SettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return settingsSection.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settingsSection[section].rowsValue.count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = settingsSection[section]
		return section == .about ? nil : section.stringValue
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var identifier = R.reuseIdentifier.settingsCell
		switch indexPath {
		case [0, 0]:
			identifier = R.reuseIdentifier.accountCell
		default: break
		}

		guard let settingsCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(identifier.identifier)")
		}
		settingsCell.sectionRow = settingsSection[indexPath.section].rowsValue[indexPath.row]
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
		let sectionRows = settingsSection[indexPath.section].rowsValue[indexPath.row]
		var shouldPerformSegue = true

		switch sectionRows {
		case .account:
			WorkflowController.shared.isSignedIn()
			shouldPerformSegue = User.isSignedIn
		case .reminder:
			WorkflowController.shared.isPro {
				UIApplication.shared.kOpen(KService.reminderSubscriptionURL)
			}
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
			if let rateURL = URL.rateURL {
				UIApplication.shared.open(rateURL)
			}
			return
		case .restoreFeatures:
			KStoreObserver.shared.restorePurchase()
			return
		case .tipjar:
			shouldPerformSegue = true
		case .followTwitter:
			UIApplication.shared.kOpen(.twitterPageURL, .twitterPageDeepLink)
			return
		case .followMedium:
			UIApplication.shared.kOpen(.mediumPageURL, .mediumPageDeepLink)
			return
		default: break
		}

		let identifierString = sectionRows.segueIdentifier
		if shouldPerformSegue && !identifierString.isEmpty {
			performSegue(withIdentifier: identifierString, sender: nil)
		}
	}
}
