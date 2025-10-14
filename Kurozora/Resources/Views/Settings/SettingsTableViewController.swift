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

	private var selectedIndexPath: IndexPath?

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
    override func themeWillReload() {
        super.themeWillReload()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setupView()
        }
    }

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
        
        self.setupView()
		
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if self.selectedIndexPath == nil {
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				guard let sectionIndex = self.settingsSection.firstIndex(of: .general) else { return }
				guard let rowIndex = self.settingsSection[safe: sectionIndex]?.rowsValue.firstIndex(of: .displayBlindness) else { return }

				let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
				self.tableView(self.tableView, didSelectRowAt: indexPath)
			}
		}
	}

    fileprivate func setupView() {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.clearsSelectionOnViewWillAppear = false
            self.view.theme_backgroundColor = nil
			self.view.backgroundColor = .clear
            self.tableView.theme_backgroundColor = nil
			self.tableView.backgroundColor = .clear
        }
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
		return self.settingsSection.count
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

        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
            settingsCell.contentView.theme_backgroundColor = nil
			settingsCell.contentView.backgroundColor = .clear
			settingsCell.selectedView?.theme_backgroundColor = nil
            settingsCell.selectedView?.backgroundColor = .clear
            settingsCell.chevronImageView?.isHidden = true
			settingsCell.selectedView?.layerCornerRadius = 12.0
        }

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
            if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				settingsCell.selectedView?.theme_backgroundColor = KThemePicker.tintColor.rawValue
				settingsCell.primaryLabel?.theme_textColor = KThemePicker.tintedButtonTextColor.rawValue
				settingsCell.secondaryLabel?.theme_textColor = KThemePicker.tintedButtonTextColor.rawValue
            } else {
                settingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
                settingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellSelectedChevronColor.rawValue

                settingsCell.primaryLabel?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
                settingsCell.secondaryLabel?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
            }
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell {
            if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				settingsCell.selectedView?.theme_backgroundColor = nil
				settingsCell.selectedView?.backgroundColor = .clear
            } else {
                settingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
                settingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue
            }

			settingsCell.primaryLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			settingsCell.secondaryLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			guard let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell else { return }
			settingsCell.selectedView?.theme_backgroundColor = nil
			settingsCell.selectedView?.backgroundColor = .clear
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let sectionRow = self.settingsSection[indexPath.section].rowsValue[indexPath.row]

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			if let previousIndexPath = self.selectedIndexPath, previousIndexPath != indexPath {
				self.tableView(tableView, didDeselectRowAt: previousIndexPath)
			}

			self.selectedIndexPath = indexPath

			if let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell {
				settingsCell.selectedView?.theme_backgroundColor = KThemePicker.tintColor.rawValue
				settingsCell.primaryLabel?.theme_textColor = KThemePicker.tintedButtonTextColor.rawValue
				settingsCell.secondaryLabel?.theme_textColor = KThemePicker.tintedButtonTextColor.rawValue
			}
		}

		switch sectionRow {
		case .account:
			self.authAndSegue(to: sectionRow.segueIdentifier)
			return
		case .switchAccount: break
		case .keychain: break
		case .browser: break
		case .cache:
			let alertController = self.presentAlertController(title: "Clear all Cache?", message: "The number you see in Kurozora might not match the one in the Settings app. That’s because caches on your disk and in RAM are counted together here. Wiping both clean might make the app a bit slower at first, but things will speed up once the caches are built up again.", defaultActionButtonTitle: Trans.cancel)
			alertController.addAction(UIAlertAction(title: "Clear 🗑", style: .destructive) { _ in
				// Clear RichLink cache right away.
				RichLink.shared.clearCache()

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
		case .displayBlindness: break
		case .icon: break
		case .library: break
		case .motion: break
		case .theme: break
		case .notifications:
			self.authAndSegue(to: sectionRow.segueIdentifier)
			return
		case .reminder:
			Task { [weak self] in
				await WorkflowController.shared.subscribeToReminders(on: self)
			}
			return
		case .soundsAndHaptics:
			break
		case .signalSticker:
			if let signalStickerURL = URL.signalStickerURL {
				UIApplication.shared.open(signalStickerURL)
			}
			return
		case .telegramSticker:
			if let telegramStickerURL = URL.telegramStickerURL {
				UIApplication.shared.open(telegramStickerURL)
			}
			return
		case .biometrics: break
		case .privacy: break
		case .unlockFeatures: break
		case .tipjar: break
		case .manageSubscriptions:
			Task { [weak self] in
				await Store.shared.manageSubscriptions(in: self?.view.window?.windowScene)
			}
			return
		case .restoreFeatures:
			Task {
				let signedIn = await WorkflowController.shared.isSignedIn(on: self)
				guard signedIn else { return }

				await Store.shared.restore()
			}
			return
		case .rate:
			if let rateURL = URL.rateURL {
				UIApplication.shared.open(rateURL)
			}
			return
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

		let identifierString = sectionRow.segueIdentifier
		if !identifierString.isEmpty {
			self.performSegue(withIdentifier: identifierString, sender: nil)
		}
	}

	/// Authenticate user and perform segue.
	///
	/// - Parameter identifier: The segue identifier.
	private func authAndSegue(to identifier: String) {
		Task {
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			self.performSegue(withIdentifier: identifier, sender: nil)
		}
	}
}
