//
//  ParentalGuideCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ParentalGuideCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			ParentalGuideSummaryCardCollectionViewCell.self,
			ParentalGuideReasonCollectionViewCell.self,
			ParentalGuideEmptyCategoryCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let summaryCardRegistration = UICollectionView.CellRegistration<ParentalGuideSummaryCardCollectionViewCell, ItemKind> { [weak self] cell, _, _ in
			guard let self = self else { return }
			cell.configure(rows: self.summaryRows())
		}

		let reasonCellRegistration = UICollectionView.CellRegistration<ParentalGuideReasonCollectionViewCell, ParentalGuideEntry> { [weak self] cell, _, entry in
			let isExpanded = self?.expandedEntryIDs.contains(entry.id) ?? false
			cell.configure(using: entry, isExpanded: isExpanded)
			cell.delegate = self
		}

		let emptyRegistration = UICollectionView.CellRegistration<ParentalGuideEmptyCategoryCollectionViewCell, ParentalGuideCategory> { cell, _, _ in
			cell.configure()
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, itemKind in
			switch itemKind {
			case .summaryCard:
				return collectionView.dequeueConfiguredReusableCell(using: summaryCardRegistration, for: indexPath, item: itemKind)
			case .entry(let entry):
				return collectionView.dequeueConfiguredReusableCell(using: reasonCellRegistration, for: indexPath, item: entry)
			case .empty(let category):
				return collectionView.dequeueConfiguredReusableCell(using: emptyRegistration, for: indexPath, item: category)
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
			guard let self = self else { return nil }
			let sectionIdentifier = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)

			let segueID: (any SegueIdentifier)?
			let subtitle: String?

			switch sectionIdentifier {
			case .summary:
				segueID = nil
				subtitle = nil
			case .category(let category):
				segueID = SegueIdentifiers.parentalGuideCategoryEntriesSegue
				subtitle = self.sentimentSubtitle(for: category)
			}

			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionIdentifier.stringValue, subtitle, indexPath: indexPath, segueID: segueID)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		self.snapshot.appendSections([.summary])
		self.snapshot.appendItems([.summaryCard], toSection: .summary)

		ParentalGuideCategory.allCases.forEach { [weak self] category in
			guard let self = self else { return }
			let section = SectionLayoutKind.category(category)
			self.snapshot.appendSections([section])

			let entries = self.entries(for: category)

			if entries.isEmpty {
				self.snapshot.appendItems([.empty(category)], toSection: section)
			} else {
				let items: [ItemKind] = entries.prefix(Self.maxEntriesPerCategory).map { .entry($0) }
				self.snapshot.appendItems(items, toSection: section)
			}
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: true)
	}
}
