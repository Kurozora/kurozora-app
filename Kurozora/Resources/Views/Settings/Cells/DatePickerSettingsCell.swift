//
//  DatePickerSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class DatePickerSettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var datePicker: UIDatePicker!

	// MARK: - Properties
	weak var delegate: DatePickerSettingsCellDelegate?

	// MARK: - Functions
	func updateCell(with date: Date, for indexPath: IndexPath) {
		self.datePicker.setDate(date, animated: true)
	}

	// MARK: - IBActions
	@IBAction func dateDidChange(_ sender: UIDatePicker) {
		self.delegate?.datePickerSettingsCell(self, didChangeDate: sender)
	}
}
