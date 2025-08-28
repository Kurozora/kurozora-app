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

	// MARK: - Functions
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
		case .automatic: break
		case .custom:
			// If datePicker is already present, we add one extra cell for that
			if datePickerIndexPath != nil, section == 2 {
				return 2 + 1
			} else if section == 2 {
				return 2
			}
		}

		return 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 1 {
			guard let selectableSettingsCell = tableView.dequeueReusableCell(withIdentifier: "\(SelectableSettingsCell.self)", for: indexPath) as? SelectableSettingsCell else {
				fatalError("Cannot dequeue reusable cell with identifier \(SelectableSettingsCell.self)")
			}
			if let darkThemeOption = DarkThemeOption(rawValue: indexPath.item) {
				selectableSettingsCell.primaryLabel?.text = automaticOptions[indexPath.row]
				selectableSettingsCell.setSelected(darkThemeOption.rawValue == UserSettings.darkThemeOption)
			}
			return selectableSettingsCell
		} else if datePickerIndexPath == indexPath {
			guard let datePickerSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.datePickerSettingsCell, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.datePickerSettingsCell.identifier)")
			}
			datePickerSettingsCell.updateCell(with: inputDates[indexPath.row - 1], for: indexPath)
			datePickerSettingsCell.delegate = self
			return datePickerSettingsCell
		}

		guard let dateSettingsCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dateSettingsCell, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.dateSettingsCell.identifier)")
		}
		let indexPathRow = datePickerIndexPath != nil && indexPath.row != 0 ? (datePickerIndexPath?.row ?? 1) - 1 : indexPath.row
		dateSettingsCell.primaryLabel?.text = customScheduleOptions[indexPathRow]
		dateSettingsCell.updateText(with: inputDates[indexPathRow])
		return dateSettingsCell
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
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: .KSAutomaticDarkThemeDidChange, object: nil)
			}
			tableView.reloadData()
		} else if indexPath.section == 2 {
			if indexPath != datePickerIndexPath {
				tableView.beginUpdates()
				if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
					tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
					self.datePickerIndexPath = nil
				} else {
					if let datePickerIndexPath = datePickerIndexPath {
						tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
					}
					datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
					tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
					tableView.deselectRow(at: indexPath, animated: true)
				}
				tableView.endUpdates()
			}
		}
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 55
	}
}

// MARK: - KTableViewDataSource
extension AppearanceOptionsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [SelectableSettingsCell.self]
	}
}

// MARK: - DatePickerSettingsCellDelegate
extension AppearanceOptionsViewController: DatePickerSettingsCellDelegate {
	func datePickerSettingsCell(_ cell: DatePickerSettingsCell, didChangeDate datePicker: UIDatePicker) {
		guard var indexPath = tableView.indexPath(for: cell) else { return }
		indexPath.row -= 1
		inputDates[indexPath.row] = datePicker.date

		if indexPath.row == 0 {
			UserSettings.set(datePicker.date, forKey: .darkThemeOptionStart)
		} else if indexPath.row == 1 {
			UserSettings.set(datePicker.date, forKey: .darkThemeOptionEnd)
		}

		NotificationCenter.default.post(name: .KSAutomaticDarkThemeDidChange, object: nil)

		tableView.reloadRows(at: [indexPath], with: .none)
	}
}
