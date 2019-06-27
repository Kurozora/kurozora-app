//
//  KDefaultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KCommonKit
import SwiftTheme

class KDefaultsCell: UITableViewCell {
	@IBOutlet weak var keyLabel: UILabel! {
		didSet {
			keyLabel.theme_textColor = KThemePicker.textColor.rawValue
			keyLabel.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
	@IBOutlet weak var valueTextField: UITextField! {
		didSet {
			valueTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			valueTextField.theme_textColor = KThemePicker.textColor.rawValue
			valueTextField.theme_placeholderAttributes = ThemeDictionaryPicker(keyPath: KThemePicker.separatorColor.stringValue) { value -> [NSAttributedString.Key : AnyObject]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}
	@IBOutlet weak var cornerView: UIView! {
		didSet {
			cornerView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

    @IBAction func valueTextFieldEditingDidEnd(_ sender: Any) {
        guard let key = keyLabel.text else {return}
        guard let value = valueTextField.text else {return}

        GlobalVariables().KDefaults[key] = value
    }
}
