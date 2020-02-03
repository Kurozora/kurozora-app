//
//  NotificationsGroupingCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class NotificationsGroupingCell: SettingsCell {
	@IBOutlet weak var selectedImageView: UIImageView! {
		didSet {
			self.selectedImageView.image = nil
		}
	}

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
