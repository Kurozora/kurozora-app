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
	// MARK: _ IBOutlets
	@IBOutlet var libraryKindSegmentedControl: UISegmentedControl!

	@IBOutlet var inProgressLabel: KLabel!
	@IBOutlet var inProgressButton: KButton!

	@IBOutlet var planningLabel: KLabel!
	@IBOutlet var planningButton: KButton!

	@IBOutlet var completedLabel: KLabel!
	@IBOutlet var completedButton: KButton!

	@IBOutlet var onHoldLabel: KLabel!
	@IBOutlet var onHoldButton: KButton!

	@IBOutlet var droppedLabel: KLabel!
	@IBOutlet var droppedButton: KButton!

	@IBOutlet var interestedLabel: KLabel!
	@IBOutlet var interestedButton: KButton!

	@IBOutlet var ignoredLabel: KLabel!
	@IBOutlet var ignoredButton: KButton!

	// MARK: - Properties
	var libraryKind: KKLibrary.Kind = UserSettings.libraryKind

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = Trans.library

		// Configure settings
		self.libraryKindSegmentedControl.segmentTitles = KKLibrary.Kind.allString
		self.libraryKindSegmentedControl.selectedSegmentIndex = UserSettings.libraryKind.rawValue

		self.configureLabels()

		self.planningLabel.text = KKLibrary.Status.planning.stringValue
		self.completedLabel.text = KKLibrary.Status.completed.stringValue
		self.droppedLabel.text = KKLibrary.Status.dropped.stringValue
		self.onHoldLabel.text = KKLibrary.Status.onHold.stringValue
		self.interestedLabel.text = KKLibrary.Status.interested.stringValue
		self.ignoredLabel.text = KKLibrary.Status.ignored.stringValue

		self.configureButtons()
	}

	// MARK: Functions
	private func configureLabels() {
		switch self.libraryKind {
		case .games:
			self.inProgressLabel.text = KKLibrary.Status.inProgress.gameStringValue
		case .literatures:
			self.inProgressLabel.text = KKLibrary.Status.inProgress.literatureStringValue
		case .shows:
			self.inProgressLabel.text = KKLibrary.Status.inProgress.showStringValue
		}

		self.planningLabel.text = KKLibrary.Status.planning.stringValue
		self.completedLabel.text = KKLibrary.Status.completed.stringValue
		self.droppedLabel.text = KKLibrary.Status.dropped.stringValue
		self.onHoldLabel.text = KKLibrary.Status.onHold.stringValue
		self.interestedLabel.text = KKLibrary.Status.interested.stringValue
		self.ignoredLabel.text = KKLibrary.Status.ignored.stringValue
	}

	private func configureButtons() {
		self.configureSortTypeButton(self.inProgressButton, status: .inProgress)
		self.configureSortTypeButton(self.planningButton, status: .planning)
		self.configureSortTypeButton(self.completedButton, status: .completed)
		self.configureSortTypeButton(self.droppedButton, status: .dropped)
		self.configureSortTypeButton(self.onHoldButton, status: .onHold)
		self.configureSortTypeButton(self.interestedButton, status: .interested)
		self.configureSortTypeButton(self.ignoredButton, status: .ignored)
	}

	private func configureSortTypeButton(_ button: UIButton, status: KKLibrary.Status) {
		button.titleLabel?.numberOfLines = 0
		button.contentHorizontalAlignment = .trailing
		button.showsMenuAsPrimaryAction = true
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

		let selectedKindIndex = self.libraryKindSegmentedControl.selectedSegmentIndex
		guard let kind = KKLibrary.Kind(rawValue: selectedKindIndex) else { return }

		let currentSortTypAndOption = UserSettings.librarySortTypes[kind]?[status]

		// Create default action
		let defaultSortingAction = UIAction(title: "Default") { [weak self] _ in
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
			let sortTypeSelected = currentSortTypAndOption?.sortType == sortType

			for option in sortType.optionValue {
				let sortOptionSelected = currentSortTypAndOption?.sortOption == option
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

	// MARK: - IBActions
	@IBAction func libraryKindSegmentedControlDidChange(_ sender: UISegmentedControl) {
		guard let libraryKind = KKLibrary.Kind(rawValue: sender.selectedSegmentIndex) else { return }
		self.libraryKind = libraryKind

		self.configureLabels()
		self.configureButtons()
	}
}
