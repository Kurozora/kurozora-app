//
//  AuthenticationOptionsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AuthenticationOptionsCell: SelectableSettingsCell {
	var authenticationInterval: AuthenticationInterval = .immediately {
		didSet {
			self.configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		primaryLabel?.text = authenticationInterval.stringValue
		self.isSelected = authenticationInterval == UserSettings.authenticationInterval
	}
}
