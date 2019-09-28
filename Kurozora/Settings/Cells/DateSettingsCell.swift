//
//  DateSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class DateSettingsCell: SettingsCell {
	@IBOutlet weak var dateLabel: UILabel! {
		didSet {
			dateLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	// MARK: - Functions
	 func updateText(with date: Date) {
		dateLabel.text = date.convertToAMPM()
	}
}

extension Date {
	func convertToAMPM() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "hh:mm a"
		let newDate: String = dateFormatter.string(from: self)
		return newDate
	}
}
