//
//  DatePickerSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol DatePickerSettingsDelegate: class {
	func didChangeDate(date: Date, indexPath: IndexPath, datePicker: UIDatePicker)
}

class DatePickerSettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var datePicker: UIDatePicker!

	// MARK: - Properties
	weak var delegate: DatePickerSettingsDelegate?

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		datePicker.textColor = KThemePicker.textColor.colorValue
	}

	// MARK: - Functions
	func updateCell(with date: Date, for indexPath: IndexPath) {
		datePicker.setDate(date, animated: true)
	}

	// MARK: - IBActions
	@IBAction func dateDidChange(_ sender: UIDatePicker) {
		if var indexPathForDisplayDate = indexPath {
			indexPathForDisplayDate.row -= 1
			delegate?.didChangeDate(date: sender.date, indexPath: indexPathForDisplayDate, datePicker: datePicker)
		}
	}
}
