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

		self.title = UIDevice.supportedBiometric.localizedSettingsName
	}
}

// MARK: - UITableViewDataSource
extension AuthenticationTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return UserSettings.authenticationEnabled ? 2 : 1
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return section == 0 ? UIDevice.supportedBiometric.localizedAuthenticationSettingsDescription : ""
	}
}
