//
//  KDefaultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KCommonKit

class KDefaultsCell: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!

    @IBAction func valueTextFieldEditingDidEnd(_ sender: Any) {
        guard let key = keyLabel.text else {return}
        guard let value = valueTextField.text else {return}

        GlobalVariables().KDefaults[key] = value
    }
}
