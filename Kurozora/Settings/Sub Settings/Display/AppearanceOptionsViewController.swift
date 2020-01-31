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
		if indexPath.section == 1, let selectableSettingsCell = tableView.dequeueReusableCell(withIdentifier: "SelectableSettingsCell", for: indexPath) as? SelectableSettingsCell {
			selectableSettingsCell.primaryLabel?.text = automaticOptions[indexPath.row]
			let darkThemeOption = DarkThemeOption(rawValue: indexPath.item)!
			let selected = UserSettings.darkThemeOption

			if darkThemeOption.rawValue == selected {
				selectableSettingsCell.isSelected = true
			}

			return selectableSettingsCell
		} else if datePickerIndexPath == indexPath, let datePickerSettingsCell = tableView.dequeueReusableCell(withIdentifier: "DatePickerSettingsCell", for: indexPath) as? DatePickerSettingsCell {
			datePickerSettingsCell.updateCell(with: inputDates[indexPath.row - 1], for: indexPath)
			datePickerSettingsCell.delegate = self
			return datePickerSettingsCell
		}

		let dateSettingsCell = tableView.dequeueReusableCell(withIdentifier: "DateSettingsCell", for: indexPath) as! DateSettingsCell
		dateSettingsCell.primaryLabel?.text = customScheduleOptions[indexPath.row]
		dateSettingsCell.updateText(with: inputDates[indexPath.row])
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

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if datePickerIndexPath == indexPath {
			return 221
		} else {
			return 55
		}
	}
}

// MARK: - DatePickerSettingsDelegate
extension AppearanceOptionsViewController: DatePickerSettingsDelegate {
	func didChangeDate(date: Date, indexPath: IndexPath, datePicker: UIDatePicker) {
		inputDates[indexPath.row] = date

		if indexPath.row == 0 {
			UserSettings.set(date, forKey: .darkThemeOptionStart)
		} else if indexPath.row == 1 {
			UserSettings.set(date, forKey: .darkThemeOptionEnd)
		}

		NotificationCenter.default.post(name: .KSAutomaticDarkThemeDidChange, object: nil)

		datePicker.setValue(KThemePicker.textColor.colorValue, forKeyPath: "textColor")
		tableView.reloadRows(at: [indexPath], with: .none)
	}
}
