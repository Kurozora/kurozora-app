//
//  AuthenticationSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit

class AuthenticationSettingsCell: SettingsCell {
	@IBOutlet weak var authenticationTitleLabel: UILabel? {
		didSet {
			var title = "Passcode"
			authenticationTitleLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue

			switch UIDevice.supportedBiomtetric {
			case .faceID:
				title = "Face ID & Passcode"
			case .touchID:
				title = "Touch ID & Passcode"
			case .none: break
			}
			authenticationTitleLabel?.text = title
		}
	}
	@IBOutlet weak var authenticationImageView: UIImageView! {
		didSet {
			switch UIDevice.supportedBiomtetric {
			case .faceID:
				authenticationImageView.image = #imageLiteral(resourceName: "face_id_icon")
			case .touchID:
				authenticationImageView.image = #imageLiteral(resourceName: "touch_id_icon")
			case .none:
				authenticationImageView.image = #imageLiteral(resourceName: "lock_icon")
			}
		}
	}

	@IBOutlet weak var authenticationDescriptionLabel: UILabel? {
		didSet {
			var title = "Lock with Passcode"
			authenticationDescriptionLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue

			switch UIDevice.supportedBiomtetric {
			case .faceID:
				title = "Lock with Face ID & Passcode"
			case .touchID:
				title = "Lock with Touch ID & Passcode"
			case .none: break
			}
			authenticationDescriptionLabel?.text = title
		}
	}
	@IBOutlet weak var enabledSwitch: UISwitch? {
		didSet {
			enabledSwitch?.theme_onTintColor = KThemePicker.tintColor.rawValue

			if let authenticationEnabledString = try? GlobalVariables().KDefaults.get("authenticationEnabled"), let authenticationEnabled = Bool(authenticationEnabledString) {
				enabledSwitch?.isOn = authenticationEnabled
			} else {
				enabledSwitch?.isOn = false
			}
		}
	}

	@IBOutlet weak var authenticationRequireValueLabel: UILabel? {
		didSet {
			authenticationRequireValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			authenticationRequireValueLabel?.text = try? GlobalVariables().KDefaults.get("requireAuthentication")
			NotificationCenter.default.addObserver(self, selector: #selector(updateAuthenticationRequireValueLabel), name: .KSAuthenticationRequireTimeoutValueDidChange, object: nil)
		}
	}

	// MARK: - Functions
	@objc func updateAuthenticationRequireValueLabel() {
		authenticationRequireValueLabel?.text = try? GlobalVariables().KDefaults.get("requireAuthentication")
	}

	// MARK: IBActions
	@IBAction func enabledSwitchSwitched(_ sender: UISwitch) {
		try? GlobalVariables().KDefaults.set("\(sender.isOn)", key: "authenticationEnabled")

		if let tableView = self.superview as? UITableView {
			tableView.reloadData()
		}
	}
}
