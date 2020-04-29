//
//  AuthenticationOptionsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AuthenticationOptionsCell: SettingsCell {
	@IBOutlet weak var selectedImageView: UIImageView! {
		didSet {
			self.selectedImageView.image = nil
		}
	}

	var authenticationInterval: AuthenticationInterval = .immediately {
		didSet {
			configureCell()
		}
	}

	override var isSelected: Bool {
		didSet {
			if isSelected {
				self.selectedImageView.image = R.image.symbols.checkmark()
				self.selectedImageView.theme_tintColor = KThemePicker.tintColor.rawValue
				UserSettings.set(authenticationInterval.rawValue, forKey: .authenticationInterval)
			} else {
				self.selectedImageView.image = nil
			}
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		primaryLabel?.text = authenticationInterval.stringValue
		self.isSelected = authenticationInterval == UserSettings.authenticationInterval
	}
}
