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
import SwiftTheme

class AccountTableViewController: SubSettingsViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: UIImageView! {
		didSet {
			profileImageView.theme_borderColor = KThemePicker.borderColor.rawValue
		}
	}
	@IBOutlet weak var usernameLabel: UILabel! {
		didSet {
			usernameLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var userEmailLabel: UILabel! {
		didSet {
			userEmailLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Setup username.
		usernameLabel.text = User.current?.username

		// Setup email address.
		userEmailLabel.text = User.current?.kurozoraID
		userEmailLabel.textAlignment = .center
		userEmailLabel.font = UIFont(name: "System", size: 13)

		// Setup profile image.
		profileImageView.image = User.current?.profileImage
	}
}

// MARK: - UITableViewDataSource
extension AccountTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath as IndexPath, animated: true)

		switch (indexPath.section, indexPath.row) {
//		case (0, 0): break
		case (1, 0):
			let username = User.current?.username ?? ""
			let alertView = SCLAlertView()
			alertView.addButton("Yes, sign me out 😞", action: {
				if User.isSignedIn {
					guard let sessionID = User.current?.session?.id else { return }
					KService.signOut(ofSessionID: sessionID) { result in
						switch result {
						case .success:
							try? Kurozora.shared.KDefaults.remove("Account_\(username)")
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
