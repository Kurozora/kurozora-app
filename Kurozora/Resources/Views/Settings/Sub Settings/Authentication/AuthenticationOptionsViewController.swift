//
//  AuthenticationOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AuthenticationOptionsViewController: SubSettingsViewController {
	/// Set of available authentication intervals.
	let authenticationIntervals: [AuthenticationInterval] = AuthenticationInterval.allCases
}

// MARK: - UITableViewDataSource
extension AuthenticationOptionsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return authenticationIntervals.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let authenticationOptionsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.authenticationOptionsCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.authenticationOptionsCell.identifier)")
		}
		let authenticationInterval = authenticationIntervals[indexPath.row]
		let selectedAuthenticationInterval = UserSettings.authenticationInterval
		authenticationOptionsCell.configureCell(using: authenticationInterval)
		authenticationOptionsCell.setSelected(authenticationInterval == selectedAuthenticationInterval)
		return authenticationOptionsCell
	}
}

// MARK: - UITableViewDelegate
extension AuthenticationOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let authenticationInterval = authenticationIntervals[indexPath.row]
		UserSettings.set(authenticationInterval.rawValue, forKey: .authenticationInterval)

		DispatchQueue.main.async {
			NotificationCenter.default.post(name: .KSAuthenticationRequireTimeoutValueDidChange, object: nil)
		}

		tableView.reloadData()
	}
}
