//
//  SoundSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/12/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class SoundSettingsViewController: SubSettingsViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var selectedChimeLabel: KSecondaryLabel!
	@IBOutlet weak var hapticsSwitch: KSwitch!
	@IBOutlet weak var startupSoundSwitch: KSwitch!
	@IBOutlet weak var uiSoundsSwitch: KSwitch!

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		#if targetEnvironment(macCatalyst)
		self.title = Trans.sound
		#else
		self.title = Trans.soundsAndHaptics
		#endif

		self.selectedChimeLabel.text = UserSettings.selectedChime
		self.startupSoundSwitch.isOn = UserSettings.startupSoundAllowed
		self.uiSoundsSwitch.isOn = UserSettings.uiSoundsAllowed
		self.hapticsSwitch.isOn = UserSettings.hapticsAllowed
	}

	// MARK: - IBActions
	@IBAction func switchTapped(_ sender: KSwitch) {
		let switchType = Sound.Row.settingsCases[sender.tag]
		let isOn = sender.isOn

		switch switchType {
		case .selectChime: break
		case .toggleChime:
			UserSettings.set(isOn, forKey: .startupSoundAllowed)
		case .toggleUISounds:
			UserSettings.set(isOn, forKey: .uiSoundsAllowed)
		case .toggleHaptics:
			UserSettings.set(isOn, forKey: .hapticsAllowed)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let soundOptionsViewController = segue.destination as? SoundOptionsViewController else { return }
		soundOptionsViewController.delegate = self
	}
}

extension SoundSettingsViewController: SoundOptionsViewControllerDelegate {
	func soundOptionsViewController(_ vc: SoundOptionsViewController, didChangeChimeTo chime: AppChimeElement) {
		self.selectedChimeLabel.text = chime.name
	}
}

// MARK: - UITableViewDataSource
extension SoundSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Sound.Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Sound.Row.settingsCases.count
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return Sound.Row.settingsCases.contains(.toggleHaptics) ? Trans.hapticsFooter : nil
	}
}
