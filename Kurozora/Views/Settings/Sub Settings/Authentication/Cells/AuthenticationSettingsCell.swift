//
//  AuthenticationSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AuthenticationSettingsCell: SettingsCell {
	@IBOutlet weak var authenticationTitleLabel: UILabel? {
		didSet {
			authenticationTitleLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue

			var title = "Lock with Passcode"
			switch UIDevice.supportedBiomtetric {
			case .faceID:
				title = "Lock with Face ID & Passcode"
			case .touchID:
				title = "Lock with Touch ID & Passcode"
			case .none: break
			}
			authenticationTitleLabel?.text = title
		}
	}
	@IBOutlet weak var authenticationImageView: UIImageView! {
		didSet {
			switch UIDevice.supportedBiomtetric {
			case .faceID:
				authenticationImageView.image = R.image.icons.faceID()
			case .touchID:
				authenticationImageView.image = R.image.icons.touchID()
			case .none:
				authenticationImageView.image = R.image.icons.lock()
			}
		}
	}

	@IBOutlet weak var enabledSwitch: UISwitch? {
		didSet {
			enabledSwitch?.theme_onTintColor = KThemePicker.tintColor.rawValue

			if let authenticationEnabledString = try? Kurozora.shared.keychain.get("authenticationEnabled"), let authenticationEnabled = Bool(authenticationEnabledString) {
				enabledSwitch?.isOn = authenticationEnabled
			} else {
				enabledSwitch?.isOn = false
			}
		}
	}

	@IBOutlet weak var authenticationRequireValueLabel: UILabel? {
		didSet {
			authenticationRequireValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			authenticationRequireValueLabel?.text = try? Kurozora.shared.keychain.get("requireAuthentication")
			NotificationCenter.default.addObserver(self, selector: #selector(updateAuthenticationRequireValueLabel), name: .KSAuthenticationRequireTimeoutValueDidChange, object: nil)
		}
	}

	// MARK: - Functions
	@objc func updateAuthenticationRequireValueLabel() {
		authenticationRequireValueLabel?.text = try? Kurozora.shared.keychain.get("requireAuthentication")
	}

	// MARK: IBActions
	@IBAction func enabledSwitchSwitched(_ sender: UISwitch) {
		try? Kurozora.shared.keychain.set("\(sender.isOn)", key: "authenticationEnabled")

		if let tableView = self.superview as? UITableView {
			tableView.reloadData()
		}
	}
}
