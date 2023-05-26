//
//  SearchFilterSwitchCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class SearchFilterSwitchCollectionViewCell: SearchFilterBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var kSwitch: KSwitch!

	// MARK: - Functions
	func configureCell(title: String?, selected: Bool?) {
		super.configureCell(title: title)

		self.kSwitch.isOn = selected == true
	}

	// MARK: - IBActions
	@IBAction func switchValueChanged(_ sender: UISwitch) {
		self.delegate?.searchFilterBaseCollectionViewCell(self, didChangeValue: sender.isOn)
	}
}
