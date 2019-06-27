//
//  DisplaySettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KCommonKit

/**
	List of app appearance options

	- case light = 0
	- case dark = 1
*/
enum AppAppearanceOption: Int {
	case light = 0
	case dark
}

class DisplaySettingsCell: SettingsCell {
	@IBOutlet weak var lightOptionImageView: UIImageView? {
		didSet {
			lightOptionImageView?.image = #imageLiteral(resourceName: "light_option")
		}
	}
	@IBOutlet weak var darkOptionImageView: UIImageView? {
		didSet {
			darkOptionImageView?.image = #imageLiteral(resourceName: "dark_option")
		}
	}

	@IBOutlet weak var lightOptionSelectedImageView: UIImageView? {
		didSet {
			lightOptionSelectedImageView?.theme_tintColor = KThemePicker.tintColor.rawValue
			lightOptionSelectedImageView?.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var darkOptionSelectedImageView: UIImageView? {
		didSet {
			darkOptionSelectedImageView?.theme_tintColor = KThemePicker.tintColor.rawValue
			darkOptionSelectedImageView?.theme_borderColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	@IBOutlet weak var lightOptionTitleLabel: UILabel? {
		didSet {
			lightOptionTitleLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var darkOptionTitleLabel: UILabel? {
		didSet {
			darkOptionTitleLabel?.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}

	@IBOutlet weak var lightOptionButton: UIButton? {
		didSet {
			lightOptionButton?.tag = 0
		}
	}
	@IBOutlet weak var darkOptionButton: UIButton? {
		didSet {
			darkOptionButton?.tag = 1
		}
	}

	@IBOutlet weak var optionsValueLabel: UILabel? {
		didSet {
			updateOptionsValueLabel()
			optionsValueLabel?.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			NotificationCenter.default.addObserver(self, selector: #selector(updateOptionsValueLabel), name: updateAutomaticDarkThemeOptionValueLabelNotification, object: nil)
		}
	}

	@IBOutlet weak var enabledAutomaticDarkThemeSwitch: UISwitch? {
		didSet {
			enabledAutomaticDarkThemeSwitch?.theme_onTintColor = KThemePicker.tintColor.rawValue
			enabledAutomaticDarkThemeSwitch?.isOn = UserSettings.automaticDarkTheme
		}
	}

	@IBOutlet weak var enabledTrueBlackSwitch: UISwitch? {
		didSet {
			enabledTrueBlackSwitch?.theme_onTintColor = KThemePicker.tintColor.rawValue
			enabledTrueBlackSwitch?.isOn = UserSettings.trueBlackEnabled
		}
	}

	@IBOutlet weak var enabledLargeTitlesSwitch: UISwitch? {
		didSet {
			enabledLargeTitlesSwitch?.theme_onTintColor = KThemePicker.tintColor.rawValue
			enabledLargeTitlesSwitch?.isOn = UserSettings.largeTitlesEnabled
		}
	}

	// MARK: - Functions
	@objc fileprivate func updateOptionsValueLabel() {
		if UserSettings.darkThemeOption == 0 && KThemeStyle.isSolarNighttime {
			optionsValueLabel?.text = "Dark Until Sunrise"
		} else if UserSettings.darkThemeOption == 0 && !KThemeStyle.isSolarNighttime {
			optionsValueLabel?.text = "Light Until Sunset"
		} else if UserSettings.darkThemeOption == 1 && KThemeStyle.isCustomNighttime {
			let startDate = UserSettings.darkThemeOptionStart.convertToAMPM()
			optionsValueLabel?.text = "Dark Until \(startDate)"
		} else {
			let endDate = UserSettings.darkThemeOptionEnd.convertToAMPM()
			optionsValueLabel?.text = "Light Until \(endDate)"
		}
	}

	// MARK: - Functions
	func updateAppAppearance(with option: Int) {
		guard let appAppearanceOption = AppAppearanceOption(rawValue: option) else { return }

		switch appAppearanceOption {
		case .light:
			lightOptionSelectedImageView?.borderWidth = 0
			darkOptionSelectedImageView?.borderWidth = 2

			lightOptionSelectedImageView?.image = #imageLiteral(resourceName: "check_circle")
			darkOptionSelectedImageView?.image = nil

			if !UserSettings.automaticDarkTheme {
				KThemeStyle.switchTo(.day)
			}
		case .dark:
			darkOptionSelectedImageView?.borderWidth = 0
			lightOptionSelectedImageView?.borderWidth = 2

			darkOptionSelectedImageView?.image = #imageLiteral(resourceName: "check_circle")
			lightOptionSelectedImageView?.image = nil

			if !UserSettings.automaticDarkTheme {
				KThemeStyle.switchTo(.night)
			}
		}
	}

	// MARK: - IBActions
	@IBAction func appearanceOptionButtonTapped(_ sender: UIButton) {
		UserSettings.set(sender.tag, forKey: .appearanceOption)
		updateAppAppearance(with: sender.tag)
	}

	@IBAction func enableAutomaticDarkThemeSwitched(_ sender: UISwitch) {
		UserSettings.set(sender.isOn, forKey: .automaticDarkTheme)

		KThemeStyle.startAutomaticDarkThemeSchedule()

		if let tableView = self.superview as? UITableView {
			tableView.reloadData()
		}
	}

	@IBAction func enableTrueBlackSwitched(_ sender: UISwitch) {
		UserSettings.set(sender.isOn, forKey: .trueBlackEnabled)

		if !UserSettings.automaticDarkTheme {
			KThemeStyle.switchTo(.night)
		}
	}

	@IBAction func enabledSwitchSwitched(_ sender: UISwitch) {
		UserSettings.set(sender.isOn, forKey: .largeTitlesEnabled)
		NotificationCenter.default.post(name: updateNormalLargeTitlesNotification, object: nil)
	}
}
