//
//  SwitchAccountsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/// The table view controller responsible for adding, deleting and listing of user's accounts.
class SwitchAccountsTableViewController: SubSettingsViewController, StoryboardInstantiable {
	static var storyboardName: String = "SwitchAccountSettings"

	// MARK: - Properties
	/// All user accounts.
	var accounts: [String] {
		return SharedDelegate.shared.keychain.allKeys()
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.tableView.reloadData()
		}
	}

	// MARK: - IBActions
	@IBAction func addAccountBarButtonItemPressed(_ sender: UIBarButtonItem) {
		let signInTableViewController = SignInTableViewController.instantiate()
		let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
		UIApplication.topViewController?.present(kNavigationController, animated: true)
	}
}

// MARK: - UITableViewDataSource
extension SwitchAccountsTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.accounts.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let selectableSettingsCell = tableView.dequeueReusableCell(withIdentifier: "\(SelectableSettingsCell.self)", for: indexPath) as? SelectableSettingsCell else {
			fatalError("Cannot dequeue reusable cell with identifier \(SelectableSettingsCell.self)")
		}
		let accountKey = self.accounts[indexPath.item]
		selectableSettingsCell.primaryLabel?.text = accountKey
		selectableSettingsCell.setSelected(accountKey == UserSettings.selectedAccount)
		return selectableSettingsCell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		let accountKey = self.accounts[indexPath.item]
		return !(accountKey == UserSettings.selectedAccount)
	}
}

// MARK: - UITableViewDelegate
extension SwitchAccountsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let accountKey = self.accounts[indexPath.item]
		// Update user settings for selected account.
		UserSettings.set(accountKey, forKey: .selectedAccount)

		// Retrieve selected user's session.
		if let authenticationKey = SharedDelegate.shared.keychain[accountKey] {
			// Start using the selected user's authentication key.
			KService.authenticationKey = authenticationKey

			// Restore the user's session.
			Task {
				if await WorkflowController.shared.restoreCurrentUserSession() {
					// Notify views the user has changed.
					NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
				}
			}
		}
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let removeAction = UIContextualAction(style: .destructive, title: "Sign out", handler: {_, _, completion in
			let accountKey = self.accounts[indexPath.item]

			// Remove user's authentication key from keychain and update tableView.
			try? SharedDelegate.shared.keychain.remove(accountKey)
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
