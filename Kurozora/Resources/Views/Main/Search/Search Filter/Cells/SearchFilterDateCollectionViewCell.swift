//
//  SearchFilterDateCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class SearchFilterDateCollectionViewCell: SearchFilterBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var datePicker: UIDatePicker!

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.datePicker.theme_tintColor = KThemePicker.tintColor.rawValue
	}

	// MARK: - Functions
	func configureCell(title: String?, selected: Date?) {
		super.configureCell(title: title)

		if let selected = selected {
			self.datePicker.date = selected
		}
	}

	// MARK: - IBActions
	@IBAction func dateDidChange(_ sender: UIDatePicker) {
		self.delegate?.searchFilterBaseCollectionViewCell(self, didChangeValue: sender.date)
	}
}
