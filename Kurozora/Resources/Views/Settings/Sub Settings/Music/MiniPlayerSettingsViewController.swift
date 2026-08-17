//
//  MiniPlayerSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class MiniPlayerSettingsViewController: SubSettingsViewController {
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

		self.title = L10n.miniPlayer
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	// MARK: - Functions
	/// Reloads the table and notifies the MiniPlayer of the changed settings.
	private func settingsChanged() {
		self.tableView.reloadData()
		NotificationCenter.default.post(name: .KSMiniPlayerSettingsDidChange, object: nil)
	}

	/// Installs the single-selection chrome visibility menu on the given button.
	///
	/// - Parameter button: The button to install the menu on.
	private func configureChromeVisibilityMenu(_ button: UIButton) {
		button.showsMenuAsPrimaryAction = true
		button.menu = UIMenu(options: .singleSelection, children: MiniPlayerChromeVisibility.allCases.map { option in
			UIAction(title: option.stringValue, state: option == UserSettings.miniPlayerChromeVisibility ? .on : .off) { [weak self] _ in
				UserSettings.set(option.rawValue, forKey: .miniPlayerChromeVisibility)
				self?.settingsChanged()
			}
		})
	}
}

// MARK: - KTableViewDataSource
extension MiniPlayerSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			MenuSettingsCell.self,
			SwitchSettingsCell.self,
		]
	}
}

// MARK: - UITableViewDataSource
extension MiniPlayerSettingsViewController {
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
		case .chromeVisibility:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(MenuSettingsCell.reuseID)")
			}
			cell.configure(title: L10n.showControls, buttonTitle: UserSettings.miniPlayerChromeVisibility.stringValue)
			self.configureChromeVisibilityMenu(cell.menuActionButton)
			return cell
		default:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SwitchSettingsCell.reuseID)")
			}
			cell.configure(title: row.title, isOn: row.isOn, tag: 0, action: UIAction { [weak self] action in
				guard
					let sender = action.sender as? KSwitch,
					let settingsKey = row.settingsKey
				else { return }
				UserSettings.set(sender.isOn, forKey: settingsKey)
				self?.settingsChanged()
			})
			cell.toggleSwitch.isEnabled = row.isEnabled
			cell.primaryLabel?.alpha = row.isEnabled ? 1 : 0.5
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard
			let contentSection = self.contentSection(for: section),
			let section = Section(rawValue: contentSection)
		else { return nil }
		return section.footer
	}
}

// MARK: - Sections and Rows
private extension MiniPlayerSettingsViewController {
	enum Section: Int, CaseIterable {
		case controls = 0
		case reveal
		#if targetEnvironment(macCatalyst)
		case window
		#endif

		var rows: [Row] {
			switch self {
			case .controls:
				return [.chromeVisibility]
			case .reveal:
				return [.revealOnSongChange]
			#if targetEnvironment(macCatalyst)
			case .window:
				return [.keepOnTop, .showOnAllSpaces]
			#endif
			}
		}

		var footer: String? {
			switch self {
			case .controls:
				return L10n.showControlsDescription
			case .reveal:
				return L10n.revealOnSongChangeDescription
			#if targetEnvironment(macCatalyst)
			case .window:
				return L10n.miniPlayerWindowDescription
			#endif
			}
		}
	}

	enum Row {
		case chromeVisibility
		case revealOnSongChange
		#if targetEnvironment(macCatalyst)
		case keepOnTop
		case showOnAllSpaces
		#endif

		var title: String {
			switch self {
			case .chromeVisibility:
				return L10n.showControls
			case .revealOnSongChange:
				return L10n.revealOnSongChange
			#if targetEnvironment(macCatalyst)
			case .keepOnTop:
				return L10n.keepOnTop
			case .showOnAllSpaces:
				return L10n.showOnAllSpaces
			#endif
			}
		}

		var settingsKey: UserSettingsKey? {
			switch self {
			case .chromeVisibility:
				return nil
			case .revealOnSongChange:
				return .miniPlayerRevealsOnSongChange
			#if targetEnvironment(macCatalyst)
			case .keepOnTop:
				return .miniPlayerStaysOnTop
			case .showOnAllSpaces:
				return .miniPlayerShowsOnAllSpaces
			#endif
			}
		}

		var isOn: Bool {
			switch self {
			case .chromeVisibility:
				return false
			case .revealOnSongChange:
				return UserSettings.miniPlayerChromeVisibility != .never && UserSettings.miniPlayerRevealsOnSongChange
			#if targetEnvironment(macCatalyst)
			case .keepOnTop:
				return UserSettings.miniPlayerStaysOnTop
			case .showOnAllSpaces:
				return UserSettings.miniPlayerStaysOnTop && UserSettings.miniPlayerShowsOnAllSpaces
			#endif
			}
		}

		/// Whether the row accepts input.
		///
		/// The reveal row requires visible chrome, and the all Spaces row requires keep on top.
		var isEnabled: Bool {
			switch self {
			case .revealOnSongChange:
				return UserSettings.miniPlayerChromeVisibility != .never
			#if targetEnvironment(macCatalyst)
			case .showOnAllSpaces:
				return UserSettings.miniPlayerStaysOnTop
			#endif
			default:
				return true
			}
		}
	}
}
