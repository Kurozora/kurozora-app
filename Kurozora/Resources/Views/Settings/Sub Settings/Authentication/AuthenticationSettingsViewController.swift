//
//  AuthenticationSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AuthenticationSettingsViewController: SubSettingsViewController {
	// MARK: - Segue Identifiers
	enum SegueIdentifiers: String, SegueIdentifier {
		case authenticationOptionsSegue
	}

	// MARK: - Properties
	private var allowsAuthentication = UserSettings.authenticationEnabled

	private var visibleSections: [Section] {
		return self.allowsAuthentication ? Section.allCases : [.authentication]
	}

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

		self.title = UIDevice.supportedBiometric.localizedSettingsName

		self.configureView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let currentAllowsAuthentication = UserSettings.authenticationEnabled

		if currentAllowsAuthentication != self.allowsAuthentication {
			self.allowsAuthentication = currentAllowsAuthentication
			self.tableView.reloadData()
		}
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	private func configureSwitchCell(_ cell: SwitchSettingsCell, title: String, isOn: Bool, tag: Row) {
		cell.configure(title: title, isOn: isOn, tag: tag.rawValue, action: UIAction { [weak self] action in
			guard
				let self = self,
				let sender = action.sender as? KSwitch
			else { return }
			self.switchTapped(sender)
		})
	}

	// MARK: - Actions
	@objc private func switchTapped(_ sender: KSwitch) {
		guard let switchType = Row(rawValue: sender.tag) else { return }
		let isOn = sender.isOn

		switch switchType {
		case .toggleAuthentication:
			UserSettings.set(isOn, forKey: .authenticationEnabled)
			self.allowsAuthentication = isOn
			self.tableView.reloadData()
		case .requireAuthentication: break
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .authenticationOptionsSegue:
			return AuthenticationOptionsViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .authenticationOptionsSegue:
			guard let authenticationOptionsViewController = destination as? AuthenticationOptionsViewController else { return }
			authenticationOptionsViewController.delegate = self
		}
	}
}

// MARK: - KTableViewDataSource
extension AuthenticationSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			SwitchSettingsCell.self,
			SettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension AuthenticationSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.visibleSections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.visibleSections[section].rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = self.visibleSections[indexPath.section].rows[indexPath.row]

		switch row {
		case .toggleAuthentication:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: UIDevice.supportedBiometric.localizedSettingsName, isOn: UserSettings.authenticationEnabled, tag: row)
			return cell
		case .requireAuthentication:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			cell.configure(title: Trans.requireAuthentication, detail: UserSettings.authenticationInterval.stringValue)
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch self.visibleSections[section] {
		case .authentication:
			return UIDevice.supportedBiometric.localizedAuthenticationSettingsDescription
		case .options:
			return UserSettings.authenticationInterval.footerStringValue
		}
	}
}

// MARK: - UITableViewDelegate
extension AuthenticationSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch self.visibleSections[indexPath.section].rows[indexPath.row] {
		case .toggleAuthentication: break
		case .requireAuthentication:
			self.show(SegueIdentifiers.authenticationOptionsSegue, sender: nil)
		}
	}
}

// MARK: - AuthenticationOptionsViewControllerDelegate
extension AuthenticationSettingsViewController: AuthenticationOptionsViewControllerDelegate {
	func authenticationOptionsViewController(_ controller: AuthenticationOptionsViewController, didChangeAuthenticationInterval authenticationInterval: AuthenticationInterval) {
		self.tableView.reloadData()
	}
}

// MARK: - Sections and Rows
extension AuthenticationSettingsViewController {
	/// List of authentication settings sections.
	enum Section: Int, CaseIterable {
		case authentication
		case options

		/// List of rows in the section.
		var rows: [Row] {
			switch self {
			case .authentication:
				return [.toggleAuthentication]
			case .options:
				return [.requireAuthentication]
			}
		}
	}

	/// List of authentication settings rows.
	enum Row: Int, CaseIterable {
		case toggleAuthentication
		case requireAuthentication
	}
}
