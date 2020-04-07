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
	@IBOutlet weak var profileImageView: UIImageView!
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
		usernameLabel.text = Kurozora.shared.KDefaults["username"]

		// Setup email address.
		userEmailLabel.text = Kurozora.shared.KDefaults["kurozora_id"]
		userEmailLabel.textAlignment = .center
		userEmailLabel.font = UIFont(name: "System", size: 13)

		// Setup profile image.
		if let profileImage = Kurozora.shared.KDefaults["profile_image"] {
			if let usernameInitials = Kurozora.shared.KDefaults["username"]?.initials {
				let placeholderImage = usernameInitials.toImage(placeholder: R.image.placeholders.profile_image()!)
				profileImageView.setImage(with: profileImage, placeholder: placeholderImage)
			}
		}
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
					guard let sessionID = User().current?.sessionID else { return }
					KService.signOut(ofSessionID: sessionID)
				}
				self.dismiss(animated: true, completion: nil)
			})

			alertView.showError("Sign out", subTitle: "Are you sure you want to sign out?", closeButtonTitle: "No, keep me signed in 😆")
		default: break
		}
	}
}
