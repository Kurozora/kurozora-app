//
//  AccountTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class AccountTableViewController: SubSettingsViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var userEmailLabel: KSecondaryLabel!

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.configureUserDetails()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureUserDetails()
	}

	// MARK: - Functions
	/// Configures the view with the user's details.
	func configureUserDetails() {
		guard let user = User.current else { return }

		// Setup username.
		self.usernameLabel.text = user.attributes.username

		// Setup email address.
		self.userEmailLabel.text = user.attributes.email

		// Setup profile image.
		user.attributes.profileImage(imageView: self.profileImageView)
	}
}

// MARK: - UITableViewDataSource
extension AccountTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			guard let user = User.current else { return 0 }

			if user.attributes.siwaIsEnabled ?? false {
				return 1
			}
		}

		return super.tableView(tableView, numberOfRowsInSection: section)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath as IndexPath, animated: true)

		switch (indexPath.section, indexPath.row) {
//		case (0, 0): break
//		case (1, 0): break
		case (2, 0):
			let alertController = self.presentAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", defaultActionButtonTitle: "No, keep me signed in 😆")
			alertController.addAction(UIAlertAction(title: "Yes, sign me out 🤨", style: .destructive) { [weak self] _ in
				guard let self = self else { return }

				WorkflowController.shared.signOut()
				self.dismiss(animated: true, completion: nil)
			})
		case (2, 1):
			let alertController = self.presentAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? Once your account is deleted, all of its resources and data will be permanently deleted. Please enter your password to confirm you would like to permanently delete your account. ", defaultActionButtonTitle: Trans.cancel)
			alertController.addTextField { textField in
				textField.textType = .password
				textField.placeholder = Trans.password
			}
			alertController.addAction(UIAlertAction(title: "Delete Permanently", style: .destructive) { [weak self] _ in
				guard let self = self else { return }
				guard let passwordTextField = alertController.textFields?.first else { return }
				guard let password = passwordTextField.text else { return }

				Task {
					if await WorkflowController.shared.deleteUser(password: password) {
						self.dismiss(animated: true, completion: nil)
					}
				}
			})
		default: break
		}
	}
}
