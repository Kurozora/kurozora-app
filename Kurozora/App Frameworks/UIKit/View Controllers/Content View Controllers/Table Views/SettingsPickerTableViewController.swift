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
	struct ItemKind: nonisolated Hashable {
		let key: String
		let value: String
	}

	enum Section: nonisolated Equatable, nonisolated Hashable {
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
	private var descriptionText: String?
	private var footerText: String?
	private var isSearchable = false

	private lazy var searchController = KSearchController(searchResultsController: nil)

	private var dataSource: PickerDataSource!

	weak var delegate: SettingsPickerTableViewControllerDelegate?

	/// The closure run when the user picks a row.
	var selectionHandler: ((String) async -> Void)?

	// MARK: - Init
	/// Creates a picker over an unordered set of options.
	///
	/// - Parameters:
	///    - items: The options keyed by their stored value.
	///    - selectedKey: The key of the option to check.
	///    - descriptionText: The text shown above the options.
	convenience init(items: [String: String], selectedKey: String? = nil, descriptionText: String? = nil) {
		let sortedItems = items.map { ItemKind(key: $0.key, value: $0.value) }
			.sorted { $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedAscending }
		self.init(items: sortedItems, selectedKey: selectedKey, descriptionText: descriptionText, isSearchable: true)
	}

	/// Creates a picker over an ordered list of options.
	///
	/// - Parameters:
	///    - items: The options in the order they are offered.
	///    - selectedKey: The key of the option to check.
	///    - descriptionText: The text shown above the options.
	///    - footerText: The text shown below the options.
	///    - isSearchable: Whether the picker offers a search bar.
	convenience init(items: [ItemKind], selectedKey: String? = nil, descriptionText: String? = nil, footerText: String? = nil, isSearchable: Bool = false) {
		self.init(style: .insetGrouped)
		self.allItems = items
		self.filteredItems = items
		self.selectedKey = selectedKey
		self.descriptionText = descriptionText
		self.footerText = footerText
		self.isSearchable = isSearchable
	}

	/// Returns picker rows for the given options.
	///
	/// - Parameters:
	///    - options: The options in the order they are offered.
	///    - title: The title of each option.
	///
	/// - Returns: The rows for the given options.
	static func items<Option: RawRepresentable>(for options: [Option], title: (Option) -> String) -> [ItemKind] where Option.RawValue == Int {
		return options.map { ItemKind(key: String($0.rawValue), value: title($0)) }
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.cellLayoutMarginsFollowReadableWidth = true

		self.configureSearchController()
		self.configureDescriptionHeader()
		self.configureDataSource()
		self.applySnapshot(animating: false)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			guard let self = self else { return }
			self.scrollToCurrentSelection()
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.updateDescriptionHeaderSize()
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
	private func configureDescriptionHeader() {
		guard let descriptionText = self.descriptionText, !descriptionText.isEmpty else {
			return
		}

		let descriptionLabel = KSecondaryLabel()
		descriptionLabel.numberOfLines = 0
		descriptionLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
		descriptionLabel.adjustsFontForContentSizeCategory = true
		descriptionLabel.text = descriptionText
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

		let container = UIView()
		container.backgroundColor = .clear
		container.preservesSuperviewLayoutMargins = true
		container.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 12, right: 20)
		container.addSubview(descriptionLabel)

		NSLayoutConstraint.activate([
			descriptionLabel.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
			descriptionLabel.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor),
			descriptionLabel.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
			descriptionLabel.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor)
		])

		self.tableView.tableHeaderView = container
	}

	private func updateDescriptionHeaderSize() {
		guard let headerView = self.tableView.tableHeaderView else { return }
		let width = self.tableView.bounds.width
		guard width > 0 else { return }

		let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
		let fittedSize = headerView.systemLayoutSizeFitting(
			targetSize,
			withHorizontalFittingPriority: .required,
			verticalFittingPriority: .fittingSizeLevel
		)

		if headerView.frame.size.height != fittedSize.height || headerView.frame.size.width != width {
			headerView.frame.size = CGSize(width: width, height: fittedSize.height)
			self.tableView.tableHeaderView = headerView
		}
	}

	private func configureSearchController() {
		guard self.isSearchable else { return }

		self.searchController.searchBar.placeholder = L10n.search
		self.searchController.searchResultsUpdater = self
		self.searchController.obscuresBackgroundDuringPresentation = false

		self.navigationItem.searchController = self.searchController
		self.navigationItem.hidesSearchBarWhenScrolling = false
	}

	private func scrollToCurrentSelection() {
		guard
			let selectedKey = self.selectedKey,
			let selectedIndex = self.filteredItems.firstIndex(where: { $0.key == selectedKey })
		else {
			return
		}

		let indexPath = IndexPath(item: selectedIndex, section: 0)
		self.tableView.safeScrollToRow(at: indexPath, at: .middle, animated: false)
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
			IconTableViewCell.self,
		]
	}
}

// MARK: - KCollectionViewDataSource
extension SettingsPickerTableViewController {
	func configureDataSource() {
		let iconTableViewCellRegistration = self.getConfiguredIconTableViewCell()

		self.dataSource = PickerDataSource(tableView: self.tableView) { tableView, indexPath, itemKind in
			tableView.dequeueConfiguredReusableCell(using: iconTableViewCellRegistration, for: indexPath, item: itemKind)
		}
		self.dataSource.footerText = self.footerText
	}

	func getConfiguredIconTableViewCell() -> UITableView.CellRegistration<IconTableViewCell, ItemKind> {
		return UITableView.CellRegistration<IconTableViewCell, ItemKind>(cellNib: IconTableViewCell.nib) { [weak self] iconTableViewCell, _, itemKind in
			guard let self else { return }
			iconTableViewCell.configure(title: itemKind.value)
			iconTableViewCell.setSelected(itemKind.key == self.selectedKey)
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
			await self.selectionHandler?(itemKind.key)
			await self.delegate?.settingsPickerTableViewController(self, didSelectKey: itemKind.key)
		}
	}

	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		if let footerView = view as? UITableViewHeaderFooterView {
			footerView.textLabel?.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
}

// MARK: - PickerDataSource
extension SettingsPickerTableViewController {
	/// The data source that titles the picker's footer.
	final class PickerDataSource: UITableViewDiffableDataSource<Section, ItemKind> {
		// MARK: - Properties
		/// The text shown below the options.
		var footerText: String?

		// MARK: - Functions
		override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
			return self.footerText
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

		if self.filteredItems.isEmpty {
			self.filteredItems = self.allItems.filter { $0.value.fuzzyContains(query) || $0.key.fuzzyContains(query) }
		}

		self.applySnapshot()
	}
}
