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
	/// Enqueues a favorite toggle for the given entry.
	///
	/// - Parameter entry: The local library entry to toggle.
	private func toggleFavorite(for entry: LocalLibraryEntry) async {
		guard let slug = User.current?.attributes.slug else { return }
		let desired = !entry.isFavorited
		await LibraryOutbox.shared.enqueueSetFavorite(desired, trackableID: entry.trackableID, userSlug: slug, kind: entry.kind)
	}

	/// Enqueues a reminder toggle for the given entry.
	///
	/// - Parameter entry: The local library entry to toggle.
	private func toggleReminder(for entry: LocalLibraryEntry) async {
		guard let slug = User.current?.attributes.slug else { return }
		let desired = !entry.isReminded
		await LibraryOutbox.shared.enqueueSetReminder(desired, trackableID: entry.trackableID, userSlug: slug, kind: entry.kind)
	}

	/// Enqueues a hidden-flag flip for the given entry.
	///
	/// - Parameter entry: The local library entry to toggle.
	private func toggleVisibility(for entry: LocalLibraryEntry) async {
		guard let slug = User.current?.attributes.slug else { return }
		let desired = !entry.isHidden
		await LibraryOutbox.shared.enqueueSetHidden(desired, trackableID: entry.trackableID, userSlug: slug, kind: entry.kind)
	}

	/// Enqueues a rating submission for the given entry.
	///
	/// - Parameters:
	///    - entry: The local library entry being rated.
	///    - score: The star rating from `0` to `5`.
	private func rate(_ entry: LocalLibraryEntry, score: Double) async {
		guard let slug = User.current?.attributes.slug else { return }
		await LibraryOutbox.shared.enqueueRate(score: score, description: nil, trackableID: entry.trackableID, userSlug: slug, kind: entry.kind)
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

	/// Reconfigures every item in the current snapshot.
	///
	/// - Parameter animated: A boolean value that indicates whether applying the snapshot animates differences.
	func reconfigureAllSnapshotItems(animated: Bool = false) {
		guard self.dataSource != nil else {
			return
		}

		self.snapshot = self.dataSource.snapshot()
		self.snapshot.reconfigureItems(self.snapshot.itemIdentifiers)
		self.dataSource.apply(self.snapshot, animatingDifferences: animated)
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
