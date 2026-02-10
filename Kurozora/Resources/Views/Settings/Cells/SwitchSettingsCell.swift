//
//  SwitchSettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class SwitchSettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet var toggleSwitch: KSwitch!

	// MARK: - Functions
	func configure(title: String, isOn: Bool, tag: Int, action: UIAction) {
		self.primaryLabel?.text = title
		self.toggleSwitch.isOn = isOn
		self.toggleSwitch.tag = tag

		self.toggleSwitch.removeAction(identifiedBy: action.identifier, for: .valueChanged)
		self.toggleSwitch.addAction(action, for: .valueChanged)
	}
}
