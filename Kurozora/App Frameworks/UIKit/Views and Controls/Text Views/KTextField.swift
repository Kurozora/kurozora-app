//
//  KTextField.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

/// A themed object that displays an editable text area in your interface.
///
/// You use text fields to gather text-based input from the user using the onscreen keyboard.
/// The keyboard is configurable for many different types of input such as plain text, emails, numbers, and so on.
/// Text fields use the target-action mechanism and a delegate object to report changes made during the course of editing.
///
/// `KTextField` applys a rounded border style to the text field and applys colors according to the currently selected theme.
class KTextField: UITextField {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the label.
	func sharedInit() {
		self.theme_textColor = KThemePicker.textFieldTextColor.rawValue
		self.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
		self.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
			guard let rgba = value as? String else { return nil }
			let color = UIColor(rgba: rgba)
			let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

			return titleTextAttributes
		}
		self.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
		self.borderStyle = .roundedRect
		self.borderWidth = 1
		self.cornerRadius = 10
	}
}
