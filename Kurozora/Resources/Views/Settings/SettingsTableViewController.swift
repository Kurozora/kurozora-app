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

class SettingsTableViewController: KTableViewController {
	// MARK: - Properties
	var settingsSection: [Section] {
		return Section.all
	}

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator and disable refresh control
		self._prefersActivityIndicatorHidden = true
		self._prefersRefreshControlDisabled = true
	}

	// MARK: - IBActions
	@IBAction func dismissPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.settingsTableViewController.subscriptionSegue.identifier:
			let kNavigationController = segue.destination as? KNavigationController
			(kNavigationController?.viewControllers.first as? SubscriptionCollectionViewController)?.leftNavigationBarButtonIsHidden = true
		case R.segue.settingsTableViewController.tipJarSegue.identifier:
			let kNavigationController = segue.destination as? KNavigationController
			(kNavigationController?.viewControllers.first as? TipJarCollectionViewController)?.leftNavigationBarButtonIsHidden = true
		default: break
		}
	}
}

// MARK: - UITableViewDataSource
extension SettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return settingsSection.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.settingsSection[section].rowsValue.count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let section = self.settingsSection[section]
		return section == .about ? nil : section.stringValue
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var identifier = R.reuseIdentifier.settingsCell
		let settingsRow = self.settingsSection[indexPath.section].rowsValue[indexPath.row]

		switch settingsRow {
		case .account:
			identifier = R.reuseIdentifier.accountCell
		default: break
		}

		guard let settingsCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(identifier.identifier)")
		}
		settingsCell.configureCell(using: settingsRow)
		return settingsCell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch self.settingsSection[section] {
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
			headerView.textLabel?.font = .systemFont(ofSize: 15)
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
			shouldPerformSegue = WorkflowController.shared.isSignedIn(on: self)
		case .switchAccount: break
		case .keychain: break
		case .notifications:
			shouldPerformSegue = WorkflowController.shared.isSignedIn(on: self)
		case .soundsAndHaptics: break
		case .reminder:
			WorkflowController.shared.subscribeToReminders(on: self)
			return
		case .displayBlindness: break
		case .theme: break
		case .icon: break
		case .browser: break
		case .biometrics: break
		case .cache:
			let alertController = self.presentAlertController(title: "Clear all Cache?", message: "All of your caches will be cleared.", defaultActionButtonTitle: Trans.cancel)
			alertController.addAction(UIAlertAction(title: "Clear 🗑", style: .destructive) { _ in
				// Clear memory cache right away.
				KingfisherManager.shared.cache.clearMemoryCache()

				// Clear disk cache. This is an async operation.
				KingfisherManager.shared.cache.clearDiskCache()

				// Clean expired or size exceeded disk cache. This is an async operation.
				KingfisherManager.shared.cache.cleanExpiredDiskCache()

				// Refresh cacheSizeLabel
				tableView.reloadData()
			})
			return
		case .privacy: break
		case .rate:
			if let rateURL = URL.rateURL {
				UIApplication.shared.open(rateURL)
			}
			return
		case .tipjar: break
		case .manageSubscriptions:
			Task { [weak self] in
				guard let self = self else { return }
				await store.manageSubscriptions(in: self.view.window?.windowScene)
			}
			return
		case .restoreFeatures:
			Task {
				await store.restore()
			}
			return
		case .unlockFeatures: break
		case .joinDiscord:
			UIApplication.shared.kOpen(.discordPageURL)
			return
		case .followGitHub:
			UIApplication.shared.kOpen(.gitHubPageURL)
			return
		case .followMastodon:
			UIApplication.shared.kOpen(.mastodonPageURL)
			return
		case .followTwitter:
			UIApplication.shared.kOpen(.twitterPageURL, deepLink: .twitterPageDeepLink)
			return
		}

		let identifierString = sectionRows.segueIdentifier
		if shouldPerformSegue && !identifierString.isEmpty {
			performSegue(withIdentifier: identifierString, sender: nil)
		}
	}
}
