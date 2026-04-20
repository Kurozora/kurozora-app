//
//  LibraryViewController+Actions.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import Pageboy
import Tabman
import UIKit

extension LibraryViewController {
	/// Enables or disables the navigation bar items in response to the current sign-in state.
	func enableActions() {
		guard let index = self.currentIndex else { return }

		self.moreBarButtonItem.menu = self.viewedUser?.makeLibraryContextMenu(in: self, userInfo: [
			"includeUser": self.user != nil,
			"index": index,
			"libraryKind": self.libraryKind.rawValue,
		], sourceView: nil, barButtonItem: self.moreBarButtonItem)
		self.populateSortActions()

		if self.viewedUser == nil {
			self.toolbar.isHidden = true

			self.navigationItem.rightBarButtonItems = nil
			self.navigationItem.leftBarButtonItems = nil
		} else if self.viewedUser != User.current {
			self.toolbar.isHidden = false

			self.navigationItem.rightBarButtonItems = [
				self.moreBarButtonItem
			]

			self.navigationItem.leftItemsSupplementBackButton = true
			self.navigationItem.leftBarButtonItems = [
				self.sortTypeBarButtonItem
			]
		} else {
			self.toolbar.isHidden = false

			var rightItems: [UIBarButtonItem] = []

			if let profileBarButtonItem = self.profileBarButtonItem {
				rightItems.append(profileBarButtonItem)
			}

			rightItems.append(self.moreBarButtonItem)
			self.navigationItem.rightBarButtonItems = rightItems

			self.navigationItem.leftItemsSupplementBackButton = true
			self.navigationItem.leftBarButtonItems = [
				self.sortTypeBarButtonItem,
				self.searchBarButtonItem
			]
		}
	}

	/// Presents a search screen locked to the library scope as a sheet.
	func presentLibrarySearch() {
		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			let searchResultsCollectionViewController = SearchResultsCollectionViewController()
			searchResultsCollectionViewController.searchViewKind = .library

			let kNavigationController = KNavigationController(rootViewController: searchResultsCollectionViewController)
			kNavigationController.modalPresentationStyle = .pageSheet
			self.present(kNavigationController, animated: true)
		}
	}

	/// Rebuilds the layout menu so that its checkmarks reflect the currently visible page's persisted cell style.
	///
	/// - Parameter index: The index of the status page whose layout menu should be shown.
	func updateLayoutMenuAction(for index: Int?) {
		guard let index = index, let viewedUser = self.viewedUser else { return }

		self.moreBarButtonItem.menu = viewedUser.makeLibraryContextMenu(in: self, userInfo: [
			"includeUser": self.user != nil,
			"index": index,
			"libraryKind": self.libraryKind.rawValue,
		], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	/// Updates the sort button's title and icon so they describe the active sort selection.
	///
	/// - Parameters:
	///    - sortType: The sort type currently in effect.
	///    - option: The sort option that refines the sort type.
	func updateSortTypeBarButtonItem(sortType: KKLibrary.SortType, option: KKLibrary.SortType.Option) {
		self.sortTypeBarButtonItem.title = "Sorting by \(sortType.stringValue) (\(option.stringValue))"
		self.sortTypeBarButtonItem.image = sortType == .none
			? UIImage(systemName: "line.3.horizontal.decrease.circle")
			: UIImage(systemName: "line.3.horizontal.decrease.circle.fill")
	}

	/// Pushes the given column preferences into the currently visible library status page.
	///
	/// - Parameter preferences: The updated column preferences to apply and persist.
	func applyColumnPreferencesToCurrentSection(_ preferences: KKLibrary.ColumnPreferences) {
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else {
			return
		}

		currentSection.applyColumnPreferences(preferences, reloadVisibleRows: true)
	}

	/// Pushes the given compact-layout title visibility into the currently visible library status page.
	///
	/// - Parameter visibility: The updated compact-layout title visibility to apply and persist.
	func applyCompactTitleVisibilityToCurrentSection(_ visibility: KKLibrary.CompactTitleVisibility) {
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else {
			return
		}

		currentSection.applyCompactTitleVisibility(visibility)
	}

	/// Rebuilds the more-button's menu so its checkmarks reflect the latest column preferences.
	func refreshMoreButtonMenu() {
		self.updateLayoutMenuAction(for: self.currentIndex)
	}

	/// Changes the layout of the currently visible library status page.
	///
	/// - Parameter libraryCellStyle: The newly selected ``KKLibrary/CellStyle``.
	func changeLayout(to libraryCellStyle: KKLibrary.CellStyle) {
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else { return }

		currentSection.libraryCellStyle = libraryCellStyle

		if self.user == nil {
			UserSettings.setLibraryCellStyle(libraryCellStyle, for: self.libraryKind, status: currentSection.libraryStatus)
		}

		self.updateLayoutMenuAction(for: self.currentIndex)

		UIView.animate(withDuration: 0.2) {
			currentSection.collectionView.reloadData()
		}
	}

	/// Rebuilds the sort menu, reflecting the sort value reported by the data source.
	func populateSortActions() {
		var menuItems: [UIMenuElement] = []

		KKLibrary.SortType.allCases.forEach { [weak self] sortType in
			guard let self = self else {
				return
			}

			var subMenuItems: [UIAction] = []
			let sortTypeSelected = self.libraryViewControllerDataSource?.sortValue() == sortType

			for option in sortType.optionValue {
				let sortOptionSelected = self.libraryViewControllerDataSource?.sortOptionValue() == option
				let actionIsOn = sortTypeSelected && sortOptionSelected

				let action = UIAction(title: option.stringValue, image: option.imageValue, state: actionIsOn ? .on : .off) { _ in
					self.libraryViewControllerDelegate?.sortLibrary(by: sortType, option: option)
					self.populateSortActions()
				}
				subMenuItems.append(action)
			}

			let submenu = UIMenu(title: sortType.stringValue, image: sortType.imageValue, children: subMenuItems)
			menuItems.append(submenu)
		}

		if let sortValue = self.libraryViewControllerDataSource?.sortValue(), sortValue != .none {
			let stopSortingAction = UIAction(title: "Stop sorting", image: UIImage(systemName: "xmark.circle.fill"), attributes: .destructive) { [weak self] _ in
				guard let self = self else {
					return
				}

				self.libraryViewControllerDelegate?.sortLibrary(by: .none, option: .none)
				self.populateSortActions()
			}
			let stopSortingMenu = UIMenu(title: "", options: .displayInline, children: [stopSortingAction])

			menuItems.append(stopSortingMenu)
		}

		self.sortTypeBarButtonItem.menu = UIMenu(title: "", children: menuItems)
	}

	#if targetEnvironment(macCatalyst)
	/// Scrolls the pager to the page chosen from the Touch Bar tab picker.
	///
	/// - Parameter touchBarItem: The picker that emitted the selection change.
	@objc func goToSelectedView(_ touchBarItem: NSPickerTouchBarItem) {
		self.bar.delegate?.bar(self.bar, didRequestScrollTo: touchBarItem.selectedIndex)
		self.populateSortActions()
	}
	#endif

	/// Handles selection changes in the library-kind segmented control.
	///
	/// - Parameter libraryKind: The newly selected library kind.
	func libraryKindSegmentedControlDidChange(to libraryKind: KKLibrary.Kind) {
		self.libraryKind = libraryKind
		self.bar.reloadData(at: 0 ... KKLibrary.Status.all.count - 1, context: .full)

		if self.user == nil {
			UserSettings.set(libraryKind.rawValue, forKey: .libraryKind)
		}

		self.libraryViewControllerDelegate?.libraryViewController(self, didChange: libraryKind)

		self.populateSortActions()
		self.refreshMoreButtonMenu()
	}
}

// MARK: - LibraryListViewControllerDelegate
extension LibraryViewController: LibraryListViewControllerDelegate {
	func libraryListViewController(willScrollTo index: Int) {
		self.updateLayoutMenuAction(for: index)
	}

	func libraryListViewController(updateSortWith sortType: KKLibrary.SortType, sortOption: KKLibrary.SortType.Option) {
		self.updateSortTypeBarButtonItem(sortType: sortType, option: sortOption)
	}

	func libraryListViewController(updateTotalCount totalCount: Int) {
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 9.0, *) {
			self.navigationItem.subtitle = totalCount > 0 ? "\(totalCount) Items" : nil
		} else {
			self.navigationItem.title = "\(L10n.library)\(totalCount > 0 ? " (\(totalCount))" : "")"
		}
	}
}

// MARK: - KTabbedViewControllerDataSource
extension LibraryViewController {
	override func initializeViewControllers(with count: Int) -> [UIViewController] {
		var viewControllers: [UIViewController] = []

		for index in 0 ..< count {
			let libraryListCollectionViewController = LibraryListCollectionViewController()
			let libraryStatus = KKLibrary.Status.all[index]

			libraryListCollectionViewController.libraryCellStyle = UserSettings.libraryCellStyle(for: self.libraryKind, status: libraryStatus)

			libraryListCollectionViewController.libraryStatus = libraryStatus
			libraryListCollectionViewController.sectionIndex = index
			libraryListCollectionViewController.user = self.user
			libraryListCollectionViewController.delegate = self
			viewControllers.append(libraryListCollectionViewController)
		}

		return viewControllers
	}
}
