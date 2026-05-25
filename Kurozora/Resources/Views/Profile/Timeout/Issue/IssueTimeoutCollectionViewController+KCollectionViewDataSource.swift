//
//  IssueTimeoutCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension IssueTimeoutCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			IssueTimeoutMenuCollectionViewCell.self,
			IssueTimeoutNoteCollectionViewCell.self,
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let durationRegistration = UICollectionView.CellRegistration<IssueTimeoutMenuCollectionViewCell, ItemKind> { [weak self] cell, _, _ in
			guard let self = self else { return }
			cell.configure(
				title: L10n.issueTimeoutDurationTitle,
				selectionTitle: Self.localizedTitle(for: self.selectedDuration),
				menu: self.makeDurationMenu()
			)
		}

		let reasonRegistration = UICollectionView.CellRegistration<IssueTimeoutMenuCollectionViewCell, ItemKind> { [weak self] cell, _, _ in
			guard let self = self else { return }
			cell.configure(
				title: L10n.issueTimeoutReasonTitle,
				selectionTitle: Self.localizedTitle(for: self.selectedReason),
				menu: self.makeReasonMenu()
			)
		}

		let noteRegistration = UICollectionView.CellRegistration<IssueTimeoutNoteCollectionViewCell, ItemKind> { [weak self] cell, _, _ in
			guard let self = self else { return }
			cell.configure(text: self.note, placeholder: L10n.issueTimeoutNotePlaceholder, delegate: self)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, itemKind in
			switch itemKind {
			case .durationRow:
				return collectionView.dequeueConfiguredReusableCell(using: durationRegistration, for: indexPath, item: itemKind)
			case .reasonRow:
				return collectionView.dequeueConfiguredReusableCell(using: reasonRegistration, for: indexPath, item: itemKind)
			case .noteEditor:
				return collectionView.dequeueConfiguredReusableCell(using: noteRegistration, for: indexPath, item: itemKind)
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
			guard let self = self else { return nil }

			let sectionIdentifier = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.configure(withTitle: sectionIdentifier.stringValue, indexPath: indexPath, segueID: nil)

			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		self.snapshot.appendSections([.timeout])
		self.snapshot.appendItems([.durationRow, .reasonRow], toSection: .timeout)

		self.snapshot.appendSections([.note])
		self.snapshot.appendItems([.noteEditor], toSection: .note)

		self.dataSource.apply(self.snapshot, animatingDifferences: false)
	}
}
