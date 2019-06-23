//
//  DisplaySettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit

class DisplaySettingsCell: SettingsCell {
	@IBOutlet weak var enabledSwitch: UISwitch? {
		didSet {
			enabledSwitch?.theme_onTintColor = KThemePicker.tintColor.rawValue
			enabledSwitch?.isOn = UserSettings.largeTitles
		}
	}

	// MARK: IBActions
	@IBAction func enabledSwitchSwitched(_ sender: UISwitch) {
		UserSettings.set(sender.isOn, forKey: .largeTitles)
	}
}
