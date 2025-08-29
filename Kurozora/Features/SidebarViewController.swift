//
//  SidebarViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/03/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SidebarViewController: KCollectionViewController {
	// MARK: - Enums
	enum SidebarSection: Int {
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

	lazy var kSearchController: KSearchController = KSearchController()
	lazy var searchResultsCollectionViewController: SearchResultsCollectionViewController = R.storyboard.search.searchResultsCollectionViewController()!
	var listConfiguration: UICollectionLayoutListConfiguration!

	private var selectedItem: TabBarItem?
	private var deselectedItem: TabBarItem?
	private lazy var viewControllers: [UIViewController] = {
		return TabBarItem.sideBarCases.map {
			return $0.kViewControllerValue
		}
	}()

	private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, TabBarItem>!

	// MARK: - Initializers
	convenience init() {
		self.init(collectionViewLayout: UICollectionViewLayout())
	}

	// MARK: - View
	override func themeWillReload() {
		super.themeWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			if let collectionViewLayout = self.createLayout() {
				self.collectionView.collectionViewLayout = collectionViewLayout
			}

			self.reloadDataSource()
		}
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
		#if targetEnvironment(macCatalyst)
		// Disable search bar in navigation for the results view
		self.searchResultsCollectionViewController.includesSearchBar = false
		self.searchResultsCollectionViewController.kSearchController = self.kSearchController

		// Configure search bar
		self.kSearchController.viewController = self.searchResultsCollectionViewController
		self.kSearchController.forceShowsCancelButton = false
		self.kSearchController.obscuresBackgroundDuringPresentation = false
		self.kSearchController.automaticallyShowsCancelButton = false
		self.kSearchController.searchResultsUpdater = self
		self.kSearchController.delegate = self

		// Add search bar to navigation controller
		self.navigationItem.searchController = self.kSearchController
		#else
		self.searchResultsCollectionViewController.includesSearchBar = true
		#endif
	}

	/// Creates and returns a list content configuration for with the given configuration as the basis.
	///
	/// - Parameters:
	///    - configuration: A content configuration for a list-based content view.
	///    - cell: A collection view cell that provides list features and default styling.
	///
	/// - Returns: a list content configuration.
	private func getContentConfiguration(_ configuration: UIListContentConfiguration?, cell: UICollectionViewListCell?, item: TabBarItem) -> UIListContentConfiguration? {
		var contentConfiguration = configuration ?? cell?.defaultContentConfiguration()
		contentConfiguration?.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0)

		// Configure text
		contentConfiguration?.text = item.stringValue
		contentConfiguration?.textProperties.colorTransformer = UIConfigurationColorTransformer { _ in
			guard let state = cell?.configurationState else { return KThemePicker.textColor.colorValue }
			return state.isSelected || state.isHighlighted ? KThemePicker.tintedButtonTextColor.colorValue : KThemePicker.textColor.colorValue
		}

		// Configure image
		contentConfiguration?.imageToTextPadding = 10.0
		contentConfiguration?.image = {
			guard let state = cell?.configurationState else { return item.imageValue }
			return state.isSelected || state.isHighlighted ? item.selectedImageValue : item.imageValue
		}()
		contentConfiguration?.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 14.0))
		contentConfiguration?.imageProperties.tintColorTransformer = UIConfigurationColorTransformer { _ in
			guard let state = cell?.configurationState else { return KThemePicker.tintColor.colorValue }
			return state.isSelected || state.isHighlighted ? KThemePicker.tintedButtonTextColor.colorValue : KThemePicker.tintColor.colorValue
		}

		// Configure background
		cell?.backgroundConfiguration?.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
			guard let state = cell?.configurationState else { return .clear }
			return state.isSelected || state.isHighlighted ? KThemePicker.tintColor.colorValue : .clear
		}
		cell?.backgroundConfiguration?.cornerRadius = 10.0

		return contentConfiguration
	}
}

// MARK: - KCollectionViewDelegateLayout
extension SidebarViewController {
	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section, layoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
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
		let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TabBarItem> { [weak self] cell, _, item in
			guard let self = self else { return }
			var contentConfiguration = self.getContentConfiguration(.sidebarCell(), cell: cell, item: item)
			contentConfiguration?.text = item.stringValue
			contentConfiguration?.image = item.imageValue
			cell.contentConfiguration = contentConfiguration
		}

		self.dataSource = UICollectionViewDiffableDataSource<SidebarSection, TabBarItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
			return collectionView.dequeueConfiguredReusableCell(using: rowRegistration, for: indexPath, item: item)
		}
	}

	private func sideBarSnapshot() -> NSDiffableDataSourceSectionSnapshot<TabBarItem> {
		var snapshot = NSDiffableDataSourceSectionSnapshot<TabBarItem>()
		snapshot.append(TabBarItem.sideBarCases)
		return snapshot
	}

	private func applyInitialSnapshot() {
		self.dataSource.apply(self.sideBarSnapshot(), to: .main, animatingDifferences: false) { [weak self] in
			guard let self = self else { return }
			// Select the home view
			let indexPath = IndexPath(row: TabBarItem.home.rawValue, section: 0)
			self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
			self.collectionView(self.collectionView, didSelectItemAt: indexPath)
		}
	}

	private func reloadDataSource() {
		var snapshot = self.dataSource.snapshot()
		snapshot.reloadSections([.main])
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}
}

// MARK: - UICollectionViewDelegate
extension SidebarViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let newlySelectedItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
		let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell
		cell?.contentConfiguration = self.getContentConfiguration(.sidebarCell(), cell: cell, item: newlySelectedItem)
		let shouldSegue = self.selectedItem != newlySelectedItem

		if newlySelectedItem != .settings {
			self.selectedItem = newlySelectedItem
		}

		if self.kSearchController.isActive {
			self.kSearchController.isActive = false
		}

		switch newlySelectedItem {
		case .settings:
			if let deselectedItem = self.deselectedItem, let deselectedIndexPath = self.dataSource.indexPath(for: deselectedItem) {
				self.collectionView.selectItem(at: deselectedIndexPath, animated: false, scrollPosition: [])
				self.collectionView(self.collectionView, didSelectItemAt: deselectedIndexPath)

				self.collectionView.deselectItem(at: indexPath, animated: false)
				self.collectionView(self.collectionView, didDeselectItemAt: indexPath)
			}

			let settingsSplitViewController = self.viewControllers[indexPath.row]
			settingsSplitViewController.modalPresentationStyle = .fullScreen
			self.present(settingsSplitViewController, animated: true)
		default:
			if shouldSegue {
				self.splitViewController?.setViewController(self.viewControllers[indexPath.row], for: .secondary)
			}
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		guard let deselectedItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
		let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell
		cell?.contentConfiguration = self.getContentConfiguration(.sidebarCell(), cell: cell, item: deselectedItem)

		self.deselectedItem = deselectedItem
	}
}

// MARK: - UISearchControllerDelegate
extension SidebarViewController: UISearchControllerDelegate, UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let kNavigationController = self.splitViewController?.viewController(for: .secondary) as? KNavigationController else { return }
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
			self.collectionView(self.collectionView, didDeselectItemAt: indexPath)
		}

		self.selectedItem = nil
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		self.kSearchController.willDismissSearchController(searchController)
		self.kSearchController.searchBar.setShowsScope(false, animated: true)
	}
}
