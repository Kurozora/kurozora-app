//
//  AuthenticationTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AuthenticationTableViewController: SubSettingsViewController {
	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		switch UIDevice.supportedBiomtetric {
		case .faceID:
			title = "Face ID & Passcode"
		case .touchID:
			title = "Touch ID & Passcode"
		case .opticID:
			title = "Optic ID & Passcode"
		default:
			title = "Passcode"
		}
	}
}

// MARK: - UITableViewDataSource
extension AuthenticationTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return UserSettings.authenticationEnabled ? 2 : 1
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == 0 {
			switch UIDevice.supportedBiomtetric {
			case .faceID:
				return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Face ID or your device's passcode when you reopen the app."
			case .touchID:
				return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Touch ID or your device's passcode when you reopen the app."
			case .opticID:
				return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through Optic ID or your device's passcode when you reopen the app."
			default:
				return "Enable this option so that Kurozora is locked whenever you close it. You'll be asked to authenticate through your device's passcode when you reopen the app."
			}
		}

		return ""
	}
}
