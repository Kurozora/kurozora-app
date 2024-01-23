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
	@IBOutlet weak var startupSoundSwitch: KSwitch!
	@IBOutlet weak var uiSoundsSwitch: KSwitch!

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.selectedChimeLabel.text = UserSettings.selectedChime
		self.startupSoundSwitch.isOn = UserSettings.startupSoundAllowed
		self.uiSoundsSwitch.isOn = UserSettings.uiSoundsAllowed
	}

	// MARK: - IBActions
	@IBAction func switchTapped(_ sender: KSwitch) {
		guard let switchType = Sound.Row(rawValue: sender.tag) else { return }
		let isOn = sender.isOn

		switch switchType {
		case .selectChime: break
		case .toggleChime:
			UserSettings.set(isOn, forKey: .startupSoundAllowed)
		case .toggleUISounds:
			UserSettings.set(isOn, forKey: .uiSoundsAllowed)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let soundOptionsViewController = segue.destination as? SoundOptionsViewController {
			soundOptionsViewController.title = Trans.chimeSound
			soundOptionsViewController.delegate = self
		}
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
}
