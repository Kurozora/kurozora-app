//
//  SelectableSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SelectableSettingsCell: SettingsCell {
	@IBOutlet weak var selectedImageView: UIImageView! {
		didSet {
			self.selectedImageView.image = nil
		}
	}

	override var isSelected: Bool {
		didSet {
			if isSelected {
				self.selectedImageView.image = #imageLiteral(resourceName: "check")
				self.selectedImageView.theme_tintColor = KThemePicker.tintColor.rawValue
			} else {
				self.selectedImageView.image = nil
			}
		}
	}
}
