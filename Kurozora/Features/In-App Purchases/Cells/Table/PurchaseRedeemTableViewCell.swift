//
//  PurchaseRedeemTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftTheme

class PurchaseRedeemTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var redeemButton: UIButton! {
		didSet {
			redeemButton.theme_tintColor = KThemePicker.tintColor.rawValue
		}
	}
	@IBOutlet weak var redeemTextField: UITextField! {
		didSet {
			redeemTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			redeemTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			redeemTextField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}

	// MARK: - IBActions
	@IBAction func redeemButtonPressed(_ sender: UIButton) {
		SCLAlertView().showInfo("No touchy!", subTitle: "This feature is a work in progress. It will be available in the upcoming feature.")
	}
}
