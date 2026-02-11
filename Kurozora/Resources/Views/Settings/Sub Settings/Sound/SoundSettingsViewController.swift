//
//  SoundSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/12/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class SoundSettingsViewController: SubSettingsViewController {
	// MARK: - Segue Identifiers
	enum SegueIdentifiers: String, SegueIdentifier {
		case soundOptionsSegue
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
		#if targetEnvironment(macCatalyst)
		self.title = Trans.sound
		#else
		self.title = Trans.soundsAndHaptics
		#endif

		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	private func configureSwitchCell(_ cell: SwitchSettingsCell, title: String, isOn: Bool, tag: Sound.Row) {
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
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .soundOptionsSegue:
			return SoundOptionsViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .soundOptionsSegue:
			guard let soundOptionsViewController = destination as? SoundOptionsViewController else { return }
			soundOptionsViewController.delegate = self
		}
	}
}

// MARK: - KTableViewDataSource
extension SoundSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			SwitchSettingsCell.self,
			SettingsCell.self
		]
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

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Sound.Row.settingsCases[indexPath.row] {
		case .selectChime:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}

			cell.configure(title: Trans.chimeSound, detail: UserSettings.selectedChime)
			return cell
		case .toggleChime:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: Trans.chimeOnStartup, isOn: UserSettings.startupSoundAllowed, tag: .toggleChime)
			return cell
		case .toggleUISounds:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: Trans.uiSounds, isOn: UserSettings.uiSoundsAllowed, tag: .toggleUISounds)
			return cell
		case .toggleHaptics:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: Trans.haptics, isOn: UserSettings.hapticsAllowed, tag: .toggleHaptics)
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Sound.Section.allCases[section] {
		case .main:
			return Trans.chimeAndSoundEffects
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch Sound.Section.allCases[section] {
		case .main:
			return Sound.Row.settingsCases.contains(.toggleHaptics) ? Trans.hapticsFooter : nil
		}
	}
}

// MARK: - UITableViewDelegate
extension SoundSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch Sound.Row.settingsCases[indexPath.section] {
		case .selectChime:
			let optionsViewController = SoundOptionsViewController()
			self.show(optionsViewController, sender: nil)
		case .toggleChime, .toggleUISounds, .toggleHaptics:
			break
		}
	}
}

// MARK: - SoundOptionsViewControllerDelegate
extension SoundSettingsViewController: SoundOptionsViewControllerDelegate {
	func soundOptionsViewController(_ vc: SoundOptionsViewController, didChangeChimeTo chime: AppChimeElement) {
		self.tableView.reloadData()
	}
}
