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

		configureUserDetails()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		configureUserDetails()
	}

	// MARK: - Functions
	/// Configures the view with the user's details.
	func configureUserDetails() {
		// Setup username.
		self.usernameLabel.text = User.current?.attributes.username

		// Setup email address.
		self.userEmailLabel.text = User.current?.attributes.email

		// Setup profile image.
		self.profileImageView.image = User.current?.attributes.profileImage
	}
}

// MARK: - UITableViewDataSource
extension AccountTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath as IndexPath, animated: true)

		switch (indexPath.section, indexPath.row) {
//		case (0, 0): break
//		case (1, 0): break
		case (2, 0):
			let username = User.current?.attributes.username ?? ""
			let alertController = self.presentAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", defaultActionButtonTitle: "No, keep me signed in 😆")
			alertController.addAction(UIAlertAction(title: "Yes, sign me out 🤨", style: .destructive) { [weak self] _ in
				if User.isSignedIn {
					KService.signOut { result in
						switch result {
						case .success:
							try? KurozoraDelegate.shared.keychain.remove(username)
						case .failure:
							break
						}
					}
				}
				self?.dismiss(animated: true, completion: nil)
			})
		default: break
		}
	}
}
