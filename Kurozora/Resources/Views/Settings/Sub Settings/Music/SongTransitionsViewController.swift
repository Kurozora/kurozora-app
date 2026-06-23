//
//  SongTransitionsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class SongTransitionsViewController: SubSettingsViewController {
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

		self.title = L10n.songTransitions
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	// MARK: - Functions
	private func transitionsSwitchTapped(_ sender: KSwitch) {
		UserSettings.set(sender.isOn, forKey: .musicCrossfadeEnabled)
		self.tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension SongTransitionsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			SwitchSettingsCell.self,
			SliderSettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension SongTransitionsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return UserSettings.musicCrossfadeEnabled ? Section.allCases.count : 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }

		switch section {
		case .transitions:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			cell.configure(title: L10n.songTransitions, isOn: UserSettings.musicCrossfadeEnabled, tag: 0, action: UIAction { [weak self] action in
				guard let sender = action.sender as? KSwitch else { return }
				self?.transitionsSwitchTapped(sender)
			})
			return cell
		case .duration:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SliderSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SliderSettingsCell.reuseID)")
			}
			let duration = UserSettings.musicCrossfadeDuration
			cell.configure(
				minimumValue: CrossfadeDuration.minimumSeconds,
				maximumValue: CrossfadeDuration.maximumSeconds,
				value: duration.rawValue,
				valueFormat: { L10n.secondsCount($0) }
			) { value in
				UserSettings.set(value, forKey: .musicCrossfadeDuration)
			}
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Section(rawValue: section) {
		case .duration:
			return L10n.crossfadeDuration
		default:
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch Section(rawValue: section) {
		case .transitions:
			return L10n.songTransitionsDescription
		case .duration:
			return L10n.crossfadeDescription
		default:
			return nil
		}
	}
}

// MARK: - Sections
private extension SongTransitionsViewController {
	enum Section: Int, CaseIterable {
		case transitions = 0
		case duration
	}
}
