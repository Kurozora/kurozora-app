//
//  LoginTextFieldCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class LoginTextFieldCell: LoginBaseTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var textField: UITextField! {
		didSet {
			textField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			textField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			textField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		switch textField.textType {
		case .emailAddress:
			textField.textType = .emailAddress
			textField.placeholder = "The cool username you claimed 🙌"
		case .password:
			textField.textType = .password
			textField.placeholder = "Your super secret password 👀"
		case .generic: break
		}
	}
}
