//
//  LibraryListCollectionViewController+CellLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

// MARK: - Compact Layout Title Visibility
extension LibraryListCollectionViewController {
	/// Persists the given compact-layout title visibility,
	///
	/// - Parameter visibility: The newly selected compact-layout title visibility.
	func applyCompactTitleVisibility(_ visibility: LibraryCompactTitleVisibility) {
		self.libraryCompactTitleVisibility = visibility

		if self.user == nil {
			UserSettings.setLibraryCompactTitleVisibility(visibility, for: self.libraryKind, status: self.libraryStatus)
		}

		self.reconfigureAllSnapshotItems()

		if let tabmanParent = self.tabmanParent as? LibraryViewController {
			tabmanParent.refreshMoreButtonMenu()
		}
	}
}

// MARK: - LibraryTableCollectionViewCellDelegate
extension LibraryListCollectionViewController: LibraryTableCollectionViewCellDelegate {
	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didToggleFavoriteAt indexPath: IndexPath) {
		Task { [weak self] in
			guard let self = self, let entry = self.entries[safe: indexPath.item] else { return }

			await self.toggleFavorite(for: entry)
			self.reconfigureAllSnapshotItems()
		}
	}

	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didToggleReminderAt indexPath: IndexPath) {
		Task { [weak self] in
			guard let self = self, let entry = self.entries[safe: indexPath.item] else { return }

			await self.toggleReminder(for: entry)
			self.reconfigureAllSnapshotItems()
		}
	}

	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didToggleVisibilityAt indexPath: IndexPath) {
		Task { [weak self] in
			guard let self = self, let entry = self.entries[safe: indexPath.item] else { return }

			await self.toggleVisibility(for: entry)
			self.reconfigureAllSnapshotItems()
		}
	}

	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didUpdateRating rating: Double, at indexPath: IndexPath) {
		Task { [weak self] in
			guard let self = self, let entry = self.entries[safe: indexPath.item] else { return }

			await self.rate(entry, score: rating)
			self.reconfigureAllSnapshotItems()
		}
	}

	// MARK: - Helpers
	/// Calls the toggle-favorite endpoint for the given entry and mirrors the result into the local store.
	///
	/// - Parameter entry: The local library entry to toggle.
	private func toggleFavorite(for entry: LocalLibraryEntry) async {
		guard let slug = User.current?.attributes.slug else { return }
		let itemID = KurozoraItemID(entry.trackableID)
		let kind = entry.kind

		do {
			let response = try await KService.toggleFavorite(inLibrary: kind, itemIDs: [itemID]).response()
			let isFavorited = response.data.favoriteStatus == .favorited
			LibraryStore.shared.applyFavorite(isFavorited, forTrackableID: itemID.rawValue, userSlug: slug, kind: kind)
		} catch {
			print("Toggle favorite failed: \(error.localizedDescription)")
		}
	}

	/// Calls the toggle-reminder endpoint for the given entry and mirrors the result into the local store.
	///
	/// - Parameter entry: The local library entry to toggle.
	private func toggleReminder(for entry: LocalLibraryEntry) async {
		guard let slug = User.current?.attributes.slug else { return }
		let itemID = KurozoraItemID(entry.trackableID)
		let kind = entry.kind

		do {
			let response = try await KService.toggleReminder(inLibrary: kind, itemIDs: [itemID]).response()
			let isReminded = response.data.reminderStatus == .reminded
			LibraryStore.shared.applyReminder(isReminded, forTrackableID: itemID.rawValue, userSlug: slug, kind: kind)
		} catch {
			print("Toggle reminder failed: \(error.localizedDescription)")
		}
	}

	/// Flips the entry's hidden flag against the network and mirrors the result into the local store.
	///
	/// - Parameter entry: The local library entry to toggle.
	private func toggleVisibility(for entry: LocalLibraryEntry) async {
		guard let slug = User.current?.attributes.slug else { return }
		let itemID = KurozoraItemID(entry.trackableID)
		let kind = entry.kind
		let nextHidden = !entry.isHidden

		do {
			_ = try await KService.updateInLibrary(kind, itemIDs: [itemID]).hidden(nextHidden).response()
			entry.isHidden = nextHidden
			entry.updatedAt = Date()
			PersistenceController.shared.save(PersistenceController.shared.viewContext)
		} catch {
			print("Toggle visibility failed: \(error.localizedDescription)")
		}
	}

	/// Submits a rating for the given entry and mirrors the result into the local store.
	///
	/// - Parameters:
	///    - entry: The local library entry being rated.
	///    - score: The star rating from `0` to `5`.
	private func rate(_ entry: LocalLibraryEntry, score: Double) async {
		guard let slug = User.current?.attributes.slug else { return }
		let itemID = KurozoraItemID(entry.trackableID)
		let kind = entry.kind

		do {
			switch kind {
			case .shows:
				_ = try await KService.rate(ShowIdentity(id: itemID), score: score).description(nil).response()
			case .literatures:
				_ = try await KService.rate(LiteratureIdentity(id: itemID), score: score).description(nil).response()
			case .games:
				_ = try await KService.rate(GameIdentity(id: itemID), score: score).description(nil).response()
			}
			LibraryStore.shared.applyRating(score: score, description: nil, forTrackableID: itemID.rawValue, userSlug: slug, kind: kind)
		} catch {
			print("Rating update failed: \(error.localizedDescription)")
		}
	}
}

// MARK: - LibraryTableHeaderReusableViewDelegate
extension LibraryListCollectionViewController: LibraryTableHeaderReusableViewDelegate {
	func tableHeader(_ header: LibraryTableHeaderReusableView, isResizing column: LibraryColumn, to width: CGFloat) {
		for cell in self.collectionView.visibleCells.compactMap({ $0 as? LibraryTableCollectionViewCell }) {
			cell.updateColumnWidth(column, to: width)
		}
	}

	func tableHeader(_ header: LibraryTableHeaderReusableView, didResize column: LibraryColumn, to width: CGFloat) {
		var updated = self.libraryColumnPreferences
		updated.widths[column] = width

		self.applyColumnPreferences(updated, reloadVisibleRows: true)
	}

	func tableHeader(_ header: LibraryTableHeaderReusableView, didReorderColumnsTo columnOrder: [LibraryColumn]) {
		var updated = self.libraryColumnPreferences

		let visibleSet = Set(columnOrder)
		var newOrder = updated.order
		var visibleIndex = 0

		for index in newOrder.indices where visibleSet.contains(newOrder[index]) {
			guard visibleIndex < columnOrder.count else { break }

			newOrder[index] = columnOrder[visibleIndex]
			visibleIndex += 1
		}
		updated.order = newOrder

		self.applyColumnPreferences(updated, reloadVisibleRows: true)
	}

	func tableHeader(_ header: LibraryTableHeaderReusableView, autoFitWidthFor column: LibraryColumn) -> CGFloat? {
		var maxContentWidth: CGFloat = column.minWidth
		maxContentWidth = max(maxContentWidth, header.headerContentWidth(for: column))

		switch column {
		case .favorite, .reminder, .visibility, .rating:
			return max(maxContentWidth, column.defaultWidth)
		default:
			break
		}

		for cell in self.collectionView.visibleCells.compactMap({ $0 as? LibraryTableCollectionViewCell }) {
			maxContentWidth = max(maxContentWidth, cell.contentWidth(for: column))
		}

		// Measure every loaded entry
		let showPoster = self.libraryColumnPreferences.showPoster

		for entry in self.entries {
			let text = LibraryTableCollectionViewCell.text(for: column, entry: entry)
			guard !text.isEmpty else { continue }
			maxContentWidth = max(maxContentWidth, LibraryTableCollectionViewCell.fittedWidth(forText: text, column: column, showPoster: showPoster))
		}

		return maxContentWidth
	}
}

// MARK: - Column Preference Management
extension LibraryListCollectionViewController {
	/// Persists the given preferences and refreshes the table-layout chrome and rows.
	///
	/// - Parameters:
	///    - preferences: The new preferences to persist for the current `(kind, status)` pair.
	///    - reloadVisibleRows: A boolean that indicates whether visible rows should be reconfigured to pick up changes to the column set or widths.
	///                         Pass `false` to skip the row refresh when only non-rendering state changed.
	func applyColumnPreferences(_ preferences: LibraryColumnPreferences, reloadVisibleRows: Bool) {
		let styleBefore = self.effectiveCellStyleForCurrentEnvironment()
		let showPosterChanged = preferences.showPoster != self.libraryColumnPreferences.showPoster

		self.libraryColumnPreferences = preferences

		if self.user == nil {
			UserSettings.setLibraryColumnPreferences(preferences, for: self.libraryKind, status: self.libraryStatus)
		}

		let styleAfter = self.effectiveCellStyleForCurrentEnvironment()
		let cellClassChanged = styleBefore != styleAfter

		self.refreshTableHeader()

		if showPosterChanged || cellClassChanged {
			self.collectionView.collectionViewLayout.invalidateLayout()
		}

		if reloadVisibleRows {
			if cellClassChanged {
				// `snapshot.reconfigureItems` asserts that the new cell shares the existing
				// cell's reuse identifier, but when the style toggles between table and list,
				// the classes differ, so fall back to a full reload.
				self.collectionView.reloadData()
			} else {
				self.reconfigureAllSnapshotItems()
			}
		}

		if let tabmanParent = self.tabmanParent as? LibraryViewController {
			tabmanParent.refreshMoreButtonMenu()
		}
	}

	/// Reconfigures every item in the current snapshot without animating a reload.
	func reconfigureAllSnapshotItems() {
		guard self.dataSource != nil else {
			return
		}

		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems(snapshot.itemIdentifiers)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Pushes the current visible columns into the pinned table header.
	func refreshTableHeader() {
		guard let header = self.visibleTableHeader() else {
			return
		}

		header.configure(columns: self.visibleColumnsWithWidths())
	}

	/// Returns the pinned table header attached to the collection view, if one is visible.
	private func visibleTableHeader() -> LibraryTableHeaderReusableView? {
		for subview in self.collectionView.subviews {
			if let header = subview as? LibraryTableHeaderReusableView {
				return header
			}
		}
		return nil
	}
}
