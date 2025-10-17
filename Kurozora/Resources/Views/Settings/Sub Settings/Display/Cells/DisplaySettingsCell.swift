//
//  DisplaySettingsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol DisplaySettingsCellDelegate: AnyObject {
	func displaySettingsCell(_ cell: DisplaySettingsCell, automaticDarkThemeEnabled: Bool)
}

class DisplaySettingsCell: SettingsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var lightOptionContainerView: UIView?
	@IBOutlet weak var lightOptionImageView: UIImageView? {
		didSet {
            self.lightOptionImageView?.image = .Settings.Display.lightOption
			self.toggleAppAppearanceOptions(!UserSettings.automaticDarkTheme)
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateAppAppearance(_:)), name: .KSAppAppearanceDidChange, object: nil)
		}
	}

	@IBOutlet weak var lightOptionSelectedImageView: UIImageView? {
		didSet {
			self.lightOptionSelectedImageView?.theme_tintColor = KThemePicker.tintColor.rawValue
			self.lightOptionSelectedImageView?.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
		}
	}

	@IBOutlet weak var lightOptionButton: UIButton?

	@IBOutlet weak var darkOptionContainerView: UIView?
	@IBOutlet weak var darkOptionImageView: UIImageView? {
		didSet {
            self.darkOptionImageView?.image = .Settings.Display.darkOption
		}
	}

	@IBOutlet weak var darkOptionSelectedImageView: UIImageView? {
		didSet {
			self.darkOptionSelectedImageView?.theme_tintColor = KThemePicker.tintColor.rawValue
			self.darkOptionSelectedImageView?.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
		}
	}

	@IBOutlet weak var darkOptionButton: UIButton?

	@IBOutlet weak var optionsValueLabel: KSecondaryLabel? {
		didSet {
			self.updateOptionsValueLabel()
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateOptionsValueLabel), name: .KSAutomaticDarkThemeDidChange, object: nil)
		}
	}

	@IBOutlet weak var enabledAutomaticDarkThemeSwitch: KSwitch? {
		didSet {
			self.enabledAutomaticDarkThemeSwitch?.isOn = UserSettings.automaticDarkTheme
			self.toggleAppAppearanceOptions(UserSettings.automaticDarkTheme)
		}
	}

	@IBOutlet weak var enabledTrueBlackSwitch: KSwitch? {
		didSet {
			self.enabledTrueBlackSwitch?.isOn = UserSettings.trueBlackEnabled
		}
	}

	@IBOutlet weak var enabledLargeTitlesSwitch: KSwitch? {
		didSet {
			self.enabledLargeTitlesSwitch?.isOn = UserSettings.largeTitlesEnabled
		}
	}

	// MARK: - Properties
	weak var delegate: DisplaySettingsCellDelegate?

	// MARK: - Functions
	@objc fileprivate func updateOptionsValueLabel() {
		if UserSettings.darkThemeOption == 0, KThemeStyle.isSolarNighttime {
			self.optionsValueLabel?.text = "Dark Until Sunrise"
		} else if UserSettings.darkThemeOption == 0, !KThemeStyle.isSolarNighttime {
			self.optionsValueLabel?.text = "Light Until Sunset"
		} else if UserSettings.darkThemeOption == 1, KThemeStyle.isCustomNighttime {
			let startDate = UserSettings.darkThemeOptionStart.convertToAMPM()
			self.optionsValueLabel?.text = "Dark Until \(startDate)"
		} else if UserSettings.darkThemeOption == 1, !KThemeStyle.isCustomNighttime {
			let endDate = UserSettings.darkThemeOptionEnd.convertToAMPM()
			self.optionsValueLabel?.text = "Light Until \(endDate)"
		} else {
			self.optionsValueLabel?.text = ""
		}
	}

	/// Updates the app's appearance with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func updateAppAppearance(_ notification: NSNotification) {
		if let option = notification.userInfo?["option"] as? Int {
			self.updateAppAppearance(with: option)
		} else if let isOn = notification.userInfo?["isOn"] as? Bool {
			self.toggleAppAppearanceOptions(!isOn)
		}
	}

	func updateAppAppearance(with option: Int) {
		guard let appAppearanceOption = AppAppearanceOption(rawValue: option) else { return }
		self.updateAppAppearanceOptions(with: appAppearanceOption)

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
			self.lightOptionSelectedImageView?.layer.borderWidth = 0
			self.darkOptionSelectedImageView?.layer.borderWidth = 2

			self.lightOptionSelectedImageView?.image = UIImage(systemName: "checkmark.circle.fill")
			self.darkOptionSelectedImageView?.image = nil
		case .dark:
			self.darkOptionSelectedImageView?.layer.borderWidth = 0
			self.lightOptionSelectedImageView?.layer.borderWidth = 2

			self.darkOptionSelectedImageView?.image = UIImage(systemName: "checkmark.circle.fill")
			self.lightOptionSelectedImageView?.image = nil
		}
	}

	func toggleAppAppearanceOptions(_ isOn: Bool) {
		self.lightOptionButton?.isUserInteractionEnabled = isOn
		self.darkOptionButton?.isUserInteractionEnabled = isOn
		if isOn {
			self.darkOptionContainerView?.alpha = 1.0
			self.lightOptionContainerView?.alpha = 1.0
		} else {
			self.darkOptionContainerView?.alpha = 0.5
			self.lightOptionContainerView?.alpha = 0.5
		}
	}

	// MARK: - IBActions
	@IBAction func appearanceOptionButtonTapped(_ sender: UIButton) {
		UserSettings.set(sender.tag, forKey: .appearanceOption)
		self.updateAppAppearance(with: sender.tag)
	}

	@IBAction func enableAutomaticDarkThemeSwitched(_ sender: KSwitch) {
		UserSettings.set(sender.isOn, forKey: .automaticDarkTheme)
		NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil, userInfo: ["isOn": sender.isOn])

		KThemeStyle.startAutomaticDarkThemeSchedule()

		self.delegate?.displaySettingsCell(self, automaticDarkThemeEnabled: sender.isOn)
	}

	@IBAction func enableTrueBlackSwitched(_ sender: KSwitch) {
		UserSettings.set(sender.isOn, forKey: .trueBlackEnabled)

		if UserSettings.currentTheme.lowercased() == "night" || UserSettings.currentTheme.lowercased() == "black" {
			KThemeStyle.switchTo(style: .night)
		}
	}

	@IBAction func enabledSwitchSwitched(_ sender: KSwitch) {
		UserSettings.set(sender.isOn, forKey: .largeTitlesEnabled)
		NotificationCenter.default.post(name: .KSPrefersLargeTitlesDidChange, object: nil)
	}
}
