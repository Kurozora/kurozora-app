//
//  KDefaultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftTheme

class KDefaultsCell: SettingsCell {
	@IBOutlet weak var valueTextField: UITextField! {
		didSet {
			valueTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			valueTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			valueTextField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}

    @IBAction func valueTextFieldEditingDidEnd(_ sender: Any) {
        guard let key = cellTitle?.text else {return}
        guard let value = valueTextField.text else {return}

        GlobalVariables().KDefaults[key] = value
    }
}
