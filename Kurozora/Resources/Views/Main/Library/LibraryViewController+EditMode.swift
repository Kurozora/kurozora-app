//
//  LibraryViewController+EditMode.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension LibraryViewController {
	// MARK: - Properties
	/// A boolean value that indicates whether the batch toolbar items should be visually clustered.
	private var shouldClusterBatchToolbarItems: Bool {
		return self.traitCollection.horizontalSizeClass == .regular
	}

	// MARK: - View
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		(self.currentViewController as? LibraryListCollectionViewController)?.setEditing(editing, animated: animated)

		if editing {
			self.enterBatchEditChrome(animated: animated)
		} else {
			self.exitBatchEditChrome(animated: animated)
		}
	}

	// MARK: - Chrome
	/// Activates the batch-edit chrome.
	///
	/// Saves the current bar items, swaps in select-all, cancel and overflow controls, hides
	/// the kind toolbar and tab bar, and reveals the bottom toolbar populated with batch actions.
	///
	/// - Parameter animated: A boolean value that indicates whether the chrome change is animated.
	func enterBatchEditChrome(animated: Bool) {
		guard !self.batchEditChromeIsActive else { return }
		self.batchEditChromeIsActive = true

		self.savedRightBarButtonItems = self.navigationItem.rightBarButtonItems
		self.savedLeftBarButtonItems = self.navigationItem.leftBarButtonItems

		self.refreshSelectAllBarButtonItem(allSelected: false, hasItems: (self.currentViewController as? LibraryListCollectionViewController)?.totalLibraryItemsCount ?? 0 > 0)
		self.navigationItem.leftBarButtonItems = [self.selectAllBarButtonItem]
		self.navigationItem.rightBarButtonItems = [self.cancelEditingBarButtonItem, self.batchOverflowBarButtonItem]

		self.toolbar.isHidden = true
		self.bar.isHidden = true
		self.bar.isUserInteractionEnabled = false
		self.isScrollEnabled = false

		if !(self.tabBarController?.tabBar.isHidden ?? true) {
			self.didHideTabBarForEdit = true
			if #available(iOS 18.0, *) {
				self.tabBarController?.setTabBarHidden(true, animated: animated)
			} else {
				self.tabBarController?.tabBar.isHidden = true
				self.view.setNeedsLayout()
				self.view.layoutIfNeeded()
			}
		}

		self.toolbarItems = self.makeBatchToolbarItems()
		self.refreshBatchActionToolbar(selectedIndexPaths: [])
		self.navigationController?.setToolbarHidden(false, animated: animated)
		self.applyEditModeContentInsets(active: true)
	}

	/// Deactivates the batch-edit chrome.
	///
	/// Restores the saved bar items, re-shows the kind toolbar and tab bar, and hides the
	/// bottom toolbar.
	///
	/// - Parameter animated: A boolean value that indicates whether the chrome change is animated.
	func exitBatchEditChrome(animated: Bool) {
		guard self.batchEditChromeIsActive else { return }
		self.batchEditChromeIsActive = false

		self.navigationItem.leftBarButtonItems = self.savedLeftBarButtonItems
		self.navigationItem.rightBarButtonItems = self.savedRightBarButtonItems

		self.toolbar.isHidden = (self.viewedUser == nil)
		self.bar.isHidden = false
		self.bar.isUserInteractionEnabled = true
		self.isScrollEnabled = true

		if self.didHideTabBarForEdit {
			self.didHideTabBarForEdit = false

			if #available(iOS 18.0, *) {
				self.tabBarController?.setTabBarHidden(false, animated: animated)
			} else {
				self.tabBarController?.tabBar.isHidden = false
				self.view.setNeedsLayout()
				self.view.layoutIfNeeded()
			}
		}

		self.navigationController?.setToolbarHidden(true, animated: animated)
		self.toolbarItems = nil
		self.applyEditModeContentInsets(active: false)
	}

	/// Updates each list page's content insets to reflect which bars are visible.
	///
	/// - Parameter active: A boolean value that indicates whether the batch-edit chrome is active.
	private func applyEditModeContentInsets(active: Bool) {
		let topInset: CGFloat = active ? 0.0 : 50.0
		let bottomInset: CGFloat = active ? 0.0 : 60.0

		for viewController in self.viewControllers {
			guard let listViewController = viewController as? LibraryListCollectionViewController else { continue }
			listViewController.collectionView.contentInset.top = topInset
			listViewController.collectionView.contentInset.bottom = bottomInset
			listViewController.collectionView.scrollIndicatorInsets = listViewController.collectionView.contentInset
		}
	}

	/// Returns the bar button items that populate the bottom toolbar in batch-edit mode.
	///
	/// The layout adapts to the horizontal size class: regular widths cluster the actions
	/// around a centered count label, while compact widths spread them across the toolbar.
	///
	/// - Returns: An ordered list of bar button items including flexible spacers.
	func makeBatchToolbarItems() -> [UIBarButtonItem] {
		let countItem = UIBarButtonItem(customView: self.selectionCountLabel)
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			countItem.hidesSharedBackground = true
		}

		if self.shouldClusterBatchToolbarItems {
			return [
				.flexibleSpace(),
				self.statusBatchBarButtonItem,
				countItem,
				self.deleteBatchBarButtonItem,
				.flexibleSpace(),
			]
		}

		return [
			self.statusBatchBarButtonItem,
			.flexibleSpace(),
			countItem,
			.flexibleSpace(),
			self.deleteBatchBarButtonItem,
		]
	}

	/// Updates the select-all bar button item's title, action and enabled state.
	///
	/// - Parameters:
	///    - allSelected: A boolean value that indicates whether every loaded item is selected.
	///    - hasItems: A boolean value that indicates whether the current page has any selectable items.
	private func refreshSelectAllBarButtonItem(allSelected: Bool, hasItems: Bool) {
		self.selectAllBarButtonItem.title = allSelected ? L10n.deselectAll : L10n.selectAll
		self.selectAllBarButtonItem.isEnabled = hasItems
		self.selectAllBarButtonItem.primaryAction = UIAction(title: self.selectAllBarButtonItem.title ?? "") { [weak self] _ in
			guard let currentSection = self?.currentViewController as? LibraryListCollectionViewController else { return }
			if allSelected {
				currentSection.deselectAllVisibleItems()
			} else {
				currentSection.selectAllLoadedItems()
			}
		}
	}

	// MARK: - Selection observation
	/// Refreshes the batch toolbar and select-all control to reflect the current selection.
	///
	/// - Parameters:
	///    - viewController: The list whose selection changed.
	///    - selectedIndexPaths: The set of currently-selected index paths.
	func libraryListViewController(_ viewController: LibraryListCollectionViewController, didUpdateSelection selectedIndexPaths: [IndexPath]) {
		guard self.batchEditChromeIsActive else { return }

		self.refreshBatchActionToolbar(selectedIndexPaths: selectedIndexPaths)

		let totalLoaded = viewController.loadedItemCount
		let allSelected = totalLoaded > 0 && selectedIndexPaths.count >= totalLoaded
		self.refreshSelectAllBarButtonItem(allSelected: allSelected, hasItems: totalLoaded > 0)
	}

	// MARK: - Toolbar verbs
	/// Updates the count label and rebuilds the menus on the batch toolbar items.
	///
	/// The menus are rebuilt on every call so each `UIAction` closure captures the latest
	/// selected index paths.
	///
	/// - Parameter selectedIndexPaths: The set of currently-selected index paths.
	private func refreshBatchActionToolbar(selectedIndexPaths: [IndexPath]) {
		let count = selectedIndexPaths.count
		let hasSelection = count > 0

		self.selectionCountLabel.text = hasSelection ? L10n.itemsSelected(count) : L10n.selectItems

		self.statusBatchBarButtonItem.isEnabled = hasSelection
		self.deleteBatchBarButtonItem.isEnabled = hasSelection
		self.batchOverflowBarButtonItem.isEnabled = hasSelection

		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else {
			return
		}

		self.statusBatchBarButtonItem.menu = self.makeBatchStatusMenu(currentSection: currentSection, selectedIndexPaths: selectedIndexPaths)
		self.batchOverflowBarButtonItem.menu = self.makeBatchOverflowMenu(currentSection: currentSection, selectedIndexPaths: selectedIndexPaths)
		self.deleteBatchBarButtonItem.menu = self.makeBatchDeleteMenu(currentSection: currentSection, selectedIndexPaths: selectedIndexPaths)
	}

	/// Returns the overflow menu containing the favorite, reminder and hide toggles.
	///
	/// The toggle titles and symbols flip based on the current state of the selected items,
	/// matching the smart-toggle behavior of Apple's Photos app.
	///
	/// - Parameters:
	///    - currentSection: The list view controller that owns the selected items.
	///    - selectedIndexPaths: The set of currently-selected index paths.
	///
	/// - Returns: A menu with one element per available batch action.
	private func makeBatchOverflowMenu(currentSection: LibraryListCollectionViewController, selectedIndexPaths: [IndexPath]) -> UIMenu {
		let anyUnfavorited = currentSection.anySelectedIsUnfavorited(at: selectedIndexPaths)
		let favoriteTitle = anyUnfavorited ? L10n.favorite : L10n.unfavorite
		let favoriteImage = UIImage(systemName: anyUnfavorited ? "heart" : "heart.slash")
		let favoriteAction = UIAction(title: favoriteTitle, image: favoriteImage) { [weak self] _ in
			self?.performBatchFavoriteUpdate(currentSection: currentSection, selectedIndexPaths: selectedIndexPaths, favorited: anyUnfavorited)
		}

		var children: [UIMenuElement] = [favoriteAction]

		if self.libraryKind == .shows {
			let anyUnreminded = currentSection.anySelectedIsUnreminded(at: selectedIndexPaths)
			let reminderTitle = anyUnreminded ? L10n.remindMe : L10n.stopReminding
			let reminderImage = UIImage(systemName: anyUnreminded ? "bell" : "bell.slash")
			let reminderAction = UIAction(title: reminderTitle, image: reminderImage) { [weak self] _ in
				self?.performBatchReminderUpdate(currentSection: currentSection, selectedIndexPaths: selectedIndexPaths, reminded: anyUnreminded)
			}
			children.append(reminderAction)
		}

		let anyVisible = currentSection.anySelectedIsVisible(at: selectedIndexPaths)
		let hideTitle = anyVisible ? L10n.hide : L10n.reveal
		let hideImage = UIImage(systemName: anyVisible ? "eye.slash" : "eye")
		let hideAction = UIAction(title: hideTitle, image: hideImage) { [weak self] _ in
			self?.performBatchHideToggle(currentSection: currentSection, selectedIndexPaths: selectedIndexPaths, hide: anyVisible)
		}
		children.append(hideAction)

		return UIMenu(title: "", children: children)
	}

	/// Returns a menu listing every library status the selected items can be moved to.
	///
	/// - Parameters:
	///    - currentSection: The list view controller that owns the selected items.
	///    - selectedIndexPaths: The set of currently-selected index paths.
	///
	/// - Returns: A menu with one action per library status.
	private func makeBatchStatusMenu(currentSection: LibraryListCollectionViewController, selectedIndexPaths: [IndexPath]) -> UIMenu {
		let actions = LibraryStatus.all.map { status -> UIAction in
			let title: String
			switch self.libraryKind {
			case .shows: title = status.showStringValue
			case .literatures: title = status.literatureStringValue
			case .games: title = status.gameStringValue
			}
			return UIAction(title: title) { [weak self] _ in
				self?.performBatchStatusChange(to: status, currentSection: currentSection, selectedIndexPaths: selectedIndexPaths)
			}
		}
		return UIMenu(title: L10n.moveTo, children: actions)
	}

	/// Returns a destructive confirmation menu for removing the selected items from the library.
	///
	/// Uses a primary destructive menu instead of a presented alert to keep the confirmation
	/// anchored to the toolbar item.
	///
	/// - Parameters:
	///    - currentSection: The list view controller that owns the selected items.
	///    - selectedIndexPaths: The set of currently-selected index paths.
	///
	/// - Returns: A destructive menu containing the delete confirmation action.
	private func makeBatchDeleteMenu(currentSection: LibraryListCollectionViewController, selectedIndexPaths: [IndexPath]) -> UIMenu {
		let count = selectedIndexPaths.count
		let buttonTitle: String = L10n.deleteItems(count)
		let message: String = L10n.deleteItemsConfirmation(count)

		let confirmAction = UIAction(title: buttonTitle, image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
			self?.performBatchDelete(currentSection: currentSection, selectedIndexPaths: selectedIndexPaths)
		}
		return UIMenu(title: message, options: .destructive, children: [confirmAction])
	}

	// MARK: - Batch operations
	/// Moves the selected items to the given library status.
	///
	/// - Parameters:
	///    - newStatus: The library status to move the selected items to.
	///    - currentSection: The list view controller that owns the selected items.
	///    - selectedIndexPaths: The set of currently-selected index paths.
	private func performBatchStatusChange(to newStatus: LibraryStatus, currentSection: LibraryListCollectionViewController, selectedIndexPaths: [IndexPath]) {
		guard let slug = User.current?.attributes.slug else { return }
		let currentStatus = currentSection.libraryStatus
		let trackableIDs = selectedIndexPaths.compactMap { currentSection.entries[safe: $0.item]?.trackableID }

		Task { [weak self] in
			guard let self = self else { return }

			for trackableID in trackableIDs {
				await LibraryOutbox.shared.enqueueSetStatus(newStatus, trackableID: trackableID, userSlug: slug, kind: self.libraryKind, seed: nil)
			}

			if newStatus != currentStatus {
				currentSection.removeEntries(withTrackableIDs: Set(trackableIDs))
			}

			self.setEditing(false, animated: true)
		}
	}

	/// Toggles the favorite state of the selected items to the given value.
	///
	/// Items already at the target state are skipped.
	///
	/// - Parameters:
	///    - currentSection: The list view controller that owns the selected items.
	///    - selectedIndexPaths: The set of currently-selected index paths.
	///    - favorited: The target favorite state to apply to the items.
	private func performBatchFavoriteUpdate(currentSection: LibraryListCollectionViewController, selectedIndexPaths: [IndexPath], favorited: Bool) {
		let trackableIDs = selectedIndexPaths.compactMap { indexPath -> String? in
			guard let entry = currentSection.entries[safe: indexPath.item], entry.isFavorited != favorited else { return nil }
			return entry.trackableID
		}
		guard !trackableIDs.isEmpty else { return }
		guard let slug = User.current?.attributes.slug else { return }

		Task { [weak self] in
			guard let self = self else { return }

			for trackableID in trackableIDs {
				await LibraryOutbox.shared.enqueueSetFavorite(favorited, trackableID: trackableID, userSlug: slug, kind: self.libraryKind)
			}

			self.setEditing(false, animated: true)
		}
	}

	/// Toggles the reminder state of the selected items to the given value.
	///
	/// Items already at the target state are skipped.
	///
	/// - Parameters:
	///    - currentSection: The list view controller that owns the selected items.
	///    - selectedIndexPaths: The set of currently-selected index paths.
	///    - reminded: The target reminder state to apply to the items.
	private func performBatchReminderUpdate(currentSection: LibraryListCollectionViewController, selectedIndexPaths: [IndexPath], reminded: Bool) {
		let trackableIDs = selectedIndexPaths.compactMap { indexPath -> String? in
			guard let entry = currentSection.entries[safe: indexPath.item], entry.isReminded != reminded else { return nil }
			return entry.trackableID
		}
		guard !trackableIDs.isEmpty else { return }
		guard let slug = User.current?.attributes.slug else { return }

		Task { [weak self] in
			guard let self = self else { return }

			for trackableID in trackableIDs {
				await LibraryOutbox.shared.enqueueSetReminder(reminded, trackableID: trackableID, userSlug: slug, kind: self.libraryKind)
			}

			self.setEditing(false, animated: true)
		}
	}

	/// Toggles the hidden state of the selected items to the given value.
	///
	/// - Parameters:
	///    - currentSection: The list view controller that owns the selected items.
	///    - selectedIndexPaths: The set of currently-selected index paths.
	///    - hide: A boolean value that indicates whether the items should be hidden.
	private func performBatchHideToggle(currentSection: LibraryListCollectionViewController, selectedIndexPaths: [IndexPath], hide: Bool) {
		guard let slug = User.current?.attributes.slug else { return }
		let trackableIDs = selectedIndexPaths.compactMap { currentSection.entries[safe: $0.item]?.trackableID }
		guard !trackableIDs.isEmpty else { return }

		Task { [weak self] in
			guard let self = self else { return }

			for trackableID in trackableIDs {
				await LibraryOutbox.shared.enqueueSetHidden(hide, trackableID: trackableID, userSlug: slug, kind: self.libraryKind)
			}

			self.setEditing(false, animated: true)
		}
	}

	/// Removes the selected items from the library and exits edit mode.
	///
	/// - Parameters:
	///    - currentSection: The list view controller that owns the selected items.
	///    - selectedIndexPaths: The set of currently-selected index paths.
	private func performBatchDelete(currentSection: LibraryListCollectionViewController, selectedIndexPaths: [IndexPath]) {
		guard let slug = User.current?.attributes.slug else { return }
		let trackableIDs = selectedIndexPaths.compactMap { currentSection.entries[safe: $0.item]?.trackableID }
		guard !trackableIDs.isEmpty else { return }

		Task { [weak self] in
			guard let self = self else { return }

			for trackableID in trackableIDs {
				await LibraryOutbox.shared.enqueueRemove(trackableID: trackableID, userSlug: slug, kind: self.libraryKind)
			}

			currentSection.removeEntries(withTrackableIDs: Set(trackableIDs))
			self.setEditing(false, animated: true)
		}
	}
}
