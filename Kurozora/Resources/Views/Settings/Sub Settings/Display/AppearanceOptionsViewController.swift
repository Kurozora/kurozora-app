//
//  AppearanceOptionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AppearanceOptionsViewController: SubSettingsViewController {
	// MARK: - Properties
	var datePickerIndexPath: IndexPath?
	var inputDates: [Date] = [UserSettings.darkThemeOptionStart, UserSettings.darkThemeOptionEnd]
	let customScheduleOptions: [String] = ["Light Appearance", "Dark Appearance"]
	let automaticOptions: [String] = ["Sunset to Sunrise", "Custom Schedule"]

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

		self.title = "Appearance Schedule"
		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	func indexPathToInsertDatePicker(indexPath: IndexPath) -> IndexPath {
		if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row < indexPath.row {
			return indexPath
		} else {
			return IndexPath(row: indexPath.row + 1, section: indexPath.section)
		}
	}
}

// MARK: - UITableViewDataSource
extension AppearanceOptionsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let darkThemeOption = DarkThemeOption(rawValue: UserSettings.darkThemeOption) else { return 2 }
		switch darkThemeOption {
		case .automatic:
			return 2
		case .custom:
			return 3
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 0
		} else if section == 1 {
			return 2
		}

		guard let darkThemeOption = DarkThemeOption(rawValue: UserSettings.darkThemeOption) else { return 0 }
		switch darkThemeOption {
		case .automatic:
			return 0
		case .custom:
			// If datePicker is already present, we add one extra cell for that.
			if self.datePickerIndexPath != nil, section == 2 {
				return 2 + 1
			} else if section == 2 {
				return 2
			}
		}

		return 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 1 {
			guard let selectableSettingsCell = tableView.dequeueReusableCell(withIdentifier: SelectableSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SelectableSettingsCell.reuseID)")
			}
			if let darkThemeOption = DarkThemeOption(rawValue: indexPath.item) {
				selectableSettingsCell.configure(title: self.automaticOptions[indexPath.row])
				selectableSettingsCell.setSelected(darkThemeOption.rawValue == UserSettings.darkThemeOption)
			}
			return selectableSettingsCell
		} else if self.datePickerIndexPath == indexPath {
			guard let datePickerSettingsCell = tableView.dequeueReusableCell(withIdentifier: DatePickerSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(DatePickerSettingsCell.reuseID)")
			}
			datePickerSettingsCell.configure(title: "Starts at", date: self.inputDates[indexPath.row - 1])
			datePickerSettingsCell.delegate = self
			return datePickerSettingsCell
		}

		guard let settingsCell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
		}
		let indexPathRow = self.datePickerIndexPath != nil && indexPath.row != 0 ? (self.datePickerIndexPath?.row ?? 1) - 1 : indexPath.row
		settingsCell.configure(title: self.customScheduleOptions[indexPathRow], detail: self.inputDates[indexPathRow].convertToAMPM())
		settingsCell.chevronImageView?.isHidden = true
		settingsCell.secondaryLabel?.isHidden = false
		return settingsCell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == 0 {
			return "Automatically transition appearance between light and dark based on time preference."
		}
		return nil
	}
}

// MARK: - UITableViewDelegate
extension AppearanceOptionsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 {
			UserSettings.set(indexPath.item, forKey: .darkThemeOption)
			self.datePickerIndexPath = nil
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: .KSAutomaticDarkThemeDidChange, object: nil)
			}
			tableView.reloadData()
		} else if indexPath.section == 2 {
			if indexPath != self.datePickerIndexPath {
				tableView.beginUpdates()
				if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
					tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
					self.datePickerIndexPath = nil
				} else {
					if let datePickerIndexPath = datePickerIndexPath {
						tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
					}
					datePickerIndexPath = self.indexPathToInsertDatePicker(indexPath: indexPath)
					tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
					tableView.deselectRow(at: indexPath, animated: true)
				}
				tableView.endUpdates()
			}
		}
	}
}

// MARK: - KTableViewDataSource
extension AppearanceOptionsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			SelectableSettingsCell.self,
			DatePickerSettingsCell.self,
			SettingsCell.self
		]
	}
}

// MARK: - DatePickerSettingsCellDelegate
extension AppearanceOptionsViewController: DatePickerSettingsCellDelegate {
	func datePickerSettingsCell(_ cell: DatePickerSettingsCell, didChangeDate datePicker: UIDatePicker) {
		guard var indexPath = tableView.indexPath(for: cell) else { return }
		indexPath.row -= 1
		self.inputDates[indexPath.row] = datePicker.date

		if indexPath.row == 0 {
			UserSettings.set(datePicker.date, forKey: .darkThemeOptionStart)
		} else if indexPath.row == 1 {
			UserSettings.set(datePicker.date, forKey: .darkThemeOptionEnd)
		}

		NotificationCenter.default.post(name: .KSAutomaticDarkThemeDidChange, object: nil)

		self.tableView.reloadRows(at: [indexPath], with: .none)
	}
}
