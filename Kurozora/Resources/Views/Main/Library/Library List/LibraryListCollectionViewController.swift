//
//  LibraryListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class LibraryListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var shows: [Show] = []
	var literatures: [Literature] = []
	var games: [Game] = []
	var nextPageCursor: PageCursor?
	var sectionIndex: Int?
	var totalLibraryItemsCount: Int = 0
	var libraryKind: LibraryKind = UserSettings.libraryKind
	var libraryStatus: LibraryStatus = .none
	var librarySortType: LibrarySortType = .none
	var librarySortTypeOption: LibrarySortOption = .none {
		didSet {
			self.nextPageCursor = nil
			self.delegate?.libraryListViewController(updateSortWith: self.librarySortType, sortOption: self.librarySortTypeOption)
		}
	}

	var libraryCellStyle: LibraryCellStyle = .detailed
	var libraryColumnPreferences: LibraryColumnPreferences = .defaultShared
	var libraryCompactTitleVisibility: LibraryCompactTitleVisibility = .always

	/// A Boolean value that indicates whether the controller's view is currently the visible page.
	var isPageVisible: Bool = false

	/// The number of items currently loaded for the active library kind.
	var loadedItemCount: Int {
		switch self.libraryKind {
		case .shows: return self.shows.count
		case .literatures: return self.literatures.count
		case .games: return self.games.count
		}
	}

	private var lastEffectiveCellStyle: LibraryCellStyle?

	weak var delegate: LibraryListViewControllerDelegate?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	var user: User?
	var viewedUser: User? {
		return self.user ?? User.current
	}

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.enableRefreshControl()
		}

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if self.viewedUser == User.current {
			NotificationCenter.default.addObserver(self, selector: #selector(addToLibrary(_:)), name: Notification.Name("AddTo\(self.libraryStatus.sectionValue)Section"), object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(removeFromLibrary(_:)), name: Notification.Name("RemoveFrom\(self.libraryStatus.sectionValue)Section"), object: nil)
		}

		// Add bottom inset to avoid the tabbar obscuring the view
		self.collectionView.contentInset.top = 50
		self.collectionView.contentInset.bottom = 60
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
		self.collectionView.allowsMultipleSelectionDuringEditing = true

		if self.viewedUser == nil {
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		self.enableRefreshControl()

		#if !targetEnvironment(macCatalyst)
		let libraryStatus: String

		switch self.libraryKind {
		case .shows:
			libraryStatus = self.libraryStatus.showStringValue
		case .literatures:
			libraryStatus = self.libraryStatus.literatureStringValue
		case .games:
			libraryStatus = self.libraryStatus.gameStringValue
		}

		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshLibrary(libraryStatus.lowercased()))
		#endif

		if let (sortType, sortOption) = UserSettings.librarySortTypes[self.libraryKind]?[self.libraryStatus] {
			self.librarySortType = sortType
			self.librarySortTypeOption = sortOption
		}

		self.libraryColumnPreferences = UserSettings.libraryColumnPreferences(for: self.libraryKind, status: self.libraryStatus)
		self.libraryCompactTitleVisibility = UserSettings.libraryCompactTitleVisibility(for: self.libraryKind, status: self.libraryStatus)

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }

			await self.fetchLibrary()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.isPageVisible = true

		if self.user == nil {
			UserSettings.set(self.sectionIndex, forKey: .libraryPage)
		}

		if self.user == nil, self.libraryKind != UserSettings.libraryKind {
			self.libraryKind = UserSettings.libraryKind
			self.nextPageCursor = nil
			self.libraryCellStyle = UserSettings.libraryCellStyle(for: self.libraryKind, status: self.libraryStatus)
			self.libraryColumnPreferences = UserSettings.libraryColumnPreferences(for: self.libraryKind, status: self.libraryStatus)
			self.libraryCompactTitleVisibility = UserSettings.libraryCompactTitleVisibility(for: self.libraryKind, status: self.libraryStatus)
			self.shows = []
			self.literatures = []
			self.games = []
			self.updateDataSource()

			Task { [weak self] in
				guard let self = self else {
					return
				}

				await self.fetchLibrary()
			}
		}

		self.configureEmptyDataView()
		self.toggleEmptyDataView()

		(tabmanParent as? LibraryViewController)?.libraryViewControllerDelegate = self
		(tabmanParent as? LibraryViewController)?.libraryViewControllerDataSource = self

		if let index = self.sectionIndex {
			self.delegate?.libraryListViewController(willScrollTo: index)
		}

		self.delegate?.libraryListViewController(updateSortWith: self.librarySortType, sortOption: self.librarySortTypeOption)
		self.delegate?.libraryListViewController(updateTotalCount: self.totalLibraryItemsCount)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.isPageVisible = false
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		guard self.dataSource != nil else {
			return
		}

		let newEffective = self.effectiveCellStyleForCurrentEnvironment()
		guard newEffective != self.lastEffectiveCellStyle else {
			return
		}

		self.lastEffectiveCellStyle = newEffective

		DispatchQueue.main.async { [weak self] in
			self?.collectionView.reloadData()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageCursor = nil

		Task { [weak self] in
			guard let self = self else { return }

			await self.fetchLibrary()
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else {
			return nil
		}

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		}
	}

	/// Selects every loaded item and notifies the delegate of the resulting selection.
	func selectAllLoadedItems() {
		let count = self.loadedItemCount
		guard count > 0 else { return }

		for index in 0 ..< count {
			let indexPath = IndexPath(item: index, section: 0)
			self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
		}
		self.delegate?.libraryListViewController(self, didUpdateSelection: self.collectionView.indexPathsForSelectedItems ?? [])
	}

	/// Deselects every selected item and notifies the delegate of the empty selection.
	func deselectAllVisibleItems() {
		self.collectionView.indexPathsForSelectedItems?.forEach { indexPath in
			self.collectionView.deselectItem(at: indexPath, animated: false)
		}
		self.delegate?.libraryListViewController(self, didUpdateSelection: [])
	}

	/// Returns the item identifiers for the given index paths.
	///
	/// Index paths are visited in the order supplied; missing items are skipped.
	///
	/// - Parameter indexPaths: The index paths whose item identifiers to resolve.
	///
	/// - Returns: The resolved item identifiers, preserving input order.
	func selectedItemIDs(at indexPaths: [IndexPath]) -> [KurozoraItemID] {
		return indexPaths.compactMap { indexPath in
			switch self.libraryKind {
			case .shows: return self.shows[safe: indexPath.item]?.id
			case .literatures: return self.literatures[safe: indexPath.item]?.id
			case .games: return self.games[safe: indexPath.item]?.id
			}
		}
	}

	/// Returns a boolean value that indicates whether any item at the given index paths is not favorited.
	///
	/// - Parameter indexPaths: The index paths to test.
	///
	/// - Returns: `true` if at least one item is not currently favorited; otherwise, `false`.
	func anySelectedIsUnfavorited(at indexPaths: [IndexPath]) -> Bool {
		return indexPaths.contains { indexPath in
			switch self.libraryKind {
			case .shows: return self.shows[safe: indexPath.item]?.attributes.library?.isFavorited != true
			case .literatures: return self.literatures[safe: indexPath.item]?.attributes.library?.isFavorited != true
			case .games: return self.games[safe: indexPath.item]?.attributes.library?.isFavorited != true
			}
		}
	}

	/// Returns a boolean value that indicates whether any item at the given index paths has no reminder.
	///
	/// - Parameter indexPaths: The index paths to test.
	///
	/// - Returns: `true` if at least one item has no reminder set; otherwise, `false`.
	func anySelectedIsUnreminded(at indexPaths: [IndexPath]) -> Bool {
		return indexPaths.contains { indexPath in
			switch self.libraryKind {
			case .shows: return self.shows[safe: indexPath.item]?.attributes.library?.isReminded != true
			case .literatures: return self.literatures[safe: indexPath.item]?.attributes.library?.isReminded != true
			case .games: return self.games[safe: indexPath.item]?.attributes.library?.isReminded != true
			}
		}
	}

	/// Returns a boolean value that indicates whether any item at the given index paths is visible.
	///
	/// - Parameter indexPaths: The index paths to test.
	///
	/// - Returns: `true` if at least one item is not currently hidden; otherwise, `false`.
	func anySelectedIsVisible(at indexPaths: [IndexPath]) -> Bool {
		return indexPaths.contains { indexPath in
			switch self.libraryKind {
			case .shows: return self.shows[safe: indexPath.item]?.attributes.library?.isHidden != true
			case .literatures: return self.literatures[safe: indexPath.item]?.attributes.library?.isHidden != true
			case .games: return self.games[safe: indexPath.item]?.attributes.library?.isHidden != true
			}
		}
	}

	/// Removes the items at the given index paths from the in-memory storage and reapplies the snapshot.
	///
	/// Decrements ``totalLibraryItemsCount`` by the number of removed items and notifies the delegate.
	///
	/// - Parameter indexPaths: The index paths of the items to remove.
	func removeItems(at indexPaths: [IndexPath]) {
		let sortedIndices = indexPaths.map { $0.item }.sorted(by: >)

		switch self.libraryKind {
		case .shows:
			for index in sortedIndices where index < self.shows.count { self.shows.remove(at: index) }
		case .literatures:
			for index in sortedIndices where index < self.literatures.count { self.literatures.remove(at: index) }
		case .games:
			for index in sortedIndices where index < self.games.count { self.games.remove(at: index) }
		}

		self.totalLibraryItemsCount = max(0, self.totalLibraryItemsCount - sortedIndices.count)
		self.delegate?.libraryListViewController(updateTotalCount: self.totalLibraryItemsCount)
		self.updateDataSource()
	}

	/// Mutates the library attributes of the items at the given index paths in place.
	///
	/// Reconfigures the affected cells without animating differences after the mutation.
	///
	/// - Parameters:
	///    - indexPaths: The index paths of the items whose library attributes should change.
	///    - mutate: A closure that receives the current attributes by reference for in-place mutation.
	func mutateLibraryAttributes(at indexPaths: [IndexPath], _ mutate: (inout LibraryAttributes) -> Void) {
		var changedItems: [ItemKind] = []

		for indexPath in indexPaths {
			switch self.libraryKind {
			case .shows:
				if var library = self.shows[safe: indexPath.item]?.attributes.library {
					mutate(&library)
					self.shows[indexPath.item].attributes.library = library
					changedItems.append(.show(self.shows[indexPath.item]))
				}
			case .literatures:
				if var library = self.literatures[safe: indexPath.item]?.attributes.library {
					mutate(&library)
					self.literatures[indexPath.item].attributes.library = library
					changedItems.append(.literature(self.literatures[indexPath.item]))
				}
			case .games:
				if var library = self.games[safe: indexPath.item]?.attributes.library {
					mutate(&library)
					self.games[indexPath.item].attributes.library = library
					changedItems.append(.game(self.games[indexPath.item]))
				}
			}
		}

		guard !changedItems.isEmpty else { return }
		self.snapshot = self.dataSource.snapshot()
		self.snapshot.reconfigureItems(changedItems)
		self.dataSource.apply(self.snapshot, animatingDifferences: false)
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else {
			return
		}

		switch identifier {
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		}
	}
}
