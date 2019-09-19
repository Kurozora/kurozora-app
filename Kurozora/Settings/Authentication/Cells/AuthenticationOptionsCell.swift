//
//  AuthenticationOptionsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit

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
				self.selectedImageView.image = #imageLiteral(resourceName: "check")
				self.selectedImageView.theme_tintColor = KThemePicker.tintColor.rawValue
				try? GlobalVariables().KDefaults.set(requireAuthentication?.stringValue ?? RequireAuthentication.immediately.stringValue, key: "requireAuthentication")
			} else {
				self.selectedImageView.image = nil
			}
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let requireAuthentication = requireAuthentication else { return }
		cellTitle?.text = requireAuthentication.stringValue

		if let requireAuthenticationString = try? GlobalVariables().KDefaults.get("requireAuthentication") {
			self.isSelected = requireAuthentication.equals(requireAuthenticationString)
		}
	}

}
