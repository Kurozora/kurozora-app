//
//  AuthenticationOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AuthenticationOptionsViewController: SubSettingsViewController {
}

// MARK: - UITableViewDataSource
extension AuthenticationOptionsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return RequireAuthentication.all.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let authenticationOptionsCell = tableView.dequeueReusableCell(withIdentifier: "AuthenticationOptionsCell", for: indexPath) as! AuthenticationOptionsCell
		authenticationOptionsCell.requireAuthentication = RequireAuthentication(rawValue: indexPath.row)
		return authenticationOptionsCell
	}
}

// MARK: - UITableViewDelegate
extension AuthenticationOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let authenticationOptionsCell = tableView.cellForRow(at: indexPath) as! AuthenticationOptionsCell
		authenticationOptionsCell.isSelected = true

		NotificationCenter.default.post(name: .KSAuthenticationRequireTimeoutValueDidChange, object: nil)
		tableView.reloadData()
	}
}
