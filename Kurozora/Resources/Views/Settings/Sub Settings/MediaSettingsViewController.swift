//
//  MediaSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

class MediaSettingsViewController: SubSettingsViewController {
	// MARK: - Properties
	/// The sections shown in the settings.
	private var sections: [Section] {
		return MediaSaveDestination.current == .photoLibrary ? Section.allCases : [.saveLocation, .liveText]
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.photoStack
		self.headerTitle = L10n.media
		self.headerDescription = L10n.mediaHeaderDescription
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

	// MARK: - Functions
	private func configureSwitchCell(_ cell: SwitchSettingsCell, row: Row, isOn: Bool) {
		cell.configure(title: row.titleValue, isOn: isOn, tag: row.tag, action: UIAction { [weak self] action in
			guard
				let self = self,
				let toggle = action.sender as? KSwitch
			else { return }

			self.switchTapped(toggle)
		})
	}

	/// Returns the menu offering every place saved images can be written to.
	private func makeLocationMenu() -> UIMenu {
		let actions = MediaSaveDestination.allCases.map { destination in
			UIAction(title: destination.titleValue, state: destination == MediaSaveDestination.current ? .on : .off) { [weak self] _ in
				UserSettings.set(destination.rawValue, forKey: .mediaSaveDestination)
				self?.tableView.reloadData()
			}
		}

		return UIMenu(options: .singleSelection, children: actions)
	}

	/// Lets the user pick the folder saved images are written to.
	private func chooseFolder() {
		let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
		documentPicker.delegate = self
		documentPicker.allowsMultipleSelection = false

		self.present(documentPicker, animated: true)
	}

	// MARK: - Actions
	@objc private func switchTapped(_ sender: KSwitch) {
		guard let row = Row(tag: sender.tag) else { return }

		switch row {
		case .saveToKurozoraAlbum:
			UserSettings.set(sender.isOn, forKey: .mediaSaveToKurozoraAlbum)
		case .liveTextAnalyzer:
			UserSettings.set(sender.isOn, forKey: .liveTextAnalyzerEnabled)
		default:
			break
		}
	}
}

// MARK: - KTableViewDataSource
extension MediaSettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			SettingsCell.self,
			MenuSettingsCell.self,
			SwitchSettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension MediaSettingsViewController {
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
		case .location:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuSettingsCell.self, for: indexPath) else {
				return UITableViewCell()
			}

			cell.configure(title: row.titleValue, buttonTitle: MediaSaveDestination.current.titleValue)
			cell.menuActionButton.menu = self.makeLocationMenu()
			return cell
		case .chooseFolder:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				return UITableViewCell()
			}

			cell.configure(title: row.titleValue, detail: row.detailValue, isEnabled: row.isEnabled)
			cell.chevronImageView?.isHidden = true
			return cell
		case .saveToKurozoraAlbum:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				return UITableViewCell()
			}

			self.configureSwitchCell(cell, row: row, isOn: UserSettings.mediaSaveToKurozoraAlbum)
			return cell
		case .liveTextAnalyzer:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchSettingsCell.self, for: indexPath) else {
				return UITableViewCell()
			}

			self.configureSwitchCell(cell, row: row, isOn: UserSettings.liveTextAnalyzerEnabled)
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard
			let contentSection = self.contentSection(for: section),
			let section = self.sections[safe: contentSection]
		else { return nil }

		return section.titleValue
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard
			let contentSection = self.contentSection(for: section),
			let section = self.sections[safe: contentSection]
		else { return nil }

		return section.footerValue
	}
}

// MARK: - UITableViewDelegate
extension MediaSettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = self.sections[safe: contentSection],
			let row = section.rows[safe: indexPath.row],
			row.isEnabled
		else { return }

		tableView.deselectRow(at: indexPath, animated: true)

		switch row {
		case .chooseFolder:
			self.chooseFolder()
		default:
			break
		}
	}
}

// MARK: - UIDocumentPickerDelegate
extension MediaSettingsViewController: UIDocumentPickerDelegate {
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let directory = urls.first else { return }

		let isAccessing = directory.startAccessingSecurityScopedResource()
		defer {
			if isAccessing {
				directory.stopAccessingSecurityScopedResource()
			}
		}

		#if targetEnvironment(macCatalyst)
		let options: URL.BookmarkCreationOptions = [.withSecurityScope]
		#else
		let options: URL.BookmarkCreationOptions = [.minimalBookmark]
		#endif

		guard let bookmark = try? directory.bookmarkData(options: options) else { return }

		UserSettings.set(bookmark, forKey: .mediaSaveDirectoryBookmark)
		UserSettings.set(MediaSaveDestination.folder.rawValue, forKey: .mediaSaveDestination)

		self.tableView.reloadData()
	}
}

// MARK: - Sections and Rows
private extension MediaSettingsViewController {
	enum Section: CaseIterable {
		case saveLocation
		case kurozoraAlbum
		case liveText

		var rows: [Row] {
			switch self {
			case .saveLocation:
				return [.location, .chooseFolder]
			case .kurozoraAlbum:
				return [.saveToKurozoraAlbum]
			case .liveText:
				return [.liveTextAnalyzer]
			}
		}

		var titleValue: String? {
			switch self {
			case .saveLocation:
				return L10n.saveLocation
			case .kurozoraAlbum, .liveText:
				return nil
			}
		}

		var footerValue: String? {
			switch self {
			case .saveLocation:
				return nil
			case .kurozoraAlbum:
				return L10n.saveToKurozoraAlbumFooter
			case .liveText:
				return L10n.liveTextAnalyzerFooter
			}
		}
	}

	enum Row {
		case location
		case chooseFolder
		case saveToKurozoraAlbum
		case liveTextAnalyzer

		init?(tag: Int) {
			switch tag {
			case 0: self = .saveToKurozoraAlbum
			case 1: self = .liveTextAnalyzer
			default: return nil
			}
		}

		var tag: Int {
			switch self {
			case .saveToKurozoraAlbum:
				return 0
			case .liveTextAnalyzer:
				return 1
			case .location, .chooseFolder:
				return -1
			}
		}

		var titleValue: String {
			switch self {
			case .location:
				return L10n.location
			case .chooseFolder:
				return L10n.chooseFolder
			case .saveToKurozoraAlbum:
				return L10n.saveToKurozoraAlbum
			case .liveTextAnalyzer:
				return L10n.liveTextAnalyzer
			}
		}

		var detailValue: String? {
			switch self {
			case .chooseFolder:
				return MediaSaveDestination.chosenDirectory?.abbreviatedPath
			default:
				return nil
			}
		}

		var isEnabled: Bool {
			switch self {
			case .chooseFolder:
				return MediaSaveDestination.current == .folder
			default:
				return true
			}
		}
	}
}
