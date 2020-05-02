//
//  KDefaultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class KDefaultsCell: SettingsCell {
	@IBOutlet weak var valueTextField: KTextField!

    @IBAction func valueTextFieldEditingDidEnd(_ sender: Any) {
        guard let key = primaryLabel?.text else {return}
        guard let value = valueTextField.text else {return}

		Kurozora.shared.keychain[key] = value
    }
}
