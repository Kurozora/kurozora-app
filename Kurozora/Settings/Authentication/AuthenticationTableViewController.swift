//
//  AuthenticationTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit

class AuthenticationTableViewController: UITableViewController {
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		switch UIDevice.supportedBiomtetric {
		case .faceID:
			title = "Face ID & Passcode"
		case .touchID:
			title = "Touch ID & Passcode"
		case .none:
			title = "Passcode"
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}
}

// MARK: - UITableViewDataSource
extension AuthenticationTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let authenticationEnabledString = try? GlobalVariables().KDefaults.get("authenticationEnabled"),
			  let authenticationEnabled = Bool(authenticationEnabledString) else { return 1 }

		return authenticationEnabled ? 2 : 1
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == 0 {
			switch UIDevice.supportedBiomtetric {
			case .faceID:
				return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Face ID or your device's passcode when you reopen the app."
			case .touchID:
				return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Touch ID or your device's passcode when you reopen the app."
			case .none:
				return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through your device's passcode when you reopen the app."
			}
		}

		return ""
	}
}

// MARK: - UITableViewDelegate
extension AuthenticationTableViewController {
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		if let footerView = view as? UITableViewHeaderFooterView {
			footerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let authenticationSettingsCell = tableView.cellForRow(at: indexPath) as! AuthenticationSettingsCell
		authenticationSettingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		authenticationSettingsCell.cellTitle?.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
		authenticationSettingsCell.authenticationRequireValueLabel?.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let authenticationSettingsCell = tableView.cellForRow(at: indexPath) as! AuthenticationSettingsCell
		authenticationSettingsCell.selectedView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		authenticationSettingsCell.cellTitle?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		authenticationSettingsCell.authenticationRequireValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
	}
}
