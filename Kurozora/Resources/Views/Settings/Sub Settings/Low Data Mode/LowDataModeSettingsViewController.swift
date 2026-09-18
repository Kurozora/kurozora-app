//
//  LowDataModeSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

class LowDataModeSettingsViewController: SubSettingsViewController, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case autoplaySegue
		case wifiQualitySegue
		case cellularQualitySegue
	}

	// MARK: - Properties
	/// The sections shown in the settings.
	private var sections: [Section] {
		return Section.allCases
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.wifiExclamationmark
		self.headerTitle = L10n.lowDataMode
		self.headerDescription = L10n.lowDataModeHeaderDescription
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

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .autoplaySegue:
			return self.makeAutoplayPicker()
		case .wifiQualitySegue:
			return self.makeVideoQualityPicker(isCellular: false)
		case .cellularQualitySegue:
			return self.makeVideoQualityPicker(isCellular: true)
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) { }

	// MARK: - Functions
	/// Returns the picker for the autoplay policy.
	///
	/// - Returns: The picker for the autoplay policy.
	private func makeAutoplayPicker() -> SettingsPickerTableViewController {
		let policies: [VideoAutoplayPolicy] = [.wifiAndCellular, .wifiOnly, .never]
		let picker = SettingsPickerTableViewController(
			items: SettingsPickerTableViewController.items(for: policies) { $0.titleValue },
			selectedKey: String(UserSettings.videoAutoplayPolicy.rawValue),
			footerText: L10n.autoplayFooter
		)
		picker.title = L10n.autoplay
		picker.selectionHandler = { key in
			guard let rawValue = Int(key) else { return }
			UserSettings.set(rawValue, forKey: .videoAutoplayPolicy)
		}
		return picker
	}

	/// Returns the picker for the given network's video quality.
	///
	/// - Parameter isCellular: Whether the picker sets the cellular quality.
	///
	/// - Returns: The picker for the given network's video quality.
	private func makeVideoQualityPicker(isCellular: Bool) -> SettingsPickerTableViewController {
		let chosenQuality = isCellular ? UserSettings.cellularVideoQuality : UserSettings.wifiVideoQuality
		let picker = SettingsPickerTableViewController(
			items: SettingsPickerTableViewController.items(for: VideoQuality.allCases) { $0.titleValue },
			selectedKey: String(chosenQuality.rawValue),
			footerText: L10n.videoQualityFooter
		)
		picker.title = isCellular ? L10n.cellularQuality : L10n.wifiQuality
		picker.selectionHandler = { key in
			guard let rawValue = Int(key) else { return }
			UserSettings.set(rawValue, forKey: isCellular ? .cellularVideoQuality : .wifiVideoQuality)
		}
		return picker
	}
}

// MARK: - KTableViewDataSource
extension LowDataModeSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [SettingsCell.self, SwitchSettingsCell.self]
	}
}

// MARK: - UITableViewDataSource
extension LowDataModeSettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.sections.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard
			let contentSection = self.contentSection(for: section),
			let section = self.sections[safe: contentSection]
		else { return 1 }
		return section.rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let headerCell = self.settingsHeaderCell(for: tableView, at: indexPath) {
			return headerCell
		}

		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = self.sections[safe: contentSection],
			let row = section.rows[safe: indexPath.row]
		else {
			return UITableViewCell()
		}

		switch row {
		case .libraryArtWiFiOnly:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				return UITableViewCell()
			}

			cell.configure(title: row.title, isOn: UserSettings.libraryArtWiFiOnly, tag: 0, action: UIAction { action in
				guard let sender = action.sender as? KSwitch else { return }
				UserSettings.set(sender.isOn, forKey: .libraryArtWiFiOnly)
			})
			return cell
		case .autoplay, .wifiQuality, .cellularQuality:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				return UITableViewCell()
			}

			cell.configure(title: row.title, detail: row.detail)
			cell.detailLabel?.isHidden = false
			cell.chevronImageView?.isHidden = false
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard
			let contentSection = self.contentSection(for: section),
			let section = self.sections[safe: contentSection]
		else { return nil }
		return section.footer
	}
}

// MARK: - UITableViewDelegate
extension LowDataModeSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = self.sections[safe: contentSection],
			let row = section.rows[safe: indexPath.row],
			let segueIdentifier = row.segueIdentifier
		else { return }

		self.show(segueIdentifier, sender: nil)
	}
}

// MARK: - Sections and Rows
private extension LowDataModeSettingsViewController {
	enum Section: Int, CaseIterable {
		case media = 0
		case library = 1

		var rows: [Row] {
			switch self {
			case .media:
				return [.autoplay, .wifiQuality, .cellularQuality]
			case .library:
				return [.libraryArtWiFiOnly]
			}
		}

		var footer: String? {
			switch self {
			case .media:
				return nil
			case .library:
				return L10n.libraryArtworkFooterMessage
			}
		}
	}

	enum Row {
		case autoplay
		case wifiQuality
		case cellularQuality
		case libraryArtWiFiOnly

		var title: String {
			switch self {
			case .autoplay:
				return L10n.autoplay
			case .wifiQuality:
				return L10n.wifiQuality
			case .cellularQuality:
				return L10n.cellularQuality
			case .libraryArtWiFiOnly:
				return L10n.libraryArtwork
			}
		}

		var detail: String {
			switch self {
			case .autoplay:
				return UserSettings.videoAutoplayPolicy.titleValue
			case .wifiQuality:
				return UserSettings.wifiVideoQuality.titleValue
			case .cellularQuality:
				return UserSettings.cellularVideoQuality.titleValue
			case .libraryArtWiFiOnly:
				return ""
			}
		}

		var segueIdentifier: LowDataModeSettingsViewController.SegueIdentifiers? {
			switch self {
			case .autoplay:
				return .autoplaySegue
			case .wifiQuality:
				return .wifiQualitySegue
			case .cellularQuality:
				return .cellularQualitySegue
			case .libraryArtWiFiOnly:
				return nil
			}
		}
	}
}
