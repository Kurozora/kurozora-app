//
//  LibrarySettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/04/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class LibrarySettingsViewController: SubSettingsViewController {
	// MARK: - Properties
	private var libraryKind: KKLibrary.Kind = UserSettings.libraryKind

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

		self.title = Trans.library

		self.configureView()
	}

	// MARK: - Functions
	private func configureView() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	private func statusTitle(for status: KKLibrary.Status) -> String {
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

	private func configureSortTypeButton(_ button: UIButton, status: KKLibrary.Status) {
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
	fileprivate func populateSortActions(_ button: UIButton, status: KKLibrary.Status) {
		var menuItems: [UIMenuElement] = []

		let kind = self.libraryKind
		let currentSortTypeAndOption = UserSettings.librarySortTypes[kind]?[status]

		// Create default action
		let defaultSortingAction = UIAction(title: Trans.default) { [weak self] _ in
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
		KKLibrary.SortType.allCases.forEach { [weak self] sortType in
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
		guard let libraryKind = KKLibrary.Kind(rawValue: sender.selectedSegmentIndex) else { return }
		self.libraryKind = libraryKind

		self.tableView.reloadData()
	}
}

// MARK: - KTableViewDataSource
extension LibrarySettingsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			SegmentedControlSettingsCell.self,
			MenuSettingsCell.self
		]
	}
}

// MARK: - UITableViewDataSource
extension LibrarySettingsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else { return 0 }
		return section.rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard
			let section = Section(rawValue: indexPath.section),
			let row = section.rows[safe: indexPath.row]
		else {
			return UITableViewCell()
		}

		switch row {
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
			cell.configure(title: Trans.libraryType, segmentTitles: KKLibrary.Kind.allString, selectedSegmentIndex: self.libraryKind.rawValue, action: action)
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
		guard let section = Section(rawValue: section) else { return nil }

		switch section {
		case .sorting:
			return Trans.sorting
		}
	}
}

// MARK: - Sections and Rows
private extension LibrarySettingsViewController {
	enum Section: Int, CaseIterable {
		case sorting = 0

		var rows: [Row] {
			switch self {
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
		case libraryKind
		case status(KKLibrary.Status)
	}
}
