//
//  MotionSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

class MotionSettingsViewController: SubSettingsViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var selectedSplashScreenLabel: KSecondaryLabel!
	@IBOutlet weak var reduceMotionSwitch: KSwitch!
	@IBOutlet weak var syncWithDeviceSettingsSwitch: KSwitch!

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = Trans.motion

		// Observe changes in the reduce motion setting
		NotificationCenter.default.addObserver(forName: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
			self?.configureReduceMotionSwitches()
		}

		// Configure settings
		self.selectedSplashScreenLabel.text = UserSettings.currentSplashScreenAnimation.titleValue

		self.configureReduceMotionSwitches()
	}

	// MARK: Functions
	private func configureReduceMotionSwitches() {
		self.reduceMotionSwitch.isOn = UserSettings.isReduceMotionEnabled
		self.syncWithDeviceSettingsSwitch.isOn = UserSettings.isReduceMotionSyncEnabled
	}

	// MARK: - IBActions
	@IBAction func reduceMotionSwitchTapped(_ sender: KSwitch) {
		// Update sync setting if necessary
		if UserSettings.isReduceMotionSyncEnabled, UIAccessibility.isReduceMotionEnabled != sender.isOn {
			UserSettings.set(false, forKey: .isReduceMotionSyncEnabled)
			self.syncWithDeviceSettingsSwitch.isOn = false
		}

		// Update reduce motion setting
		UserSettings.set(sender.isOn, forKey: .isReduceMotionEnabled)
	}

	@IBAction func syncWithDeviceSettingsSwitchTapped(_ sender: KSwitch) {
		// Sync reduce motion switch with device settings if necessary
		if sender.isOn {
			let isAccessibilityReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled

			if self.reduceMotionSwitch.isOn != isAccessibilityReduceMotionEnabled {
				self.reduceMotionSwitch.isOn = isAccessibilityReduceMotionEnabled
				UserSettings.set(isAccessibilityReduceMotionEnabled, forKey: .isReduceMotionEnabled)
			}
		}

		// Update sync setting
		UserSettings.set(sender.isOn, forKey: .isReduceMotionSyncEnabled)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let motionOptionsViewController = segue.destination as? MotionOptionsViewController else { return }
		motionOptionsViewController.delegate = self
	}
}

// MARK: - SoundOptionsViewControllerDelegate
extension MotionSettingsViewController: MotionOptionsViewControllerDelegate {
	func motionOptionsViewController(_ vc: MotionOptionsViewController, didChangeAnimationTo animation: SplashScreenAnimation) {
		self.selectedSplashScreenLabel.text = animation.titleValue
	}
}

// MARK: - UITableViewDataSource
extension MotionSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Motion.Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Motion.Section.allCases[section].rows.count
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let section = Motion.Section(rawValue: section) else { return nil }

		switch section {
		case .animations:
			return nil
		case .reduceMotion:
			return Trans.reduceMotionFooter
		}
	}
}
