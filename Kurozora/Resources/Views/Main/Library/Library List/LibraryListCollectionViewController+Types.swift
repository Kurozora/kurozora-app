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
	func libraryListViewController(updateSortWith sortType: KKLibrary.SortType, sortOption: KKLibrary.SortType.Option)

	/// Tells the delegate that the total number of items in the library has changed.
	///
	/// - Parameter totalCount: The updated total item count for the current status page.
	func libraryListViewController(updateTotalCount totalCount: Int)
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
		/// The item contains a ``Show`` value.
		case show(_: Show)

		/// The item contains a ``Literature`` value.
		case literature(_: Literature)

		/// The item contains a ``Game`` value.
		case game(_: Game)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .show(let show):
				hasher.combine(show)
			case .literature(let literature):
				hasher.combine(literature)
			case .game(let game):
				hasher.combine(game)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.show(let show1), .show(let show2)):
				return show1 == show2
			case (.literature(let literature1), .literature(let literature2)):
				return literature1 == literature2
			case (.game(let game1), .game(let game2)):
				return game1 == game2
			default:
				return false
			}
		}
	}
}

// MARK: - LibraryViewControllerDataSource
extension LibraryListCollectionViewController: LibraryViewControllerDataSource {
	/// The sort type currently applied to the library list.
	///
	/// - Returns: The ``KKLibrary/SortType`` in effect for this status page.
	func sortValue() -> KKLibrary.SortType {
		return self.librarySortType
	}

	/// The sort option currently refining the sort type.
	///
	/// - Returns: The ``KKLibrary/SortType/Option`` in effect for this status page.
	func sortOptionValue() -> KKLibrary.SortType.Option {
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
	func libraryViewController(_ view: LibraryViewController, didChange libraryKind: KKLibrary.Kind) {
		let (sortType, sortOption) = UserSettings.librarySortTypes[libraryKind]?[self.libraryStatus] ?? (KKLibrary.SortType.none, KKLibrary.SortType.Option.none)

		self.libraryKind = libraryKind
		self.libraryCellStyle = UserSettings.libraryCellStyle(for: libraryKind, status: self.libraryStatus)
		self.libraryColumnPreferences = UserSettings.libraryColumnPreferences(for: libraryKind, status: self.libraryStatus)

		// Reset data and refetch
		self.nextPageURL = nil
		self.shows = []
		self.literatures = []
		self.games = []
		self.updateDataSource()

		// Refresh view
		self.refreshTableHeader()
		self.collectionView.collectionViewLayout.invalidateLayout()

		self.sortLibrary(by: sortType, option: sortOption)
		self.configureEmptyDataView()
	}

	/// Applies a new sort selection and refetches the library in the background.
	///
	/// - Parameters:
	///    - sortType: The new sort type to apply.
	///    - option: The new sort option that refines the sort type.
	func sortLibrary(by sortType: KKLibrary.SortType, option: KKLibrary.SortType.Option) {
		self.librarySortType = sortType
		self.librarySortTypeOption = option

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchLibrary()
		}
	}
}
