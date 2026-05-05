//
//  ParentalGuideCategoryEntriesCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ParentalGuideCategoryEntriesCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [ParentalGuideReasonCollectionViewCell.self]
	}

	override func configureDataSource() {
		let reasonCellRegistration = UICollectionView.CellRegistration<ParentalGuideReasonCollectionViewCell, ParentalGuideEntry> { [weak self] cell, _, entry in
			let isExpanded = self?.expandedEntryIDs.contains(entry.id) ?? false
			cell.configure(using: entry, isExpanded: isExpanded)
			cell.delegate = self
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, itemKind in
			switch itemKind {
			case .entry(let entry):
				return collectionView.dequeueConfiguredReusableCell(using: reasonCellRegistration, for: indexPath, item: entry)
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		let items = self.entries.map { ItemKind.entry($0) }
		self.snapshot.appendItems(items, toSection: .main)

		self.dataSource.apply(self.snapshot, animatingDifferences: true)
	}
}
