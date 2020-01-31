//
//  AccountTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftTheme

class AccountTableViewController: SubSettingsViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: UIImageView! {
		didSet {
			self.profileImageView?.image = User.currentUserProfileImage
			self.profileImageView?.theme_borderColor = KThemePicker.borderColor.rawValue
		}
	}
	@IBOutlet weak var usernameLabel: UILabel! {
		didSet {
			usernameLabel.text = Kurozora.shared.KDefaults["username"]
			usernameLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var userEmailLabel: UILabel! {
		didSet {
			userEmailLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Setup user email
		userEmailLabel.text = "\(Kurozora.shared.KDefaults["username"] ?? "kurozora")@kurozora.app"
		userEmailLabel.textAlignment = .center
		userEmailLabel.font = UIFont(name: "System", size: 13)
	}
}

// MARK: - UITableViewDataSource
extension AccountTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath as IndexPath, animated: true)

		switch (indexPath.section, indexPath.row) {
//		case (0, 0): break
		case (1, 0):
			let alertView = SCLAlertView()
			alertView.addButton("Yes, sign me out 😞", action: {
				if User.isSignedIn {
					KService.shared.signOut(withSuccess: nil)
				}
				self.dismiss(animated: true, completion: nil)
			})

			alertView.showError("Sign out", subTitle: "Are you sure you want to sign out?", closeButtonTitle: "No, keep me signed in 😆")
		default: break
		}
	}
}
