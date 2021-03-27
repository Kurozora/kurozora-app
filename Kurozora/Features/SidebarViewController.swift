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

	#if targetEnvironment(macCatalyst)
	var kSearchController: KSearchController = KSearchController()
	#endif

	private var selectedItem: TabBarItem = .feed
	private lazy var viewControllers: [UIViewController] = {
		return TabBarItem.allCases.map {
			return $0.kViewControllerValue
		}
	}()

	private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!

	// MARK: - Initializers
	convenience init() {
		let layout = UICollectionViewCompositionalLayout { (section, layoutEnvironment) -> NSCollectionLayoutSection? in
			if #available(iOS 14.0, macOS 11.0, *) {
				var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
				configuration.showsSeparators = false
				let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
				return section
			}
			return nil
		}
		self.init(collectionViewLayout: layout)
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.theme_backgroundColor = KThemePicker.sidebarBackgroundColor.rawValue

		self.sharedInit()
		self.configureDataSource()
		self.applyInitialSnapshot()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the sidebar view.
	private func sharedInit() {
		self.collectionView.isScrollEnabled = false
		self.clearsSelectionOnViewWillAppear = false
		self.navigationItem.hidesSearchBarWhenScrolling = false
		self.navigationItem.largeTitleDisplayMode = .always
		self.navigationController?.navigationBar.showsLargeContentViewer = false

		#if targetEnvironment(macCatalyst)
		self.configureSearchBar()
		#endif
	}

	/// Configures the search bar.
	fileprivate func configureSearchBar() {
		#if targetEnvironment(macCatalyst)
		// Configure search bar
		kSearchController.viewController = self
		kSearchController.searchScope = .show

		// Add search bar to navigation controller
		navigationItem.searchController = kSearchController
		kSearchController.automaticallyShowsCancelButton = false
		kSearchController.automaticallyShowsScopeBar = false
		#endif
	}

	/**
		Creates and returns a list content configuration for with the given configuration as the basis.

		- Parameter configuration: A content configuration for a list-based content view.
		- Parameter cell: A collection view cell that provides list features and default styling.

		- Returns: a list content configuration.
	*/
	private func getContentConfiguration(_ configuration: UIListContentConfiguration?, cell: UICollectionViewListCell?) -> UIListContentConfiguration? {
		let isSelected = cell?.configurationState.isSelected ?? false
		var contentConfiguration = configuration ?? cell?.defaultContentConfiguration()
		contentConfiguration?.text = self.selectedItem.stringValue
		contentConfiguration?.textProperties.font = .systemFont(ofSize: 14.0)
		contentConfiguration?.textProperties.colorTransformer = UIConfigurationColorTransformer { [weak cell] _ in
			guard let state = cell?.configurationState else { return KThemePicker.textColor.colorValue }
			return state.isHighlighted ? KThemePicker.textColor.colorValue.lighten(by: 0.4) : KThemePicker.textColor.colorValue
		}
		contentConfiguration?.image = isSelected ? selectedItem.selectedImageValue : selectedItem.imageValue
		contentConfiguration?.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 14.0))
		contentConfiguration?.imageToTextPadding = 10.0
		contentConfiguration?.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0)
		return contentConfiguration
	}
}

// MARK: - KCollectionViewDelegateLayout
extension SidebarViewController {
	override func createLayout() -> UICollectionViewLayout? {
		if dataSource != nil {
			let layout = UICollectionViewCompositionalLayout { (section, layoutEnvironment) -> NSCollectionLayoutSection? in
				if #available(iOS 14.0, macOS 11.0, *) {
					var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
					configuration.showsSeparators = false
					let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
					return section
				}
				return nil
			}
			return layout
		}

		return nil
	}
}

// MARK: - KCollectionViewDataSource
extension SidebarViewController {
	override func configureDataSource() {
		if #available(iOS 14.0, macOS 11.0, *) {
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
	}

	@available(iOS 14.0, *)
	private func sideBarSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
		var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
		let items: [SidebarItem] = TabBarItem.allCases.map {
			return .row(title: $0.stringValue, image: $0.imageValue, id: $0.rowIdentifierValue)
		}
		snapshot.append(items)
		return snapshot
	}

	@available(iOS 14.0, *)
	private func applyInitialSnapshot() {
		dataSource.apply(sideBarSnapshot(), to: .main, animatingDifferences: false) {
			// Select the home view
			let indexPath = IndexPath(row: 0, section: 0)
			self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
			self.collectionView(self.collectionView, didSelectItemAt: indexPath)
		}
	}
}

extension SidebarViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let newlySelectedItem = TabBarItem.allCases[indexPath.row]
		let shouldSegue = self.selectedItem != newlySelectedItem

		self.selectedItem = newlySelectedItem
		let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell
		cell?.contentConfiguration = self.getContentConfiguration(nil, cell: cell)

		if shouldSegue {
			splitViewController?.setViewController(self.viewControllers[indexPath.row], for: .secondary)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell
		cell?.contentConfiguration = self.getContentConfiguration(nil, cell: cell)
	}
}
