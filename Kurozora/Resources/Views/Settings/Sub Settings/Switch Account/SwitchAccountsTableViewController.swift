//
//  SwitchAccountsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol SwitchAccountsTableViewControllerDelegate: AnyObject {
	func switchAccountsTableViewController(
		_ controller: SwitchAccountsTableViewController,
		didSelect account: StoredAccount
	)
}

/// The table view controller responsible for adding, deleting and listing of user's accounts.
class SwitchAccountsTableViewController: SubSettingsViewController {
	// MARK: - Views
	private var addAccountBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	weak var delegate: SwitchAccountsTableViewControllerDelegate?

	/// The slug to highlight as selected. When nil, falls back to `UserSettings.selectedAccount`.
	var selectedSlug: String?

	/// All user accounts.
	var accounts: [StoredAccount] {
		return AccountManager.shared.allAccounts()
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
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

		self.title = Trans.switchAccount

		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true

		self.configureNavigationItems()
	}

	private func configureNavigationItems() {
		self.configureAddAccountBarButtonItem()
	}

	private func configureAddAccountBarButtonItem() {
		guard self.delegate == nil else { return }

		self.addAccountBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.addAccountBarButtonItemPressed()
		})
		self.navigationItem.rightBarButtonItem = self.addAccountBarButtonItem
	}

	private func addAccountBarButtonItemPressed() {
		let signInTableViewController = SignInTableViewController()
		let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
		self.present(kNavigationController, animated: true)
	}
}

// MARK: - UITableViewDataSource
extension SwitchAccountsTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.accounts.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let selectableAccountSettingsCell = tableView.dequeueReusableCell(withIdentifier: "\(SelectableAccountSettingsCell.self)", for: indexPath) as? SelectableAccountSettingsCell else {
			fatalError("Cannot dequeue reusable cell with identifier \(SelectableAccountSettingsCell.self)")
		}
		let account = self.accounts[indexPath.item]
		let effectiveSlug = self.selectedSlug ?? UserSettings.selectedAccount
		let isSelected = account.slug == effectiveSlug
		selectableAccountSettingsCell.configure(using: account, isSelected: isSelected)
		return selectableAccountSettingsCell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		guard self.delegate == nil else { return false }
		let account = self.accounts[indexPath.item]
		return account.slug != UserSettings.selectedAccount
	}
}

// MARK: - UITableViewDelegate
extension SwitchAccountsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let account = self.accounts[indexPath.item]

		if let delegate = self.delegate {
			delegate.switchAccountsTableViewController(self, didSelect: account)
			return
		}

		// Update user settings for selected account.
		UserSettings.set(account.slug, forKey: .selectedAccount)

		// Start using the selected user's authentication key.
		KService.authenticationKey = account.authenticationToken

		// Push auth state to Watch.
		WatchSessionManager.shared.sendAuthState(slug: account.slug, token: account.authenticationToken)

		// Restore the user's session.
		Task {
			if await WorkflowController.shared.restoreCurrentUserSession() {
				// Notify views the user has changed.
				NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
			}
		}
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let removeAction = UIContextualAction(style: .destructive, title: Trans.signOut, handler: { _, _, completion in
			let account = self.accounts[indexPath.item]

			// Remove user's account from keychain and update tableView.
			AccountManager.shared.remove(slug: account.slug)
			tableView.deleteRows(at: [indexPath], with: .automatic)
			completion(true)
		})

		return UISwipeActionsConfiguration(actions: [removeAction])
	}
}

// MARK: - KTableViewDataSource
extension SwitchAccountsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [SelectableAccountSettingsCell.self]
	}
}
