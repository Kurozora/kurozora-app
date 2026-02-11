//
//  MotionSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

class MotionSettingsViewController: SubSettingsViewController {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case motionOptionsSegue
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Observe changes in the reduce motion setting
		NotificationCenter.default.addObserver(forName: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
			guard let self = self else { return }
			let section = Motion.Section.reduceMotion
			guard let rowIndex = section.rows.firstIndex(of: .toggleReduceMotionSync) else { return }
			let indexPath = IndexPath(row: rowIndex, section: section.rawValue)
			guard let reduceMotionSyncSwitchSettingsCell = self.tableView.cellForRow(at: indexPath) as? SwitchSettingsCell else { return }

			self.switchTapped(reduceMotionSyncSwitchSettingsCell.toggleSwitch)
		}

		self.title = Trans.motion

		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	private func configureSwitchCell(_ cell: SwitchSettingsCell, title: String, isOn: Bool, tag: Motion.Row) {
		cell.configure(title: title, isOn: isOn, tag: tag.rawValue, action: UIAction { [weak self] action in
			guard
				let self = self,
				let sender = action.sender as? KSwitch
			else { return }
			self.switchTapped(sender)
		})
	}

	// MARK: - Actions
	@objc private func switchTapped(_ sender: KSwitch) {
		guard let switchType = Motion.Row(rawValue: sender.tag) else { return }
		let isOn = sender.isOn

		switch switchType {
		case .splashScreen: break
		case .toggleReduceMotion:
			// Update sync setting if necessary
			if UserSettings.isReduceMotionSyncEnabled, UIAccessibility.isReduceMotionEnabled != sender.isOn {
				UserSettings.set(false, forKey: .isReduceMotionSyncEnabled)
				let section = Motion.Section.reduceMotion
				let rowIndex = section.rows.firstIndex(of: .toggleReduceMotionSync) ?? 0
				let indexPath = IndexPath(row: rowIndex, section: section.rawValue)
				guard let switchSettingsCell = self.tableView.cellForRow(at: indexPath) as? SwitchSettingsCell else {
					sender.isOn = !isOn
					return
				}
				switchSettingsCell.toggleSwitch.isOn = false
			}

			// Update reduce motion setting
			UserSettings.set(sender.isOn, forKey: .isReduceMotionEnabled)
		case .toggleReduceMotionSync:
			// Sync reduce motion switch with device settings if necessary
			let isAccessibilityReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
			let section = Motion.Section.reduceMotion
			let rowIndex = section.rows.firstIndex(of: .toggleReduceMotion) ?? 0
			let indexPath = IndexPath(row: rowIndex, section: section.rawValue)

			if let reduceMotionSwitchSettingsCell = self.tableView.cellForRow(at: indexPath) as? SwitchSettingsCell {
				if sender.isOn {
					if reduceMotionSwitchSettingsCell.toggleSwitch.isOn != isAccessibilityReduceMotionEnabled {
						reduceMotionSwitchSettingsCell.toggleSwitch.isOn = isAccessibilityReduceMotionEnabled
						UserSettings.set(isAccessibilityReduceMotionEnabled, forKey: .isReduceMotionEnabled)
					} else if !isAccessibilityReduceMotionEnabled {
						reduceMotionSwitchSettingsCell.toggleSwitch.isOn = false
						UserSettings.set(isAccessibilityReduceMotionEnabled, forKey: .isReduceMotionEnabled)
					}
				}
			}

			// Update sync setting
			UserSettings.set(sender.isOn, forKey: .isReduceMotionSyncEnabled)
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .motionOptionsSegue: return MotionOptionsViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .motionOptionsSegue:
			guard let motionOptionsViewController = destination as? MotionOptionsViewController else { return }
			motionOptionsViewController.delegate = self
		}
	}
}

// MARK: - KTableViewDataSource
extension MotionSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			SwitchSettingsCell.self,
			SettingsCell.self
		]
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

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = Motion.Section.allCases[indexPath.section]

		switch section {
		case .animations:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			let currentSplashScreenAnimation = UserSettings.currentSplashScreenAnimation

			cell.configure(title: Trans.splashScreen, detail: currentSplashScreenAnimation.titleValue)
			return cell
		case .reduceMotion:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			let row = section.rows[indexPath.row]

			switch row {
			case .splashScreen: break
			case .toggleReduceMotion:
				self.configureSwitchCell(cell, title: Trans.reduceMotion, isOn: UserSettings.isReduceMotionEnabled, tag: .toggleReduceMotion)
			case .toggleReduceMotionSync:
				self.configureSwitchCell(cell, title: Trans.syncWithDeviceSettings, isOn: UserSettings.isReduceMotionSyncEnabled, tag: .toggleReduceMotionSync)
			}

			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let section = Motion.Section(rawValue: section) else { return nil }

		switch section {
		case .animations:
			return Trans.animations
		case .reduceMotion:
			return Trans.reduceMotion
		}
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

// MARK: - UITableViewDelegate
extension MotionSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard
			let section = Motion.Section(rawValue: indexPath.section),
			let row = section.rows[safe: indexPath.row]
		else { return }

		switch row {
		case .splashScreen:
			self.show(SegueIdentifiers.motionOptionsSegue, sender: nil)
		case .toggleReduceMotion, .toggleReduceMotionSync:
			break
		}
	}
}

// MARK: - MotionOptionsViewControllerDelegate
extension MotionSettingsViewController: MotionOptionsViewControllerDelegate {
	func motionOptionsViewController(_ vc: MotionOptionsViewController, didChangeAnimationTo animation: SplashScreenAnimation) {
		self.tableView.reloadData()
	}
}
