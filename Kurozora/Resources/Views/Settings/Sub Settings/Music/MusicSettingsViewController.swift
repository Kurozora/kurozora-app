//
//  MusicSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit
import UserNotifications

class MusicSettingsViewController: SubSettingsViewController, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case songTransitionsSegue
		case skipDurationSegue
		case largerTextSegue
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.music
		self.headerTitle = L10n.music
		self.headerDescription = L10n.musicHeaderDescription
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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.tableView.reloadData()
	}

	// MARK: - Functions
	private func notificationSwitchTapped(_ sender: KSwitch) {
		UserSettings.set(sender.isOn, forKey: .musicSongChangeNotificationsEnabled)

		guard sender.isOn else { return }
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .songTransitionsSegue: return SongTransitionsViewController()
		case .skipDurationSegue: return SkipDurationSettingsViewController()
		case .largerTextSegue: return LargerTextSettingsViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) { }
}

// MARK: - KTableViewDataSource
extension MusicSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			SwitchSettingsCell.self,
			SettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension MusicSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard
			let contentSection = self.contentSection(for: section),
			let section = Section(rawValue: contentSection)
		else { return 1 }
		return section.rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = Section(rawValue: contentSection),
			let row = section.rows[safe: indexPath.row]
		else {
			return UITableViewCell()
		}

		switch row {
		case .songChangeNotifications:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			cell.configure(title: L10n.whenSongChanges, isOn: UserSettings.musicSongChangeNotificationsEnabled, tag: 0, action: UIAction { [weak self] action in
				guard let sender = action.sender as? KSwitch else { return }
				self?.notificationSwitchTapped(sender)
			})
			return cell
		default:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			cell.configure(title: row.title, detail: row.detail)
			cell.detailLabel?.isHidden = false
			cell.chevronImageView?.isHidden = false
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard
			let contentSection = self.contentSection(for: section),
			let section = Section(rawValue: contentSection)
		else { return nil }
		return section.header
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard
			let contentSection = self.contentSection(for: section),
			let section = Section(rawValue: contentSection)
		else { return nil }
		return section.footer
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard self.contentSection(for: section) != nil else { return .leastNormalMagnitude }
		return UITableView.automaticDimension
	}
}

// MARK: - UITableViewDelegate
extension MusicSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = Section(rawValue: contentSection),
			let row = section.rows[safe: indexPath.row],
			let segueIdentifier = row.segueIdentifier
		else { return }

		self.show(segueIdentifier, sender: nil)
	}
}

// MARK: - Sections and Rows
private extension MusicSettingsViewController {
	enum Section: Int, CaseIterable {
		case playback = 0
		case lyrics
		case notifications

		var rows: [Row] {
			switch self {
			case .playback:
				#if targetEnvironment(macCatalyst)
				return [.skipDuration]
				#else
				return [.songTransitions, .skipDuration]
				#endif
			case .lyrics:
				return [.largerText]
			case .notifications:
				return [.songChangeNotifications]
			}
		}

		var header: String? {
			switch self {
			case .playback:
				return L10n.audio
			case .lyrics:
				return L10n.lyrics
			case .notifications:
				return L10n.notifications
			}
		}

		var footer: String? {
			switch self {
			case .lyrics:
				return L10n.largerTextDescription
			default:
				return nil
			}
		}
	}

	enum Row {
		case songTransitions
		case skipDuration
		case largerText
		case songChangeNotifications

		var title: String {
			switch self {
			case .songTransitions:
				return L10n.songTransitions
			case .skipDuration:
				return L10n.skipDuration
			case .largerText:
				return L10n.largerText
			case .songChangeNotifications:
				return L10n.whenSongChanges
			}
		}

		var detail: String {
			switch self {
			case .songTransitions:
				return UserSettings.musicCrossfadeEnabled ? L10n.on : L10n.off
			case .skipDuration:
				return L10n.secondsCount(UserSettings.musicSkipDuration.rawValue)
			case .largerText:
				return UserSettings.lyricsLargerText.stringValue
			case .songChangeNotifications:
				return ""
			}
		}

		var segueIdentifier: MusicSettingsViewController.SegueIdentifiers? {
			switch self {
			case .songTransitions:
				return .songTransitionsSegue
			case .skipDuration:
				return .skipDurationSegue
			case .largerText:
				return .largerTextSegue
			case .songChangeNotifications:
				return nil
			}
		}
	}
}
