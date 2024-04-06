//
//  KDefaultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class KDefaultsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var valueTextField: KTextField!

	// MARK: - IBActions
	@IBAction func valueTextFieldEditingDidEnd(_ sender: Any) {
		guard let key = primaryLabel?.text else {return}
		guard let value = valueTextField.text else {return}

		SharedDelegate.shared.keychain[key] = value
	}
}
