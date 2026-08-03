//
//  MotionSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

class MotionSettingsViewController: SubSettingsViewController, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case motionOptionsSegue
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.circleDottedCircle
		self.headerTitle = L10n.motion
		self.headerDescription = L10n.motionHeaderDescription
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
			let indexPath = IndexPath(row: rowIndex, section: section.rawValue + self.headerSectionOffset)
			guard let reduceMotionSyncSwitchSettingsCell = self.tableView.cellForRow(at: indexPath) as? SwitchSettingsCell else { return }

			self.switchTapped(reduceMotionSyncSwitchSettingsCell.toggleSwitch)
		}

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
				let indexPath = IndexPath(row: rowIndex, section: section.rawValue + self.headerSectionOffset)
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
			let indexPath = IndexPath(row: rowIndex, section: section.rawValue + self.headerSectionOffset)

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
		return super.registerCells(for: tableView) + [
			SwitchSettingsCell.self,
			SettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension MotionSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Motion.Section.allCases.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let contentSection = self.contentSection(for: section) else { return 1 }
		return Motion.Section.allCases[contentSection].rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		guard let contentSection = self.contentSection(for: indexPath.section) else { return UITableViewCell() }
		let section = Motion.Section.allCases[contentSection]

		switch section {
		case .animations:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			let currentSplashScreenAnimation = UserSettings.currentSplashScreenAnimation

			cell.configure(title: L10n.splashScreen, detail: currentSplashScreenAnimation.titleValue)
			return cell
		case .reduceMotion:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			let row = section.rows[indexPath.row]

			switch row {
			case .splashScreen: break
			case .toggleReduceMotion:
				self.configureSwitchCell(cell, title: L10n.reduceMotion, isOn: UserSettings.isReduceMotionEnabled, tag: .toggleReduceMotion)
			case .toggleReduceMotionSync:
				self.configureSwitchCell(cell, title: L10n.syncWithDeviceSettings, isOn: UserSettings.isReduceMotionSyncEnabled, tag: .toggleReduceMotionSync)
			}

			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section),
			  let section = Motion.Section(rawValue: contentSection) else { return nil }

		switch section {
		case .animations:
			return L10n.animations
		case .reduceMotion:
			return L10n.reduceMotion
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section),
			  let section = Motion.Section(rawValue: contentSection) else { return nil }

		switch section {
		case .animations:
			return nil
		case .reduceMotion:
			return L10n.reduceMotionFooter
		}
	}
}

// MARK: - UITableViewDelegate
extension MotionSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = Motion.Section(rawValue: contentSection),
			let row = section.rows[safe: indexPath.row]
		else { return }

		switch row {
		case .splashScreen:
			self.show(.motionOptionsSegue, sender: nil)
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
