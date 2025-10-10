//
//  SettingsPickerTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

#if !targetEnvironment(macCatalyst)
import IQKeyboardManagerSwift
#endif
import UIKit

protocol SettingsPickerTableViewControllerDelegate: AnyObject {
	func settingsPickerTableViewController(_ controller: SettingsPickerTableViewController, didSelectKey key: String) async
}

class SettingsPickerTableViewController: KTableViewController {
	// MARK: - Types
	struct ItemKind: Hashable {
		let key: String
		let value: String
	}

	enum Section {
		case main
	}

	// MARK: - Properties
	// Refresh control
	override var prefersRefreshControlDisabled: Bool {
		return true
	}

	// Activity indicator
	override var prefersActivityIndicatorHidden: Bool {
		return true
	}

	private var allItems: [ItemKind] = []
	private var filteredItems: [ItemKind] = []
	private var selectedKey: String?

	private lazy var searchController = KSearchController(searchResultsController: nil)

	private var dataSource: UITableViewDiffableDataSource<Section, ItemKind>!

	weak var delegate: SettingsPickerTableViewControllerDelegate?

	// MARK: - Init
	convenience init(items: [String: String], selectedKey: String? = nil) {
		self.init(style: .insetGrouped)
		self.allItems = items.map { ItemKind(key: $0.key, value: $0.value) }
			.sorted { $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedAscending }
		self.filteredItems = self.allItems
		self.selectedKey = selectedKey
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureSearchController()
		self.configureDataSource()
		self.applySnapshot(animating: false)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		#if !targetEnvironment(macCatalyst)
		IQKeyboardManager.shared.isEnabled = false
		#endif
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		#if !targetEnvironment(macCatalyst)
		IQKeyboardManager.shared.isEnabled = true
		#endif
	}

	// MARK: - Functions
	private func configureSearchController() {
		self.searchController.searchResultsUpdater = self
		self.searchController.obscuresBackgroundDuringPresentation = false
		self.searchController.searchBar.placeholder = "Search"
		navigationItem.searchController = self.searchController
		definesPresentationContext = true
	}

	// MARK: - Data
	private func applySnapshot(animating: Bool = true) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, ItemKind>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.filteredItems, toSection: .main)
		self.dataSource.apply(snapshot, animatingDifferences: animating)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension SettingsPickerTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			SelectableSettingsCell.self,
		]
	}
}

// MARK: - KCollectionViewDataSource
extension SettingsPickerTableViewController {
	func configureDataSource() {
		let selectableSettingsCellRegistration = self.getConfiguredSelectableSettingsCell()

		self.dataSource = UITableViewDiffableDataSource<Section, ItemKind>(tableView: self.tableView) { tableView, indexPath, itemKind in
			tableView.dequeueConfiguredReusableCell(using: selectableSettingsCellRegistration, for: indexPath, item: itemKind)
		}
	}

	func getConfiguredSelectableSettingsCell() -> UITableView.CellRegistration<SelectableSettingsCell, ItemKind> {
		return UITableView.CellRegistration<SelectableSettingsCell, ItemKind>(cellNib: UINib(resource: R.nib.selectableSettingsCell)) { [weak self] selectableSettingsCell, _, itemKind in
			guard let self else { return }
			selectableSettingsCell.primaryLabel?.text = itemKind.value
			selectableSettingsCell.setSelected(itemKind.key == self.selectedKey)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension SettingsPickerTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let itemKind = self.filteredItems[indexPath.item]
		self.selectedKey = itemKind.key

		var snapshot = self.dataSource.snapshot()
		snapshot.reloadSections([.main])
		self.dataSource.apply(snapshot, animatingDifferences: false)

		Task {
			await self.delegate?.settingsPickerTableViewController(self, didSelectKey: itemKind.key)
		}
	}
}

// MARK: - UISearchResultsUpdating
extension SettingsPickerTableViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let query = searchController.searchBar.text, !query.isEmpty else {
			self.filteredItems = self.allItems
			self.applySnapshot()
			return
		}

		self.filteredItems = self.allItems.filter {
			$0.value.localizedCaseInsensitiveContains(query) ||
				$0.key.localizedCaseInsensitiveContains(query)
		}

		// Simple "fuzzy" search fallback
		if self.filteredItems.isEmpty {
			self.filteredItems = self.allItems.filter { $0.value.lowercased().contains(query.lowercased().prefix(2)) }
		}

		self.applySnapshot()
	}
}
