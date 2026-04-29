//
//  LibraryListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

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

			if let compact = libraryBaseCollectionViewCell as? LibraryCompactCollectionViewCell {
				let titleVisibility = self.libraryCompactTitleVisibility

				switch item {
				case .show(let show):
					compact.configure(using: show, showSelectionIcon: self.isEditing, titleVisibility: titleVisibility)
				case .literature(let literature):
					compact.configure(using: literature, showSelectionIcon: self.isEditing, titleVisibility: titleVisibility)
				case .game(let game):
					compact.configure(using: game, showSelectionIcon: self.isEditing, titleVisibility: titleVisibility)
				}
			} else {
				switch item {
				case .show(let show):
					libraryBaseCollectionViewCell.configure(using: show, showSelectionIcon: self.isEditing)
				case .literature(let literature):
					libraryBaseCollectionViewCell.configure(using: literature, showSelectionIcon: self.isEditing)
				case .game(let game):
					libraryBaseCollectionViewCell.configure(using: game, showSelectionIcon: self.isEditing)
				}
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

		switch self.libraryKind {
		case .shows:
			let shows: [ItemKind] = self.shows.map { show in
				.show(show)
			}
			self.snapshot.appendItems(shows, toSection: .main)
		case .literatures:
			let literatures: [ItemKind] = self.literatures.map { literature in
				.literature(literature)
			}
			self.snapshot.appendItems(literatures, toSection: .main)
		case .games:
			let games: [ItemKind] = self.games.map { game in
				.game(game)
			}
			self.snapshot.appendItems(games, toSection: .main)
		}

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
