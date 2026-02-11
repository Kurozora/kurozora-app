//
//  DatePickerSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol DatePickerSettingsCellDelegate: AnyObject {
	func datePickerSettingsCell(_ cell: DatePickerSettingsCell, didChangeDate datePicker: UIDatePicker)
}

class DatePickerSettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var datePicker: UIDatePicker!

	// MARK: - Properties
	weak var delegate: DatePickerSettingsCellDelegate?

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.datePicker.theme_tintColor = KThemePicker.tintColor.rawValue
	}

	// MARK: - Functions
	func configure(title: String?, date: Date) {
		self.configure(title: title)

		self.datePicker.setDate(date, animated: true)
	}

	// MARK: - IBActions
	@IBAction func dateDidChange(_ sender: UIDatePicker) {
		self.delegate?.datePickerSettingsCell(self, didChangeDate: sender)
	}
}
