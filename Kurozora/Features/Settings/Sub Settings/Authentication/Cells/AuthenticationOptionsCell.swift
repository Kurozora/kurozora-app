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

	var requireAuthentication: RequireAuthentication? {
		didSet {
			configureCell()
		}
	}

	override var isSelected: Bool {
		didSet {
			if isSelected {
				self.selectedImageView.image = R.image.symbols.checkmark()
				self.selectedImageView.theme_tintColor = KThemePicker.tintColor.rawValue
				try? Kurozora.shared.KDefaults.set(requireAuthentication?.stringValue ?? RequireAuthentication.immediately.stringValue, key: "requireAuthentication")
			} else {
				self.selectedImageView.image = nil
			}
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		guard let requireAuthentication = requireAuthentication else { return }
		primaryLabel?.text = requireAuthentication.stringValue

		if let requireAuthenticationString = try? Kurozora.shared.KDefaults.get("requireAuthentication") {
			self.isSelected = requireAuthentication.equals(requireAuthenticationString)
		}
	}

}
