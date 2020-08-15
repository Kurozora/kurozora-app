//
//  AccountTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SCLAlertView

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

	// MARK: - Segue
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if identifier == R.segue.accountTableViewController.siwASegue.identifier {
			if #available(iOS 13.0, macCatalyst 13.0, *) {
				return true
			} else {
				SCLAlertView().showInfo("Not supported 😵", subTitle: "Sign in with Apple is only supported on iOS 13.0 and up. If you would like to use this feature, please update your iOS version if possible.")
				return false
			}
		}

		return true
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
			let alertView = SCLAlertView()
			alertView.addButton("Yes, sign me out 🤨", action: {
				if User.isSignedIn {
					guard let sessionID = User.current?.relationships?.sessions?.data.first?.id else { return }
					KService.signOut(ofSessionID: sessionID) { result in
						switch result {
						case .success:
							try? Kurozora.shared.keychain.remove(username)
						case .failure:
							break
						}
					}
				}
				self.dismiss(animated: true, completion: nil)
			})

			alertView.showError("Sign out", subTitle: "Are you sure you want to sign out?", closeButtonTitle: "No, keep me signed in 😆")
		default: break
		}
	}
}
