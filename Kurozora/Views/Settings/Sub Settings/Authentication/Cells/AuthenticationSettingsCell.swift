//
//  AuthenticationSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AuthenticationSettingsCell: SettingsCell {
	// MARK: - IBOutlets
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
			enabledSwitch?.isOn = UserSettings.authenticationEnabled
		}
	}

	@IBOutlet weak var authenticationRequireValueLabel: UILabel? {
		didSet {
			authenticationRequireValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			authenticationRequireValueLabel?.text = UserSettings.authenticationInterval.stringValue
			NotificationCenter.default.addObserver(self, selector: #selector(updateAuthenticationRequireValueLabel), name: .KSAuthenticationRequireTimeoutValueDidChange, object: nil)
		}
	}

	// MARK: - Functions
	@objc func updateAuthenticationRequireValueLabel() {
		authenticationRequireValueLabel?.text = UserSettings.authenticationInterval.stringValue
	}

	// MARK: - IBActions
	@IBAction func enabledSwitchSwitched(_ sender: UISwitch) {
		UserSettings.set(sender.isOn, forKey: .authenticationEnabled)

		if let tableView = self.superview as? UITableView {
			tableView.reloadData()
		}
	}
}
