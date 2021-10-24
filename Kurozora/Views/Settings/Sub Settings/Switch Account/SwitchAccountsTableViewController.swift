//
//  SwitchAccountsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/**
	The table view controller responsible for adding, deleting and listing of user's accounts.
*/
class SwitchAccountsTableViewController: SubSettingsViewController {
	// MARK: - Properties
	/// All user accounts.
	var accounts: [String] {
		return KurozoraDelegate.shared.keychain.allKeys()
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		tableView.reloadData()
	}

	// MARK: - IBActions
	@IBAction func addAccountBarButtonItemPressed(_ sender: UIBarButtonItem) {
		if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
			let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
			UIApplication.topViewController?.present(kNavigationController, animated: true)
		}
	}
}

// MARK: - UITableViewDataSource
extension SwitchAccountsTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return accounts.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let selectableSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectableSettingsCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.selectableSettingsCell.identifier)")
		}
		let accountKey = accounts[indexPath.item]
		selectableSettingsCell.primaryLabel?.text = accountKey
		selectableSettingsCell.setSelected(accountKey == UserSettings.selectedAccount)
		return selectableSettingsCell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let accountKey = accounts[indexPath.item]
		return !(accountKey == UserSettings.selectedAccount)
	}
}

// MARK: - UITableViewDelegate
extension SwitchAccountsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let accountKey = accounts[indexPath.item]
		// Update user settings for selected account
		UserSettings.set(accountKey, forKey: .selectedAccount)

		// Retrieve selected user's session.
		if let authenticationKey = KurozoraDelegate.shared.keychain[accountKey] {
			// Start using the selected user's authentication key.
			KService.authenticationKey = authenticationKey

			// Restore the user's session.
			WorkflowController.shared.restoreCurrentUserSession()
		}
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let removeAction = UIContextualAction(style: .destructive, title: "Sign out", handler: {_, _, completion in
			let accountKey = self.accounts[indexPath.item]

			// Remove user's authentication key from keychain and update tableView.
			try? KurozoraDelegate.shared.keychain.remove(accountKey)
			tableView.deleteRows(at: [indexPath], with: .automatic)
			completion(true)
		})

		return UISwipeActionsConfiguration(actions: [removeAction])
	}
}

// MARK: - KTableViewDataSource
extension SwitchAccountsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [SelectableSettingsCell.self]
	}
}
