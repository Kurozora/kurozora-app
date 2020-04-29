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
	let authenticationIntervals: [AuthenticationInterval] = AuthenticationInterval.all
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
		return authenticationOptionsCell
	}
}

// MARK: - UITableViewDelegate
extension AuthenticationOptionsViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let authenticationOptionsCell = cell as? AuthenticationOptionsCell {
			authenticationOptionsCell.authenticationInterval = authenticationIntervals[indexPath.row]
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let authenticationOptionsCell = tableView.cellForRow(at: indexPath) as! AuthenticationOptionsCell
		authenticationOptionsCell.isSelected = true

		NotificationCenter.default.post(name: .KSAuthenticationRequireTimeoutValueDidChange, object: nil)
		tableView.reloadData()
	}
}
