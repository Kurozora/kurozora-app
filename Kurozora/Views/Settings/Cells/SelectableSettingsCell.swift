//
//  SelectableSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SelectableSettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var selectedImageView: KImageView! {
		didSet {
			self.selectedImageView.image = nil
		}
	}

	// MARK: - Functions
	/**
		Sets the selected status of the cell.

		- Parameter selected: The boolean value indicating whether the cell is selected.
	*/
	func setSelected(_ selected: Bool) {
		self.selectedImageView?.image = selected ? UIImage(systemName: "checkmark") : nil
	}
}
