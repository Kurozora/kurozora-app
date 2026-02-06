//
//  SettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Kingfisher
import KurozoraKit
import UIKit

class SettingsTableViewController: KTableViewController {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case accountSegue
		case switchAccountSegue
		case keysSegue
		case browserSegue
		case displaySegue
		case iconSegue
		case librarySegue
		case motionSegue
		case themeSegue
		case notificationSegue
		case soundSegue
		case biometricsSegue
		case privacySegue
		case subscriptionSegue
		case tipJarSegue
	}

	// MARK: - Views
	private var closeBarButtonItem: UIBarButtonItem!

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

		Task { @MainActor [weak self] in
			guard let self = self else { return }
			self.configureTableView()
		}
	}

	override func viewWillReload() {
		super.viewWillReload()

		Task { @MainActor [weak self] in
			guard let self = self else { return }
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = Trans.settings

		// Stop activity indicator and disable refresh control
		self._prefersActivityIndicatorHidden = true
		self._prefersRefreshControlDisabled = true

		self.configureView()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if self.selectedIndexPath == nil {
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *), !UIDevice.isPhone {
				guard let sectionIndex = self.settingsSection.firstIndex(of: .general) else { return }
				guard let rowIndex = self.settingsSection[safe: sectionIndex]?.rowsValue.firstIndex(of: .displayBlindness) else { return }

				let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
				self.tableView(self.tableView, didSelectRowAt: indexPath)
			}
		}
	}

	private func configureView() {
		self.configureNavigationItems()
		self.configureTableView()
	}

	private func configureTableView() {
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *), !UIDevice.isPhone {
			self.clearsSelectionOnViewWillAppear = false
			self.view.theme_backgroundColor = nil
			self.view.backgroundColor = .clear
			self.tableView.theme_backgroundColor = nil
			self.tableView.backgroundColor = .clear
			self.tableView.theme_separatorColor = nil
			self.tableView.separatorColor = .clear
		}
	}

	/// Configures the close bar button item.
	private func configureCloseBarButtonItem() {
		self.closeBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.dismiss(animated: true, completion: nil)
		})
		self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
	}

	/// Configures the navigation items.
	private func configureNavigationItems() {
		self.configureCloseBarButtonItem()
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .accountSegue: return AccountTableViewController()
		case .switchAccountSegue: return SwitchAccountsTableViewController()
		case .keysSegue: return DebugSettingsTableViewController()
		case .browserSegue: return BrowserSettingsTableViewController()
		case .displaySegue: return DisplayTableViewController()
		case .iconSegue: return ManageIconTableViewController()
		case .librarySegue: return LibrarySettingsViewController()
		case .motionSegue: return MotionOptionsViewController()
		case .themeSegue: return ManageThemesCollectionViewController()
		case .notificationSegue: return NotificationsOptionsViewController()
		case .soundSegue: return SoundSettingsViewController()
		case .biometricsSegue: return AuthenticationTableViewController()
		case .privacySegue: return PrivacySettingsViewController()
		case .subscriptionSegue: return SubscriptionCollectionViewController()
		case .tipJarSegue: return TipJarCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .accountSegue, .switchAccountSegue, .keysSegue,
		     .browserSegue, .displaySegue, .iconSegue,
		     .librarySegue, .motionSegue, .themeSegue,
		     .notificationSegue, .soundSegue,
		     .biometricsSegue, .privacySegue:
			return
		case .subscriptionSegue:
			let kNavigationController = destination as? KNavigationController
			(kNavigationController?.viewControllers.first as? SubscriptionCollectionViewController)?.leftNavigationBarButtonIsHidden = true
		case .tipJarSegue:
			let kNavigationController = destination as? KNavigationController
			(kNavigationController?.viewControllers.first as? TipJarCollectionViewController)?.leftNavigationBarButtonIsHidden = true
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
		var identifier = SettingsCell.self
		let settingsRow = self.settingsSection[indexPath.section].rowsValue[safe: indexPath.row]

		switch settingsRow {
		case .account:
			identifier = AccountSettingsCell.self
		default: break
		}

		guard let settingsCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(identifier.reuseID)")
		}
		settingsCell.configureCell(using: settingsRow)

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *), !UIDevice.isPhone {
			settingsCell.contentView.theme_backgroundColor = nil
			settingsCell.contentView.backgroundColor = .clear
			settingsCell.selectedView?.theme_backgroundColor = nil
			settingsCell.selectedView?.backgroundColor = .clear
			settingsCell.chevronImageView?.isHidden = true
			settingsCell.selectedView?.layerCornerRadius = (settingsCell.selectedView?.frame.height ?? 44) / 2
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
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *), !UIDevice.isPhone {
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
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *), !UIDevice.isPhone {
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
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *), !UIDevice.isPhone {
			guard let settingsCell = tableView.cellForRow(at: indexPath) as? SettingsCell else { return }
			settingsCell.selectedView?.theme_backgroundColor = nil
			settingsCell.selectedView?.backgroundColor = .clear
			settingsCell.primaryLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			settingsCell.secondaryLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let sectionRow = self.settingsSection[indexPath.section].rowsValue[indexPath.row]

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *), !UIDevice.isPhone {
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
			guard let segueID = sectionRow.segueIdentifier else { return }
			self.authAndSegue(to: segueID)
			return
		case .switchAccount:
			self.showDetailViewController(SegueIdentifiers.switchAccountSegue, sender: nil)
			return
		case .keychain:
			self.showDetailViewController(SegueIdentifiers.keysSegue, sender: nil)
			return
		case .browser:
			self.showDetailViewController(SegueIdentifiers.browserSegue, sender: nil)
			return
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
		case .icon:
			self.showDetailViewController(SegueIdentifiers.iconSegue, sender: nil)
			return
		case .library: break
		case .motion: break
		case .theme:
			self.showDetailViewController(SegueIdentifiers.themeSegue, sender: nil)
			return
		case .notifications:
			guard let segueID = sectionRow.segueIdentifier else { return }
			self.authAndSegue(to: segueID)
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
		case .unlockFeatures:
			self.showDetailViewController(SegueIdentifiers.subscriptionSegue, sender: nil)
			return
		case .tipjar:
			self.showDetailViewController(SegueIdentifiers.tipJarSegue, sender: nil)
			return
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

		if let identifierString = sectionRow.segueIdentifier {
			self.performSegue(withIdentifier: identifierString, sender: nil)
		}
	}

	/// Authenticate user and perform segue.
	///
	/// - Parameter identifier: The segue identifier.
	private func authAndSegue(to identifier: SegueIdentifiers) {
		Task {
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			self.performSegue(withIdentifier: identifier, sender: nil)
		}
	}
}

// MARK: - KTableViewDataSource
extension SettingsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			AccountSettingsCell.self,
			SettingsCell.self
		]
	}
}
