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
	@IBOutlet weak var datePicker: UIDatePicker!

	var indexPath: IndexPath!
	weak var delegate: DatePickerSettingsDelegate?

	override func layoutSubviews() {
		super.layoutSubviews()
		
		datePicker.setValue(KThemePicker.textColor.colorValue, forKeyPath: "textColor")
		datePicker.setValue(false, forKey: "highlightsToday")
	}

	func updateCell(with date: Date, for indexPath: IndexPath) {
		datePicker.setDate(date, animated: true)
		self.indexPath = indexPath
	}

	// MARK: - IBActions
	@IBAction func dateDidChange(_ sender: UIDatePicker) {
		let indexPathForDisplayDate = IndexPath(row: indexPath.row - 1, section: indexPath.section)
		delegate?.didChangeDate(date: sender.date, indexPath: indexPathForDisplayDate, datePicker: datePicker)
	}
}
