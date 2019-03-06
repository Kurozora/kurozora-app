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

class AccountTableViewController: UITableViewController {
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		// Setup user avatar
		userAvatar.image = User.currentUserAvatar()

		// Setup username
        usernameLabel.text = GlobalVariables().KDefaults["username"]
		usernameLabel.theme_textColor = "Global.textColor"

		// Setup user email
        userEmailLabel.text = "some@email.com"
        userEmailLabel.theme_textColor = "Global.textcolor"
        userEmailLabel.textAlignment = .center
        userEmailLabel.font = UIFont(name: "System", size: 13)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"
    }

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		for cell in tableView.visibleCells {
			guard let indexPath = tableView.indexPath(for: cell) else { return }
			var rectCorner: UIRectCorner!
			var roundCorners = true
			let numberOfRows: Int = tableView.numberOfRows(inSection: indexPath.section)

			if numberOfRows == 1 {
				// single cell
				rectCorner = UIRectCorner.allCorners
			} else if indexPath.row == numberOfRows - 1 {
				// bottom cell
				rectCorner = [.bottomLeft, .bottomRight]
			} else if indexPath.row == 0 {
				// top cell
				rectCorner = [.topLeft, .topRight]
			} else {
				roundCorners = false
			}

			if roundCorners {
				tableView.cellForRow(at: indexPath)?.contentView.roundedCorners(rectCorner, radius: 10)
			}
		}
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

			alertView.showNotice("Sign out", subTitle: "Are you sure you want to sign out?", closeButtonTitle: "No, keep me signed in 😆")
		default: break
		}
	}
}
