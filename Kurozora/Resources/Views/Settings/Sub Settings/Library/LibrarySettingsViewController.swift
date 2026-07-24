//
//  LibrarySettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/04/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit
import UIKit

class LibrarySettingsViewController: SubSettingsViewController {
	// MARK: - Properties
	private var libraryKind: LibraryKind = UserSettings.libraryKind

	/// The most recent library sync timestamp for the signed-in user.
	private var lastSyncDate: Date?

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.headerImage = .Icons.library
		self.headerTitle = L10n.library
		self.headerDescription = L10n.libraryHeaderDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.cellLayoutMarginsFollowReadableWidth = true

		self.refreshLastSyncDate()
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleLibrarySyncProgressDidChange), name: .KLibrarySyncProgressDidChange, object: nil)
	}

	// MARK: - Sync
	/// Fetches the most recent sync timestamp across all library kinds for the given user.
	private func fetchLastSyncDate(forUserSlug userSlug: String) -> Date? {
		let fetchRequest = LocalSyncCursor.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "userSlug == %@ AND syncedAt != nil", userSlug)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "syncedAt", ascending: false)]
		fetchRequest.fetchLimit = 1
		return try? PersistenceController.shared.viewContext.fetch(fetchRequest).first?.syncedAt
	}

	/// Refreshes the cached last sync date.
	private func refreshLastSyncDate() {
		guard let userSlug = User.current?.attributes.slug else {
			self.lastSyncDate = nil
			return
		}
		self.lastSyncDate = self.fetchLastSyncDate(forUserSlug: userSlug)
	}

	/// Returns a sentence describing how recently the library synced.
	private func lastSyncSentence(for lastSyncDate: Date?) -> String {
		guard let lastSyncDate else { return L10n.neverSynced }

		let elapsedMinutes = Int(Date().timeIntervalSince(lastSyncDate) / 60)

		if elapsedMinutes < 10 {
			return L10n.syncedJustNow
		} else if elapsedMinutes < 60 {
			return L10n.lastSyncedMinutesAgo(elapsedMinutes)
		} else if elapsedMinutes < 60 * 24 {
			return L10n.lastSyncedHoursAgo(elapsedMinutes / 60)
		} else {
			return L10n.lastSyncedOnDate(lastSyncDate.appFormatted(date: .abbreviated, time: .omitted))
		}
	}

	/// Reloads the sync section's rows.
	private func reloadSyncSection() {
		self.tableView.reloadSections(IndexSet([Section.sync.rawValue + self.headerSectionOffset]), with: .none)
	}

	/// Refreshes the sync section when sync progress changes.
	@objc private func handleLibrarySyncProgressDidChange() {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			self.refreshLastSyncDate()
			self.reloadSyncSection()
		}
	}

	/// Starts a library sync for the current user.
	private func syncNow() {
		guard !LibrarySyncProgress.shared.isSyncing else { return }

		Task { [weak self] in
			guard let self = self else { return }
			guard await WorkflowController.shared.isSignedIn(on: self) else { return }
			guard let userSlug = User.current?.attributes.slug else { return }
			await LibrarySyncEngine.shared.syncAll(forUserSlug: userSlug)
		}
	}

	private func statusTitle(for status: LibraryStatus) -> String {
		switch status {
		case .inProgress:
			switch self.libraryKind {
			case .games:
				return status.gameStringValue
			case .literatures:
				return status.literatureStringValue
			case .shows:
				return status.showStringValue
			}
		case .none,
		     .planning,
		     .completed,
		     .dropped,
		     .onHold,
		     .interested,
		     .ignored:
			return status.stringValue
		}
	}

	private func configureSortTypeButton(_ button: UIButton, status: LibraryStatus) {
		button.titleLabel?.numberOfLines = 0
		button.contentHorizontalAlignment = .trailing
		button.showsMenuAsPrimaryAction = true
		button.changesSelectionAsPrimaryAction = true
		self.populateSortActions(button, status: status)
	}

	private func saveSettings(_ dict: [Int: [Int: (Int, Int)]]) {
		let encoder = PropertyListEncoder()

		var rawDict: [Int: [Int: Int]] = [:]
		for (kind, statusMap) in dict {
			var encodedStatusMap: [Int: Int] = [:]

			for (status, (sortType, option)) in statusMap {
				let encoded = (sortType << 8) | option
				encodedStatusMap[status] = encoded
			}

			rawDict[kind] = encodedStatusMap
		}

		if let data = try? encoder.encode(rawDict) {
			UserSettings.set(data, forKey: .librarySortTypes)
		}
	}

	/// Builds and presents the sort types in an action sheet.
	fileprivate func populateSortActions(_ button: UIButton, status: LibraryStatus) {
		var menuItems: [UIMenuElement] = []

		let kind = self.libraryKind
		let currentSortTypeAndOption = UserSettings.librarySortTypes[kind]?[status]

		// Create default action
		let defaultSortingAction = UIAction(title: L10n.default) { [weak self] _ in
			guard let self = self else { return }

			var updated = UserSettings.librarySortTypes
			var statusDict = updated[kind] ?? [:]
			statusDict[status] = (.none, .none)
			updated[kind] = statusDict

			let converted: [Int: [Int: (Int, Int)]] = updated.reduce(into: [:]) { result, pair in
				let (kindKey, statusMap) = pair
				let kindRaw = kindKey.rawValue

				result[kindRaw] = statusMap.reduce(into: [:]) { statusResult, statusPair in
					let (statusKey, tuple) = statusPair
					statusResult[statusKey.rawValue] = (tuple.sortType.rawValue, tuple.sortOption.rawValue)
				}
			}

			self.saveSettings(converted)
		}

		let defaultSortingMenu = UIMenu(title: "", options: .displayInline, children: [defaultSortingAction])
		menuItems.append(defaultSortingMenu)

		// Create sorting action
		LibrarySortType.all.forEach { [weak self] sortType in
			guard let self = self else { return }
			var subMenuItems: [UIAction] = []
			let sortTypeSelected = currentSortTypeAndOption?.sortType == sortType

			for option in sortType.optionValue {
				let sortOptionSelected = currentSortTypeAndOption?.sortOption == option
				let actionIsOn = sortTypeSelected && sortOptionSelected

				let action = UIAction(title: option.stringValue, image: option.imageValue, state: actionIsOn ? .on : .off) { _ in
					var updated = UserSettings.librarySortTypes
					var statusDict = updated[kind] ?? [:]
					statusDict[status] = (sortType, option)
					updated[kind] = statusDict

					let converted: [Int: [Int: (Int, Int)]] = updated.reduce(into: [:]) { result, pair in
						let (kindKey, statusMap) = pair
						let kindRaw = kindKey.rawValue

						result[kindRaw] = statusMap.reduce(into: [:]) { statusResult, statusPair in
							let (statusKey, tuple) = statusPair
							statusResult[statusKey.rawValue] = (tuple.sortType.rawValue, tuple.sortOption.rawValue)
						}
					}

					self.saveSettings(converted)
				}

				subMenuItems.append(action)
			}

			let submenu = UIMenu(title: sortType.stringValue, image: sortType.imageValue, children: subMenuItems)
			menuItems.append(submenu)
		}

		button.menu = UIMenu(title: "", children: menuItems)
	}

	@objc private func libraryKindSegmentedControlDidChange(_ sender: UISegmentedControl) {
		guard let libraryKind = LibraryKind(rawValue: sender.selectedSegmentIndex) else { return }
		self.libraryKind = libraryKind

		self.tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension LibrarySettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			SettingsCell.self,
			SegmentedControlSettingsCell.self,
			MenuSettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension LibrarySettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count + self.headerSectionOffset
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let contentSection = self.contentSection(for: section),
			  let section = Section(rawValue: contentSection) else { return 1 }
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
		case .lastSyncDate:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			cell.configure(title: self.lastSyncSentence(for: self.lastSyncDate))
			cell.primaryLabel?.theme_textColor = KThemePicker.textColor.rawValue
			cell.chevronImageView?.isHidden = true
			cell.contentView.alpha = 1.0
			return cell
		case .syncNow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SettingsCell.reuseID)")
			}
			let isSyncing = LibrarySyncProgress.shared.isSyncing
			cell.configure(title: L10n.syncNow, detail: isSyncing ? L10n.syncingNow : nil)
			cell.primaryLabel?.theme_textColor = KThemePicker.tintColor.rawValue
			cell.chevronImageView?.isHidden = true
			cell.contentView.alpha = isSyncing ? 0.5 : 1.0
			return cell
		case .libraryKind:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(SegmentedControlSettingsCell.reuseID)")
			}
			let action = UIAction { [weak self] action in
				guard
					let self = self,
					let segmentedControl = action.sender as? UISegmentedControl
				else { return }
				self.libraryKindSegmentedControlDidChange(segmentedControl)
			}
			cell.configure(title: L10n.libraryType, segmentTitles: LibraryKind.allString, selectedSegmentIndex: self.libraryKind.rawValue, action: action)
			return cell
		case .status(let status):
			guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuSettingsCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(MenuSettingsCell.reuseID)")
			}
			cell.configure(title: self.statusTitle(for: status))
			self.configureSortTypeButton(cell.menuActionButton, status: status)
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section),
			  let section = Section(rawValue: contentSection) else { return nil }

		switch section {
		case .sync:
			return L10n.sync
		case .sorting:
			return L10n.defaultSorting
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard let contentSection = self.contentSection(for: section),
			  let section = Section(rawValue: contentSection) else { return nil }

		switch section {
		case .sync:
			return L10n.librarySyncFooterMessage
		case .sorting:
			return nil
		}
	}
}

// MARK: - UITableViewDelegate
extension LibrarySettingsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard
			let contentSection = self.contentSection(for: indexPath.section),
			let section = Section(rawValue: contentSection),
			let row = section.rows[safe: indexPath.row]
		else { return }

		switch row {
		case .lastSyncDate, .libraryKind, .status:
			return
		case .syncNow:
			self.syncNow()
		}
	}
}

// MARK: - Sections and Rows
private extension LibrarySettingsViewController {
	enum Section: Int, CaseIterable {
		case sync = 0
		case sorting = 1

		var rows: [Row] {
			switch self {
			case .sync:
				return [.lastSyncDate, .syncNow]
			case .sorting:
				return [
					.libraryKind,
					.status(.inProgress),
					.status(.planning),
					.status(.completed),
					.status(.onHold),
					.status(.dropped),
					.status(.interested),
					.status(.ignored)
				]
			}
		}
	}

	enum Row {
		case lastSyncDate
		case syncNow
		case libraryKind
		case status(LibraryStatus)
	}
}
