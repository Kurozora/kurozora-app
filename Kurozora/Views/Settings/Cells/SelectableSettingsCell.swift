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
	@IBOutlet weak var selectedImageView: UIImageView! {
		didSet {
			self.selectedImageView.image = nil
		}
	}

	// MARK: - Properties
	override var isSelected: Bool {
		didSet {
			if isSelected {
				self.selectedImageView.image = R.image.symbols.checkmark()
				self.selectedImageView.theme_tintColor = KThemePicker.tintColor.rawValue
			} else {
				self.selectedImageView.image = nil
			}
		}
	}
}
