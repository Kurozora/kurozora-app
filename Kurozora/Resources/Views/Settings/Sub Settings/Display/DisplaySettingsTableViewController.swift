//
//  DisplaySettingsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class DisplaySettingsTableViewController: SubSettingsViewController {
	// MARK: - Segue Identifiers
	enum SegueIdentifiers: String, SegueIdentifier {
		case appearanceOptionsSegue
	}

	// MARK: - Properties
	private let appearanceOptions: [DisplaySettingsCell.Option] = [
		.init(identifier: AppAppearanceOption.light.rawValue, title: "Light", image: .Settings.Display.lightOption),
		.init(identifier: AppAppearanceOption.dark.rawValue, title: "Dark", image: .Settings.Display.darkOption)
	]
	private var displayedAppAppearanceOption: AppAppearanceOption = AppAppearanceOption(rawValue: UserSettings.appearanceOption) ?? .light

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

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleAutomaticDarkThemeDidChange), name: .KSAutomaticDarkThemeDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleAppAppearanceDidChange(_:)), name: .KSAppAppearanceDidChange, object: nil)

		self.title = Trans.displayBlindness

		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	private func configureSwitchCell(_ cell: SwitchSettingsCell, title: String, isOn: Bool, switchType: SwitchType) {
		cell.configure(title: title, isOn: isOn, tag: switchType.rawValue, action: UIAction { [weak self] action in
			guard
				let self = self,
				let sender = action.sender as? KSwitch
			else { return }
			self.switchTapped(sender)
		})
	}

	private func row(at indexPath: IndexPath) -> Row? {
		guard let section = Section(rawValue: indexPath.section) else { return nil }
		let rows = section.rows(automaticDarkThemeEnabled: UserSettings.automaticDarkTheme)
		guard indexPath.row < rows.count else { return nil }
		return rows[indexPath.row]
	}

	private func automaticDarkThemeOptionsValueText() -> String {
		if UserSettings.darkThemeOption == DarkThemeOption.automatic.rawValue, KThemeStyle.isSolarNighttime {
			return "Dark Until Sunrise"
		} else if UserSettings.darkThemeOption == DarkThemeOption.automatic.rawValue, !KThemeStyle.isSolarNighttime {
			return "Light Until Sunset"
		} else if UserSettings.darkThemeOption == DarkThemeOption.custom.rawValue, KThemeStyle.isCustomNighttime {
			let startDate = UserSettings.darkThemeOptionStart.convertToAMPM()
			return "Dark Until \(startDate)"
		} else if UserSettings.darkThemeOption == DarkThemeOption.custom.rawValue, !KThemeStyle.isCustomNighttime {
			let endDate = UserSettings.darkThemeOptionEnd.convertToAMPM()
			return "Light Until \(endDate)"
		}

		return ""
	}

	private func switchAppearanceIfNeeded(using option: AppAppearanceOption) {
		guard !UserSettings.automaticDarkTheme else { return }

		switch option {
		case .light:
			KThemeStyle.switchTo(style: .day)
		case .dark:
			KThemeStyle.switchTo(style: .night)
		}
	}

	@objc private func switchTapped(_ sender: KSwitch) {
		guard let switchType = SwitchType(rawValue: sender.tag) else { return }

		switch switchType {
		case .automaticDarkTheme:
			UserSettings.set(sender.isOn, forKey: .automaticDarkTheme)
			NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil, userInfo: ["isOn": sender.isOn])
			KThemeStyle.startAutomaticDarkThemeSchedule()
			self.tableView.reloadData()
		case .trueBlack:
			UserSettings.set(sender.isOn, forKey: .trueBlackEnabled)

			if UserSettings.currentTheme.lowercased() == "night" || UserSettings.currentTheme.lowercased() == "black" {
				KThemeStyle.switchTo(style: .night)
			}
		case .largeTitles:
			UserSettings.set(sender.isOn, forKey: .largeTitlesEnabled)
			NotificationCenter.default.post(name: .KSPrefersLargeTitlesDidChange, object: nil)
		}
	}

	private func reloadAppearanceSection() {
		guard self.tableView.numberOfSections > Section.appearance.rawValue else { return }
		self.tableView.reloadSections(IndexSet(integer: Section.appearance.rawValue), with: .none)
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .appearanceOptionsSegue:
			return AppearanceOptionsViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .appearanceOptionsSegue: break
		}
	}

	// MARK: - Observers
	@objc private func handleAutomaticDarkThemeDidChange() {
		self.reloadAppearanceSection()
	}

	@objc private func handleAppAppearanceDidChange(_ notification: NSNotification) {
		if let option = notification.userInfo?["option"] as? Int, let appAppearanceOption = AppAppearanceOption(rawValue: option) {
			self.displayedAppAppearanceOption = appAppearanceOption
		}

		if notification.userInfo?["isOn"] is Bool {
			self.tableView.reloadData()
		} else {
			self.reloadAppearanceSection()
		}
	}
}

// MARK: - KTableViewDataSource
extension DisplaySettingsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			DisplaySettingsCell.self,
			SwitchSettingsCell.self,
			SettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension DisplaySettingsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else { return 0 }
		return section.rows(automaticDarkThemeEnabled: UserSettings.automaticDarkTheme).count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let row = self.row(at: indexPath) else { return UITableViewCell() }

		switch row {
		case .appAppearance:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: DisplaySettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(DisplaySettingsCell.reuseID)")
			}
			cell.delegate = self
			cell.configure(options: self.appearanceOptions, selectedIdentifier: self.displayedAppAppearanceOption.rawValue, isEnabled: !UserSettings.automaticDarkTheme)
			return cell
		case .automaticDarkTheme:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: Trans.automatic, isOn: UserSettings.automaticDarkTheme, switchType: .automaticDarkTheme)
			return cell
		case .automaticDarkThemeOptions:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			cell.configure(title: "Options", detail: self.automaticDarkThemeOptionsValueText())
			cell.chevronImageView?.isHidden = false
			cell.secondaryLabel?.isHidden = false
			return cell
		case .trueBlack:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: "True Black", isOn: UserSettings.trueBlackEnabled, switchType: .trueBlack)
			return cell
		case .largeTitles:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: "Large Titles", isOn: UserSettings.largeTitlesEnabled, switchType: .largeTitles)
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let section = Section(rawValue: section) else { return nil }

		switch section {
		case .appearance:
			return "Appearance"
		case .blindness:
			return "Blindness"
		case .navigationBar:
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let section = Section(rawValue: section) else { return nil }

		switch section {
		case .appearance:
			return nil
		case .blindness:
			return "Enable this option if you prefer a darker black color. Or if you value your eyes' health while using the app in the dark. Or those precious battery juices. Or or or..."
		case .navigationBar:
			return "Disable this option if you hate the large titles in the navigation bar #annoying #too_ugly_for_me"
		}
	}
}

// MARK: - UITableViewDelegate
extension DisplaySettingsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let row = self.row(at: indexPath) else { return }

		switch row {
		case .automaticDarkThemeOptions:
			self.show(SegueIdentifiers.appearanceOptionsSegue, sender: nil)
		case .appAppearance, .automaticDarkTheme, .trueBlack, .largeTitles:
			break
		}
	}
}

// MARK: - DisplaySettingsCellDelegate
extension DisplaySettingsTableViewController: DisplaySettingsCellDelegate {
	func displaySettingsCell(_ cell: DisplaySettingsCell, didSelectOptionWithIdentifier identifier: Int) {
		guard let option = AppAppearanceOption(rawValue: identifier) else { return }

		UserSettings.set(identifier, forKey: .appearanceOption)
		self.displayedAppAppearanceOption = option
		cell.updateSelectedOption(identifier: identifier)
		self.switchAppearanceIfNeeded(using: option)
	}
}

// MARK: - Enums
private extension DisplaySettingsTableViewController {
	enum Section: Int, CaseIterable {
		case appearance = 0
		case blindness
		case navigationBar

		func rows(automaticDarkThemeEnabled: Bool) -> [Row] {
			switch self {
			case .appearance:
				var rows: [Row] = [.appAppearance, .automaticDarkTheme]
				if automaticDarkThemeEnabled {
					rows.append(.automaticDarkThemeOptions)
				}
				return rows
			case .blindness:
				return [.trueBlack]
			case .navigationBar:
				return [.largeTitles]
			}
		}
	}

	enum Row {
		case appAppearance
		case automaticDarkTheme
		case automaticDarkThemeOptions
		case trueBlack
		case largeTitles
	}

	enum SwitchType: Int {
		case automaticDarkTheme = 0
		case trueBlack
		case largeTitles
	}
}
