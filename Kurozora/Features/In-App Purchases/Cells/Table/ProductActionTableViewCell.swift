//
//  ProductActionTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftTheme

protocol ProductActionTableViewCellDelegate: class {
	func actionButtonPressed(_ sender: UIButton)
}

class ProductActionTableViewCell: UITableViewCell {
	// MARK: - Properties
	weak var delegate: ProductActionTableViewCellDelegate?

	// MARK: - IBOutlets
	@IBOutlet weak var actionButton: UIButton! {
		didSet {
			actionButton.theme_tintColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var actionTextField: UITextField! {
		didSet {
			actionTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			actionTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			actionTextField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) {
		delegate?.actionButtonPressed(sender)
	}
}
