//
//  LibraryListCollectionViewController+Types.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A set of methods you can use to receive scrolling, sorting and count-update messages from a ``LibraryListCollectionViewController`` instance.
protocol LibraryListViewControllerDelegate: AnyObject {
	/// Tells the delegate that the library list is about to scroll to the given index.
	///
	/// - Parameter index: The index of the library status page that will become visible.
	func libraryListViewController(willScrollTo index: Int)

	/// Tells the delegate that the sort selection changed.
	///
	/// Emitted whenever ``LibraryListCollectionViewController/librarySortType`` or
	/// ``LibraryListCollectionViewController/librarySortTypeOption`` is written to.
	///
	/// - Parameters:
	///    - sortType: The sort type the list is now sorted by.
	///    - sortOption: The sort option that refines the sort type, such as ascending or descending.
	func libraryListViewController(updateSortWith sortType: LibrarySortType, sortOption: LibrarySortOption)

	/// Tells the delegate that the total number of items in the library has changed.
	///
	/// - Parameter totalCount: The updated total item count for the current status page.
	func libraryListViewController(updateTotalCount totalCount: Int)

	/// Tells the delegate that the user's selection in the library list has changed.
	///
	/// - Parameters:
	///    - viewController: The list whose selection changed.
	///    - selectedIndexPaths: The set of currently-selected index paths.
	func libraryListViewController(_ viewController: LibraryListCollectionViewController, didUpdateSelection selectedIndexPaths: [IndexPath])
}

// MARK: - SectionLayoutKind
extension LibraryListCollectionViewController {
	/// The sections rendered by the library list collection view.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		/// The single section that contains every library item.
		case main = 0
	}
}

// MARK: - ItemKind
extension LibraryListCollectionViewController {
	/// The list of available library list item kinds.
	enum ItemKind: Hashable {
		/// The item contains a ``LocalLibraryEntry`` row from the local store.
		case entry(_: LocalLibraryEntry)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .entry(let entry):
				hasher.combine(entry.objectID)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.entry(let lhsEntry), .entry(let rhsEntry)):
				return lhsEntry.objectID == rhsEntry.objectID
			}
		}
	}
}

// MARK: - LibraryViewControllerDataSource
extension LibraryListCollectionViewController: LibraryViewControllerDataSource {
	/// The sort type currently applied to the library list.
	///
	/// - Returns: The ``LibrarySortType`` in effect for this status page.
	func sortValue() -> LibrarySortType {
		return self.librarySortType
	}

	/// The sort option currently refining the sort type.
	///
	/// - Returns: The ``LibrarySortOption`` in effect for this status page.
	func sortOptionValue() -> LibrarySortOption {
		return self.librarySortTypeOption
	}
}

// MARK: - LibraryViewControllerDelegate
extension LibraryListCollectionViewController: LibraryViewControllerDelegate {
	/// Updates the list to reflect a change in the library kind chosen by the parent controller.
	///
	/// Restores the persisted sort and cell style for the new `(kind, status)` pair, triggers a
	/// refetch, and refreshes the empty-data view copy so it reads correctly for the new kind.
	///
	/// - Parameters:
	///    - view: The ``LibraryViewController`` that initiated the change.
	///    - libraryKind: The newly selected library kind.
	func libraryViewController(_ view: LibraryViewController, didChange libraryKind: LibraryKind) {
		let (sortType, sortOption) = UserSettings.librarySortTypes[libraryKind]?[self.libraryStatus] ?? (LibrarySortType.none, LibrarySortOption.none)

		self.libraryKind = libraryKind
		self.libraryCellStyle = UserSettings.libraryCellStyle(for: libraryKind, status: self.libraryStatus)
		self.libraryColumnPreferences = UserSettings.libraryColumnPreferences(for: libraryKind, status: self.libraryStatus)
		self.libraryCompactTitleVisibility = UserSettings.libraryCompactTitleVisibility(for: libraryKind, status: self.libraryStatus)

		// Reset data and refetch
		self.entries = []
		self.updateDataSource()

		// Refresh view
		self.refreshTableHeader()
		self.collectionView.collectionViewLayout.invalidateLayout()

		self.sortLibrary(by: sortType, option: sortOption)
		self.configureEmptyDataView()
		self.rebindLibraryObserver()
	}

	/// Applies a new sort selection and refetches the library in the background.
	///
	/// - Parameters:
	///    - sortType: The new sort type to apply.
	///    - option: The new sort option that refines the sort type.
	func sortLibrary(by sortType: LibrarySortType, option: LibrarySortOption) {
		self.librarySortType = sortType
		self.librarySortTypeOption = option
		self.entries = []

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchLibrary()
		}
	}
}
