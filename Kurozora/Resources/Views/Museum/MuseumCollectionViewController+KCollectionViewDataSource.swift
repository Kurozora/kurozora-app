//
//  MuseumCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension MuseumCollectionViewController {
	override func configureDataSource() {
		let museumPosterCellConfiguration = self.getConfiguredMuseumPosterCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: museumPosterCellConfiguration, for: indexPath, item: itemKind)
		}

		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		for museumYear in self.museumYears {
			let sectionLayoutKind: SectionLayoutKind = .year(museumYear)
			self.snapshot.appendSections([sectionLayoutKind])

			if let museumEntries = self.entriesByYear[museumYear.year] {
				let itemKinds: [ItemKind] = museumEntries.map { museumEntry in
					.museumEntry(museumEntry, year: museumYear.year)
				}
				self.snapshot.appendItems(itemKinds, toSection: sectionLayoutKind)
			} else {
				let skeletonCount = min(museumYear.count, 10)
				let itemKinds: [ItemKind] = (0 ..< skeletonCount).map { index in
					.pending(year: museumYear.year, index: index)
				}
				self.snapshot.appendItems(itemKinds, toSection: sectionLayoutKind)
			}
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: false)
		self.toggleEmptyDataView()
	}

	/// Replaces a year's skeleton items with the entries fetched so far.
	///
	/// - Parameters:
	///    - year: The year whose section to hydrate.
	///    - museumEntries: The year's entries fetched so far.
	///    - hasMorePages: Whether more pages are on the way.
	func hydrateSection(for year: Int, with museumEntries: [MuseumEntry], hasMorePages: Bool = false) {
		var snapshot = self.dataSource.snapshot()

		guard let sectionLayoutKind = snapshot.sectionIdentifiers.first(where: { sectionLayoutKind in
			switch sectionLayoutKind {
			case .year(let museumYear):
				return museumYear.year == year
			}
		}) else { return }

		var itemKinds: [ItemKind] = museumEntries.map { museumEntry in
			.museumEntry(museumEntry, year: year)
		}

		if hasMorePages {
			itemKinds.append(contentsOf: (0 ..< 10).map { index in
				.pending(year: year, index: museumEntries.count + index)
			})
		}

		snapshot.deleteItems(snapshot.itemIdentifiers(inSection: sectionLayoutKind))
		snapshot.appendItems(itemKinds, toSection: sectionLayoutKind)

		let followingIndexPath = self.indexPathFollowing(sectionLayoutKind, in: snapshot)
		let followingMinX = followingIndexPath.flatMap { indexPath in
			self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)?.frame.minX
		}

		self.snapshot = snapshot
		self.dataSource.apply(snapshot, animatingDifferences: false)

		if self.pinnedYear != nil {
			self.restorePinnedYear()
		} else if let followingIndexPath = followingIndexPath, let followingMinX = followingMinX {
			self.collectionView.layoutIfNeeded()

			if let hydratedMinX = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: followingIndexPath)?.frame.minX {
				self.collectionView.contentOffset.x += hydratedMinX - followingMinX
			}
		}

		self.syncActiveYear()
	}

	/// The first item of the section after the given one, when that section starts behind the hall's leading edge.
	///
	/// - Parameters:
	///    - sectionLayoutKind: The section about to change width.
	///    - snapshot: The snapshot the section belongs to.
	///
	/// - Returns: The index path the hall anchors on.
	private func indexPathFollowing(_ sectionLayoutKind: SectionLayoutKind, in snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>) -> IndexPath? {
		guard let sectionIndex = snapshot.indexOfSection(sectionLayoutKind) else { return nil }
		guard sectionIndex + 1 < snapshot.numberOfSections else { return nil }

		let leadingEdgeX = self.collectionView.contentOffset.x + self.collectionView.adjustedContentInset.left
		let sectionIndexPath = IndexPath(item: 0, section: sectionIndex)
		guard let sectionMinX = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: sectionIndexPath)?.frame.minX else { return nil }
		guard sectionMinX < leadingEdgeX else { return nil }

		return IndexPath(item: 0, section: sectionIndex + 1)
	}
}
