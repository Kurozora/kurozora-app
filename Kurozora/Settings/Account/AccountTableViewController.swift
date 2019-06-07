//
//  AccountTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import Kingfisher
import SCLAlertView
import SwiftTheme

class AccountTableViewController: UITableViewController {
	@IBOutlet weak var userAvatar: UIImageView! {
		didSet {
			self.userAvatar?.image = User.currentUserAvatar()
			self.userAvatar?.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var usernameLabel: UILabel! {
		didSet {
			usernameLabel.text = GlobalVariables().KDefaults["username"]
			usernameLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var userEmailLabel: UILabel! {
		didSet {
			userEmailLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		// Setup user email
		userEmailLabel.text = "\(GlobalVariables().KDefaults["username"] ?? "kurozora")@kurozora.app"
        userEmailLabel.textAlignment = .center
        userEmailLabel.font = UIFont(name: "System", size: 13)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
    }
}

// MARK: - UITableViewDataSource
extension AccountTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath as IndexPath, animated: true)

		switch (indexPath.section, indexPath.row) {
//		case (0,0): break
		case (1,0):
			let alertView = SCLAlertView()
			alertView.addButton("Yes, sign me out 😞", action: {
				if let isLoggedIn = User.isLoggedIn() {
					if isLoggedIn {
						Service.shared.logout(withSuccess: { (success) in
							let storyboard:UIStoryboard = UIStoryboard(name: "login", bundle: nil)
							let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController

							self.present(vc, animated: true, completion: nil)
						})
					} else {
						let storyboard:UIStoryboard = UIStoryboard(name: "login", bundle: nil)
						let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController

						self.present(vc, animated: true, completion: nil)
					}
				}
			})

			alertView.showError("Sign out", subTitle: "Are you sure you want to sign out?", closeButtonTitle: "No, keep me signed in 😆")
		default: break
		}
	}
}

// MARK: - UITableViewDelegate
extension AccountTableViewController {
	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let settingsCell = tableView.cellForRow(at: indexPath) as! SettingsCell
		settingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		settingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellSelectedChevronColor.rawValue

		settingsCell.cellTitle?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let settingsCell = tableView.cellForRow(at: indexPath) as! SettingsCell
		settingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		settingsCell.chevronImageView?.theme_tintColor = KThemePicker.tableViewCellChevronColor.rawValue

		settingsCell.cellTitle?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
	}
}
