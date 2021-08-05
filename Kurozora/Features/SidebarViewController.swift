//
//  SidebarViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/03/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

class SidebarViewController: KCollectionViewController {
	private enum SidebarSection: Int {
		case main
	}

	private struct SidebarItem: Hashable, Identifiable {
		let id: UUID
		let title: String
		let image: UIImage?

		static func row(title: String, image: UIImage, id: UUID = UUID()) -> Self {
			return SidebarItem(id: id, title: title, image: image)
		}
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

	lazy var kSearchController: KSearchController = KSearchController()
	lazy var searchResultsCollectionViewController: SearchResultsCollectionViewController = R.storyboard.search.searchResultsCollectionViewController()!
	var listConfiguration: UICollectionLayoutListConfiguration!

	private var selectedItem: TabBarItem?
	private lazy var viewControllers: [UIViewController] = {
		return TabBarItem.sideBarCases.map {
			return $0.kViewControllerValue
		}
	}()

	private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!

	// MARK: - Initializers
	convenience init() {
		self.init(collectionViewLayout: UICollectionViewLayout())
	}

	// MARK: - View
	override func themeWillReload() {
		super.themeWillReload()

		self.listConfiguration.backgroundColor = KThemePicker.backgroundColor.colorValue
		self.applyInitialSnapshot()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.sharedInit()
		self.configureDataSource()
		self.applyInitialSnapshot()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the sidebar view.
	fileprivate func sharedInit() {
		self.collectionView.isScrollEnabled = false
		self.clearsSelectionOnViewWillAppear = false
		self.navigationItem.hidesSearchBarWhenScrolling = false
		self.navigationItem.largeTitleDisplayMode = .never

		self.configureSearchBar()
	}

	/// Configures the search bar.
	fileprivate func configureSearchBar() {
		// Disable search bar in navigation for the results view
		searchResultsCollectionViewController.includesSearchBar = false

		// Configure search bar
		kSearchController.viewController = searchResultsCollectionViewController
		kSearchController.searchScope = .show
		kSearchController.forceShowsCancelButton = false
		kSearchController.obscuresBackgroundDuringPresentation = false
		kSearchController.automaticallyShowsCancelButton = false
		kSearchController.automaticallyShowsScopeBar = true
		kSearchController.searchResultsUpdater = self
		kSearchController.delegate = self

		// Add search bar to navigation controller
		navigationItem.searchController = kSearchController
	}

	/**
		Creates and returns a list content configuration for with the given configuration as the basis.

		- Parameter configuration: A content configuration for a list-based content view.
		- Parameter cell: A collection view cell that provides list features and default styling.

		- Returns: a list content configuration.
	*/
	private func getContentConfiguration(_ configuration: UIListContentConfiguration?, cell: UICollectionViewListCell?) -> UIListContentConfiguration? {
		var contentConfiguration = configuration ?? cell?.defaultContentConfiguration()
		contentConfiguration?.text = self.selectedItem?.stringValue
		contentConfiguration?.textProperties.colorTransformer = UIConfigurationColorTransformer { [weak cell] _ in
			guard let state = cell?.configurationState else { return KThemePicker.textColor.colorValue }
			return state.isSelected || state.isHighlighted ? KThemePicker.tintedButtonTextColor.colorValue : KThemePicker.textColor.colorValue
		}
		contentConfiguration?.textProperties.font = .systemFont(ofSize: 14.0)
		contentConfiguration?.imageToTextPadding = 10.0
		contentConfiguration?.image = { () -> UIImage? in
			guard let state = cell?.configurationState else { return self.selectedItem?.imageValue }
			return state.isSelected || state.isHighlighted ? self.selectedItem?.selectedImageValue : self.selectedItem?.imageValue
		}()
		contentConfiguration?.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 14.0))
		contentConfiguration?.imageProperties.tintColorTransformer = UIConfigurationColorTransformer { [weak cell] _ in
			guard let state = cell?.configurationState else { return KThemePicker.tintColor.colorValue }
			return state.isSelected || state.isHighlighted ? KThemePicker.tintedButtonTextColor.colorValue : KThemePicker.tintColor.colorValue
		}
		contentConfiguration?.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0)

		cell?.backgroundConfiguration?.backgroundColorTransformer = UIConfigurationColorTransformer { [weak cell] _ in
			guard let state = cell?.configurationState else { return .clear }
			return state.isSelected || state.isHighlighted ? KThemePicker.tintColor.colorValue : .clear
		}
		cell?.backgroundConfiguration?.cornerRadius = 8.0
		return contentConfiguration
	}
}

// MARK: - KCollectionViewDelegateLayout
extension SidebarViewController {
	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { (section, layoutEnvironment) -> NSCollectionLayoutSection? in
			self.listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebar)
			self.listConfiguration.backgroundColor = KThemePicker.backgroundColor.colorValue
			self.listConfiguration.showsSeparators = false
			let section = NSCollectionLayoutSection.list(using: self.listConfiguration, layoutEnvironment: layoutEnvironment)
			section.contentInsets.top = 10.0
			return section
		}
		return layout
	}
}

// MARK: - KCollectionViewDataSource
extension SidebarViewController {
	override func configureDataSource() {
		let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, _, item) in
			var contentConfiguration = self.getContentConfiguration(UIListContentConfiguration.sidebarCell(), cell: cell)
			contentConfiguration?.text = item.title
			contentConfiguration?.image = item.image
			cell.contentConfiguration = contentConfiguration
		}

		dataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
			return collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
		}
	}

	private func sideBarSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
		var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
		let items: [SidebarItem] = TabBarItem.sideBarCases.map {
			return .row(title: $0.stringValue, image: $0.imageValue, id: $0.rowIdentifierValue)
		}
		snapshot.append(items)
		return snapshot
	}

	private func applyInitialSnapshot() {
		dataSource.apply(sideBarSnapshot(), to: .main, animatingDifferences: false) {
			// Select the home view
			let indexPath = IndexPath(row: 0, section: 0)
			self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
			self.collectionView(self.collectionView, didSelectItemAt: indexPath)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension SidebarViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let newlySelectedItem = TabBarItem.sideBarCases[indexPath.row]
		let shouldSegue = self.selectedItem != newlySelectedItem

		self.selectedItem = newlySelectedItem
		let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell
		cell?.contentConfiguration = self.getContentConfiguration(nil, cell: cell)

		if self.kSearchController.isActive {
			self.kSearchController.isActive = false
		}

		if shouldSegue {
			self.splitViewController?.setViewController(self.viewControllers[indexPath.row], for: .secondary)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell
		cell?.contentConfiguration = self.getContentConfiguration(nil, cell: cell)
	}
}

// MARK: - UISearchControllerDelegate
extension SidebarViewController: UISearchControllerDelegate, UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let kNavigationController = splitViewController?.viewController(for: .secondary) as? KNavigationController else { return }
		if (kNavigationController.topViewController as? SearchResultsCollectionViewController) == nil {
			let kNavigationController = KNavigationController(rootViewController: self.searchResultsCollectionViewController)
			self.splitViewController?.setViewController(kNavigationController, for: .secondary)
		}
	}

	func willPresentSearchController(_ searchController: UISearchController) {
		self.kSearchController.willPresentSearchController(searchController)

		// Deselect collection view item
		for indexPath in self.collectionView.indexPathsForSelectedItems ?? [] {
			self.collectionView.deselectItem(at: indexPath, animated: true)
			self.collectionView.delegate?.collectionView?(self.collectionView, didDeselectItemAt: indexPath)
		}
		self.selectedItem = nil
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		self.kSearchController.willDismissSearchController(searchController)
	}
}
