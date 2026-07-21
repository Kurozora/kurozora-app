//
//  LibraryListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class LibraryListCollectionViewController: KCollectionViewController, TypedSegueHandling {
	// MARK: - Properties
	/// The local library entries currently loaded for the active kind and status.
	var entries: [LocalLibraryEntry] = []
	var sectionIndex: Int?
	var totalLibraryItemsCount: Int = 0
	var libraryKind: LibraryKind = UserSettings.libraryKind
	var libraryStatus: LibraryStatus = .none
	var librarySortType: LibrarySortType = .none
	var librarySortTypeOption: LibrarySortOption = .none {
		didSet {
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
		return self.entries.count
	}

	private var lastEffectiveCellStyle: LibraryCellStyle?

	/// Observes local library mutations to keep the list current.
	private var libraryObserver: LocalLibraryEntryObserver?

	/// Whether a full refetch is already scheduled.
	private var refetchScheduled = false

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
		self.rebindLibraryObserver()

		Task { [weak self] in
			guard let self = self else { return }

			await self.fetchLibrary()
		}
	}

	/// Re-subscribes the library observer to the active `(userSlug, libraryKind)` pair.
	func rebindLibraryObserver() {
		guard self.viewedUser == User.current, let slug = User.current?.attributes.slug else {
			self.libraryObserver = nil
			return
		}

		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug, kind: self.libraryKind),
			onChange: { [weak self] entry in
				self?.handleLibraryEntryChange(entry)
			},
			onRemove: { [weak self] removed in
				self?.handleLibraryEntryRemoval(removed)
			}
		)
	}

	/// Reacts to a library insert or update by reconfiguring, removing, or refetching as appropriate.
	private func handleLibraryEntryChange(_ entry: LocalLibraryEntry) {
		if entry.libraryStatus != self.libraryStatus {
			// Match on trackable identity as well — a resynced row carries a new object ID.
			guard let index = self.entries.firstIndex(where: { $0.objectID == entry.objectID || $0.trackableID == entry.trackableID }) else { return }
			self.entries.remove(at: index)
			self.totalLibraryItemsCount = max(0, self.totalLibraryItemsCount - 1)
			self.delegate?.libraryListViewController(updateTotalCount: self.totalLibraryItemsCount)
			self.updateDataSource()
			return
		}

		var currentSnapshot = self.dataSource.snapshot()
		let item = ItemKind.entry(entry)

		if currentSnapshot.itemIdentifiers.contains(item) {
			currentSnapshot.reconfigureItems([item])
			self.dataSource.apply(currentSnapshot, animatingDifferences: false)
		} else {
			self.scheduleRefetch()
		}
	}

	/// Schedules a coalesced full refetch from the local store.
	private func scheduleRefetch() {
		guard !self.refetchScheduled else { return }
		self.refetchScheduled = true

		Task { [weak self] in
			guard let self = self else { return }
			self.refetchScheduled = false
			self.entries = []
			await self.fetchLibrary()
		}
	}

	/// Removes a deleted entry from the list and decrements the displayed total count.
	private func handleLibraryEntryRemoval(_ removed: LocalLibraryEntryObserver.RemovedEntry) {
		guard let index = self.entries.firstIndex(where: { $0.objectID == removed.objectID || $0.trackableID == removed.trackableID }) else { return }
		self.entries.remove(at: index)
		self.totalLibraryItemsCount = max(0, self.totalLibraryItemsCount - 1)
		self.delegate?.libraryListViewController(updateTotalCount: self.totalLibraryItemsCount)
		self.updateDataSource()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.isPageVisible = true

		if self.user == nil {
			UserSettings.set(self.sectionIndex, forKey: .libraryPage)
		}

		if self.user == nil, self.libraryKind != UserSettings.libraryKind {
			self.libraryKind = UserSettings.libraryKind
			self.libraryCellStyle = UserSettings.libraryCellStyle(for: self.libraryKind, status: self.libraryStatus)
			self.libraryColumnPreferences = UserSettings.libraryColumnPreferences(for: self.libraryKind, status: self.libraryStatus)
			self.libraryCompactTitleVisibility = UserSettings.libraryCompactTitleVisibility(for: self.libraryKind, status: self.libraryStatus)
			self.entries = []
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
		self.entries = []

		Task { [weak self] in
			guard let self = self else { return }

			await self.fetchLibrary()
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

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
			self.entries[safe: indexPath.item].map { KurozoraItemID($0.trackableID) }
		}
	}

	/// Returns a boolean value that indicates whether any item at the given index paths is not favorited.
	///
	/// - Parameter indexPaths: The index paths to test.
	///
	/// - Returns: `true` if at least one item is not currently favorited; otherwise, `false`.
	func anySelectedIsUnfavorited(at indexPaths: [IndexPath]) -> Bool {
		return indexPaths.contains { indexPath in
			self.entries[safe: indexPath.item]?.isFavorited != true
		}
	}

	/// Returns a boolean value that indicates whether any item at the given index paths has no reminder.
	///
	/// - Parameter indexPaths: The index paths to test.
	///
	/// - Returns: `true` if at least one item has no reminder set; otherwise, `false`.
	func anySelectedIsUnreminded(at indexPaths: [IndexPath]) -> Bool {
		return indexPaths.contains { indexPath in
			self.entries[safe: indexPath.item]?.isReminded != true
		}
	}

	/// Returns a boolean value that indicates whether any item at the given index paths is visible.
	///
	/// - Parameter indexPaths: The index paths to test.
	///
	/// - Returns: `true` if at least one item is not currently hidden; otherwise, `false`.
	func anySelectedIsVisible(at indexPaths: [IndexPath]) -> Bool {
		return indexPaths.contains { indexPath in
			self.entries[safe: indexPath.item]?.isHidden != true
		}
	}

	/// Removes the items at the given index paths from the in-memory storage and reapplies the snapshot.
	///
	/// Decrements ``totalLibraryItemsCount`` by the number of removed items and notifies the delegate.
	///
	/// - Parameter indexPaths: The index paths of the items to remove.
	func removeItems(at indexPaths: [IndexPath]) {
		let sortedIndices = indexPaths.map { $0.item }.sorted(by: >)

		for index in sortedIndices where index < self.entries.count {
			self.entries.remove(at: index)
		}

		self.totalLibraryItemsCount = max(0, self.totalLibraryItemsCount - sortedIndices.count)
		self.delegate?.libraryListViewController(updateTotalCount: self.totalLibraryItemsCount)
		self.updateDataSource()
	}

	/// Mutates the library attributes of the entries at the given index paths via the local store.
	///
	/// Reconfigures the affected cells without animating differences after the mutation.
	///
	/// - Parameters:
	///    - indexPaths: The index paths of the items whose library attributes should change.
	///    - mutate: A closure invoked with each entry for direct mutation.
	func mutateLibraryAttributes(at indexPaths: [IndexPath], _ mutate: (LocalLibraryEntry) -> Void) {
		var changedItems: [ItemKind] = []

		for indexPath in indexPaths {
			guard let entry = self.entries[safe: indexPath.item] else { continue }
			mutate(entry)
			changedItems.append(.entry(entry))
		}

		guard !changedItems.isEmpty else { return }
		self.snapshot = self.dataSource.snapshot()
		self.snapshot.reconfigureItems(changedItems)
		self.dataSource.apply(self.snapshot, animatingDifferences: false)
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }
		guard let entry = sender as? LocalLibraryEntry else { return }
		let itemID = KurozoraItemID(entry.trackableID)

		switch identifier {
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			showDetailsCollectionViewController.showIdentity = ShowIdentity(id: itemID)
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			literatureDetailCollectionViewController.literatureIdentity = LiteratureIdentity(id: itemID)
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			gameDetailCollectionViewController.gameIdentity = GameIdentity(id: itemID)
		}
	}
}
