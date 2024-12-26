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
			self.authenticationTitleLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue

			self.authenticationTitleLabel?.text = UIDevice.supportedBiometric.localizedSettingsName
		}
	}
	@IBOutlet weak var authenticationImageView: UIImageView! {
		didSet {
			self.authenticationImageView.image = UIDevice.supportedBiometric.imageValue
		}
	}

	@IBOutlet weak var enabledSwitch: KSwitch? {
		didSet {
			self.enabledSwitch?.isOn = UserSettings.authenticationEnabled
		}
	}

	@IBOutlet weak var authenticationRequireValueLabel: UILabel? {
		didSet {
			self.authenticationRequireValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			self.authenticationRequireValueLabel?.text = UserSettings.authenticationInterval.stringValue
			NotificationCenter.default.addObserver(self, selector: #selector(updateAuthenticationRequireValueLabel), name: .KSAuthenticationRequireTimeoutValueDidChange, object: nil)
		}
	}

	// MARK: - Functions
	@objc func updateAuthenticationRequireValueLabel() {
		self.authenticationRequireValueLabel?.text = UserSettings.authenticationInterval.stringValue
	}

	// MARK: - IBActions
	@IBAction func enabledSwitchSwitched(_ sender: KSwitch) {
		UserSettings.set(sender.isOn, forKey: .authenticationEnabled)

		self.parentTableView?.reloadData()
	}
}
