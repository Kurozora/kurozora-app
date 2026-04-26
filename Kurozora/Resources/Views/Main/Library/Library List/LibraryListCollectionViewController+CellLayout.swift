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
			guard let self = self, let item = self.libraryItem(at: indexPath) else { return }

			await item.toggleFavorite(on: self)
			self.reconfigureAllSnapshotItems()
		}
	}

	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didToggleReminderAt indexPath: IndexPath) {
		Task { [weak self] in
			guard let self = self, let item = self.libraryItem(at: indexPath) else { return }

			await item.toggleReminder(on: self)
			self.reconfigureAllSnapshotItems()
		}
	}

	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didToggleVisibilityAt indexPath: IndexPath) {
		Task { [weak self] in
			guard let self = self, let item = self.libraryItem(at: indexPath) else { return }

			await item.toggleVisibility(on: self)
			self.reconfigureAllSnapshotItems()
		}
	}

	func libraryTableCell(_ cell: LibraryTableCollectionViewCell, didUpdateRating rating: Double, at indexPath: IndexPath) {
		Task { [weak self] in
			guard let self = self else { return }

			do {
				switch self.libraryKind {
				case .shows:
					guard let show = self.shows[safe: indexPath.item] else { return }
					_ = try await show.rate(using: rating, description: nil)
				case .literatures:
					guard let literature = self.literatures[safe: indexPath.item] else { return }
					_ = try await literature.rate(using: rating, description: nil)
				case .games:
					guard let game = self.games[safe: indexPath.item] else { return }
					_ = try await game.rate(using: rating, description: nil)
				}
			} catch {
				print("Rating update failed: \(error.localizedDescription)")
			}

			self.reconfigureAllSnapshotItems()
		}
	}

	// MARK: - Helpers
	/// Returns the library item at the given index path, typed as ``Libraryable``.
	///
	/// - Parameter indexPath: The index path whose item to resolve.
	///
	/// - Returns: The show, literature, or game at `indexPath`, or `nil` if none exists.
	fileprivate func libraryItem(at indexPath: IndexPath) -> Libraryable? {
		switch self.libraryKind {
		case .shows: return self.shows[safe: indexPath.item]
		case .literatures: return self.literatures[safe: indexPath.item]
		case .games: return self.games[safe: indexPath.item]
		}
	}
}

// MARK: - LibraryTableHeaderReusableViewDelegate
extension LibraryListCollectionViewController: LibraryTableHeaderReusableViewDelegate {
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
		let visibleCells = self.collectionView.visibleCells.compactMap { $0 as? LibraryTableCollectionViewCell }

		guard !visibleCells.isEmpty else { return nil }

		var maxContentWidth: CGFloat = column.minWidth

		for cell in visibleCells {
			maxContentWidth = max(maxContentWidth, cell.contentWidth(for: column))
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
