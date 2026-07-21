//
//  LibraryListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit
import UIKit

extension LibraryListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		[
			LibraryDetailedCollectionViewCell.self,
			LibraryCompactCollectionViewCell.self,
			LibraryListCollectionViewCell.self,
			LibraryTableCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		self.collectionView.register(LibraryTableHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: LibraryTableHeaderReusableView.reuseID)

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			let effectiveStyle = self.effectiveCellStyleForCurrentEnvironment()

			if effectiveStyle == .table {
				return self.makeTableCell(for: item, at: indexPath, in: collectionView)
			}

			guard let libraryBaseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: effectiveStyle.identifierString, for: indexPath) as? LibraryBaseCollectionViewCell else {
				fatalError("Cannot dequeue reusable cell with identifier \(effectiveStyle.identifierString)")
			}

			guard case let .entry(entry) = item else { return libraryBaseCollectionViewCell }

			if let compact = libraryBaseCollectionViewCell as? LibraryCompactCollectionViewCell {
				compact.configure(using: entry, showSelectionIcon: self.isEditing, titleVisibility: self.libraryCompactTitleVisibility)
			} else {
				libraryBaseCollectionViewCell.configure(using: entry, showSelectionIcon: self.isEditing)
			}

			return libraryBaseCollectionViewCell
		}

		self.dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
			guard let self = self, kind == UICollectionView.elementKindSectionHeader else { return nil }
			let header = collectionView.dequeueReusableSupplementaryView(
				ofKind: kind,
				withReuseIdentifier: LibraryTableHeaderReusableView.reuseID,
				for: indexPath
			) as? LibraryTableHeaderReusableView

			header?.delegate = self
			header?.configure(columns: self.visibleColumnsWithWidths())

			return header
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		// Dedup objectIDs; overlapping paged reads during a sync batch can duplicate rows.
		var seenObjectIDs = Set<NSManagedObjectID>()
		let items: [ItemKind] = self.entries.compactMap { entry in
			guard seenObjectIDs.insert(entry.objectID).inserted else { return nil }
			return .entry(entry)
		}
		self.snapshot.appendItems(items, toSection: .main)

		self.dataSource.apply(self.snapshot, animatingDifferences: true)
	}

	// MARK: - Helpers
	/// Returns the cell style that drives rendering for the current trait collection.
	///
	/// Falls back from ``LibraryCellStyle/table`` to ``LibraryCellStyle/list`` only when
	/// the horizontal size class is compact.
	///
	/// - Returns: The effective cell style for the current environment.
	func effectiveCellStyleForCurrentEnvironment() -> LibraryCellStyle {
		guard self.libraryCellStyle == .table else {
			return self.libraryCellStyle
		}

		if self.traitCollection.horizontalSizeClass == .compact {
			return .list
		}

		return .table
	}

	/// Returns the `(column, width)` pairs to render in the table layout for the current library kind.
	///
	/// - Returns: The visible columns paired with their resolved widths, in left-to-right order.
	func visibleColumnsWithWidths() -> [(column: LibraryColumn, width: CGFloat)] {
		return self.libraryColumnPreferences.visibleColumns(for: self.libraryKind).map { column in
			(column: column, width: self.libraryColumnPreferences.width(for: column))
		}
	}

	private func makeTableCell(for item: ItemKind, at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryTableCollectionViewCell.reuseID, for: indexPath) as? LibraryTableCollectionViewCell else {
			fatalError("Cannot dequeue reusable cell with identifier \(LibraryTableCollectionViewCell.reuseID)")
		}

		let totalItems = collectionView.numberOfItems(inSection: indexPath.section)
		let isLastRow = indexPath.item == totalItems - 1

		cell.configure(
			using: item,
			kind: self.libraryKind,
			columns: self.visibleColumnsWithWidths(),
			showPoster: self.libraryColumnPreferences.showPoster,
			showSelectionIcon: self.isEditing,
			isLastRow: isLastRow,
			indexPath: indexPath,
			delegate: self
		)

		return cell
	}
}
