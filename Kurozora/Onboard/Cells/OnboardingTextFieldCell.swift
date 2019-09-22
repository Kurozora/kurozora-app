//
//  LoginTextFieldCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class OnboardingTextFieldCell: OnboardingBaseTableViewCell {
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

		switch onboardingType {
		case .register:
			switch textField.textType {
			case .username:
				textField.placeholder = "Username: pick a cool one 🙉"
			case .emailAddress:
				textField.placeholder = "Email: we all forget our passwords 🙈"
			case .password:
				textField.placeholder = "Password: make it super secret 🙊"
			default: break
			}
		case .login:
			switch textField.textType {
			case .username:
				textField.placeholder = "The cool Kurozora ID you claimed 🙌"
			case .password:
				textField.placeholder = "Your super secret password 👀"
			default: break
			}
		case .reset:
			switch textField.textType {
			case .emailAddress:
				textField.placeholder = "Your email to the rescue 💌"
			default : break
			}
		}
	}
}
