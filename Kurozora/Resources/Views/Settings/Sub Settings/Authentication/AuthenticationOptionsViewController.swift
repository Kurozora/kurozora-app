//
//  AuthenticationOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol AuthenticationOptionsViewControllerDelegate: AnyObject {
	func authenticationOptionsViewController(_ vc: AuthenticationOptionsViewController, didChangeAuthenticationInterval authenticationInterval: AuthenticationInterval)
}

class AuthenticationOptionsViewController: SubSettingsViewController {
	// MARK: - Properties
	weak var delegate: AuthenticationOptionsViewControllerDelegate?

	/// Set of available authentication intervals.
	private let authenticationIntervals: [AuthenticationInterval] = AuthenticationInterval.allCases

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = Trans.requireAuthentication

		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}
}

// MARK: - KTableViewDataSource
extension AuthenticationOptionsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [SelectableSettingsCell.self]
	}
}

// MARK: - UITableViewDataSource
extension AuthenticationOptionsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.authenticationIntervals.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectableSettingsCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(SelectableSettingsCell.reuseID)")
		}
		let authenticationInterval = self.authenticationIntervals[indexPath.row]
		let selectedAuthenticationInterval = UserSettings.authenticationInterval

		cell.configure(title: authenticationInterval.stringValue)
		cell.setSelected(authenticationInterval == selectedAuthenticationInterval)
		return cell
	}
}

// MARK: - UITableViewDelegate
extension AuthenticationOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let authenticationInterval = self.authenticationIntervals[indexPath.row]
		UserSettings.set(authenticationInterval.rawValue, forKey: .authenticationInterval)

		self.delegate?.authenticationOptionsViewController(self, didChangeAuthenticationInterval: authenticationInterval)

		tableView.reloadData()
	}
}
