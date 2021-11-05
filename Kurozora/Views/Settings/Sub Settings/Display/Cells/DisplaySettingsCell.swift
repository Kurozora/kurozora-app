//
//  DisplaySettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class DisplaySettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var lightOptionContainerView: UIView?
	@IBOutlet weak var lightOptionImageView: UIImageView? {
		didSet {
			lightOptionImageView?.image = R.image.settings.display.lightOption()
			toggleAppAppearanceOptions(!UserSettings.automaticDarkTheme)
			NotificationCenter.default.addObserver(self, selector: #selector(updateAppAppearance(_:)), name: .KSAppAppearanceDidChange, object: nil)
		}
	}
	@IBOutlet weak var lightOptionSelectedImageView: UIImageView? {
		didSet {
			lightOptionSelectedImageView?.theme_tintColor = KThemePicker.tintColor.rawValue
			lightOptionSelectedImageView?.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
		}
	}
	@IBOutlet weak var lightOptionButton: UIButton?

	@IBOutlet weak var darkOptionContainerView: UIView?
	@IBOutlet weak var darkOptionImageView: UIImageView? {
		didSet {
			darkOptionImageView?.image = R.image.settings.display.darkOption()
		}
	}
	@IBOutlet weak var darkOptionSelectedImageView: UIImageView? {
		didSet {
			darkOptionSelectedImageView?.theme_tintColor = KThemePicker.tintColor.rawValue
			darkOptionSelectedImageView?.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
		}
	}
	@IBOutlet weak var darkOptionButton: UIButton?

	@IBOutlet weak var optionsValueLabel: KSecondaryLabel? {
		didSet {
			updateOptionsValueLabel()
			NotificationCenter.default.addObserver(self, selector: #selector(updateOptionsValueLabel), name: .KSAutomaticDarkThemeDidChange, object: nil)
		}
	}

	@IBOutlet weak var enabledAutomaticDarkThemeSwitch: KSwitch? {
		didSet {
			enabledAutomaticDarkThemeSwitch?.isOn = UserSettings.automaticDarkTheme
			toggleAppAppearanceOptions(UserSettings.automaticDarkTheme)
		}
	}

	@IBOutlet weak var enabledTrueBlackSwitch: KSwitch? {
		didSet {
			enabledTrueBlackSwitch?.isOn = UserSettings.trueBlackEnabled
		}
	}

	@IBOutlet weak var enabledLargeTitlesSwitch: KSwitch? {
		didSet {
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
		} else if UserSettings.darkThemeOption == 1 && !KThemeStyle.isCustomNighttime {
			let endDate = UserSettings.darkThemeOptionEnd.convertToAMPM()
			optionsValueLabel?.text = "Light Until \(endDate)"
		} else {
			optionsValueLabel?.text = ""
		}
	}

	/**
		Updates the app's appearance with the received information.

		- Parameter notification: An object containing information broadcast to registered observers.
	*/
	@objc func updateAppAppearance(_ notification: NSNotification) {
		if let option = notification.userInfo?["option"] as? Int {
			updateAppAppearance(with: option)
		} else if let isOn = notification.userInfo?["isOn"] as? Bool {
			toggleAppAppearanceOptions(!isOn)
		}
	}

	func updateAppAppearance(with option: Int) {
		guard let appAppearanceOption = AppAppearanceOption(rawValue: option) else { return }
		updateAppAppearanceOptions(with: appAppearanceOption)

		switch appAppearanceOption {
		case .light:
			if !UserSettings.automaticDarkTheme {
				KThemeStyle.switchTo(style: .day)
			}
		case .dark:
			if !UserSettings.automaticDarkTheme {
				KThemeStyle.switchTo(style: .night)
			}
		}
	}

	func updateAppAppearanceOptions(with option: AppAppearanceOption) {
		switch option {
		case .light:
			lightOptionSelectedImageView?.borderWidth = 0
			darkOptionSelectedImageView?.borderWidth = 2

			lightOptionSelectedImageView?.image = UIImage(systemName: "checkmark.circle.fill")
			darkOptionSelectedImageView?.image = nil
		case .dark:
			darkOptionSelectedImageView?.borderWidth = 0
			lightOptionSelectedImageView?.borderWidth = 2

			darkOptionSelectedImageView?.image = UIImage(systemName: "checkmark.circle.fill")
			lightOptionSelectedImageView?.image = nil
		}
	}

	func toggleAppAppearanceOptions(_ isOn: Bool) {
		lightOptionButton?.isUserInteractionEnabled = isOn
		darkOptionButton?.isUserInteractionEnabled = isOn
		if isOn {
			darkOptionContainerView?.alpha = 1.0
			lightOptionContainerView?.alpha = 1.0
		} else {
			darkOptionContainerView?.alpha = 0.5
			lightOptionContainerView?.alpha = 0.5
		}
	}

	// MARK: - IBActions
	@IBAction func appearanceOptionButtonTapped(_ sender: UIButton) {
		UserSettings.set(sender.tag, forKey: .appearanceOption)
		updateAppAppearance(with: sender.tag)
	}

	@IBAction func enableAutomaticDarkThemeSwitched(_ sender: KSwitch) {
		UserSettings.set(sender.isOn, forKey: .automaticDarkTheme)
		NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil, userInfo: ["isOn": sender.isOn])

		KThemeStyle.startAutomaticDarkThemeSchedule()

		self.parentTableView?.reloadData()
	}

	@IBAction func enableTrueBlackSwitched(_ sender: KSwitch) {
		UserSettings.set(sender.isOn, forKey: .trueBlackEnabled)

		if UserSettings.currentTheme == "Night" || UserSettings.currentTheme == "Black" {
			KThemeStyle.switchTo(style: .night)
		}
	}

	@IBAction func enabledSwitchSwitched(_ sender: KSwitch) {
		UserSettings.set(sender.isOn, forKey: .largeTitlesEnabled)
		NotificationCenter.default.post(name: .KSPrefersLargeTitlesDidChange, object: nil)
	}
}
