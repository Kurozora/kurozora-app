//
//  KotodamaArchiveCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension KotodamaArchiveCollectionViewController {
	override func configureDataSource() {
		let archiveCellRegistration = self.getConfiguredArchiveCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, KotodamaArchiveEntry>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			collectionView.dequeueConfiguredReusableCell(using: archiveCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, KotodamaArchiveEntry>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.entries)
		self.snapshot = snapshot
		self.dataSource.apply(snapshot) { [weak self] in
			guard let self = self else { return }
			self.toggleEmptyDataView()
		}
	}
}

// MARK: - UICollectionViewDelegate
extension KotodamaArchiveCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		guard let entry = self.dataSource.itemIdentifier(for: indexPath) else { return }

		self.openPuzzle(for: entry)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard self.nextCursor != nil, indexPath.item == self.entries.count - 1 else { return }

		Task { [weak self] in
			await self?.fetchEntries(resetting: false)
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let entry = self.dataSource.itemIdentifier(for: indexPath),
			  let date = Self.dateFormatter.date(from: entry.attributes.puzzleDate ?? "")
		else { return nil }

		return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: {
			KotodamaGameViewController(puzzle: .archive(date))
		})
	}
}
