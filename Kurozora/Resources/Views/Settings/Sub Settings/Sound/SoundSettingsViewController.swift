//
//  SoundSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/12/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

class SoundSettingsViewController: SubSettingsViewController, TypedSegueHandling {
	// MARK: - Segue Identifiers
	enum SegueIdentifiers: String, SegueIdentifier {
		case soundOptionsSegue
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)

		self.headerImage = .Icons.sound
		#if targetEnvironment(macCatalyst)
		self.headerTitle = L10n.sound
		#else
		self.headerTitle = L10n.soundsAndHaptics
		#endif
		self.headerDescription = L10n.soundHeaderDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

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
		return super.registerCells(for: tableView) + [
			SwitchSettingsCell.self,
			SettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension SoundSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Sound.Section.allCases.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard self.contentSection(for: section) != nil else { return 1 }
		return Sound.Row.settingsCases.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		switch Sound.Row.settingsCases[indexPath.row] {
		case .selectChime:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}

			let stored = UserSettings.selectedChime
			let firstChimeName = Chime.shared.appChimeGroups.first?.chimes.first?.first?.name
			let detail = (stored == firstChimeName) ? "Default" : stored
			cell.configure(title: L10n.chimeSound, detail: detail)
			return cell
		case .toggleChime:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: L10n.chimeOnStartup, isOn: UserSettings.startupSoundAllowed, tag: .toggleChime)
			return cell
		case .toggleUISounds:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: L10n.uiSounds, isOn: UserSettings.uiSoundsAllowed, tag: .toggleUISounds)
			return cell
		case .toggleHaptics:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			self.configureSwitchCell(cell, title: L10n.haptics, isOn: UserSettings.hapticsAllowed, tag: .toggleHaptics)
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section) else { return nil }

		switch Sound.Section.allCases[contentSection] {
		case .main:
			return L10n.chimeAndSoundEffects
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section) else { return nil }

		switch Sound.Section.allCases[contentSection] {
		case .main:
			return Sound.Row.settingsCases.contains(.toggleHaptics) ? L10n.hapticsFooter : nil
		}
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let contentSection = self.contentSection(for: section) else { return .leastNormalMagnitude }
		return super.tableView(tableView, heightForHeaderInSection: contentSection)
	}
}

// MARK: - UITableViewDelegate
extension SoundSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch Sound.Row.settingsCases[indexPath.row] {
		case .selectChime:
			self.show(.soundOptionsSegue, sender: nil)
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
