//
//  ReportCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ReportCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			ReportReasonOptionCollectionViewCell.self,
			ReportDetailsTextCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let reasonOptionRegistration = UICollectionView.CellRegistration<ReportReasonOptionCollectionViewCell, ReportOption> { [weak self] cell, _, option in
			cell.configure(title: option.title, isSelected: self?.selectedOption == option)
		}

		let detailsRegistration = UICollectionView.CellRegistration<ReportDetailsTextCollectionViewCell, AnyHashable> { [weak self] cell, _, _ in
			guard let self = self else { return }

			let placeholder = self.selectedOption?.requiresDetails == true
				? L10n.reportDetailsPlaceholderRequired
				: L10n.reportDetailsPlaceholder

			cell.configure(text: self.details, placeholder: placeholder, delegate: self)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, itemKind in
			switch itemKind {
			case .reasonOption(let option):
				return collectionView.dequeueConfiguredReusableCell(using: reasonOptionRegistration, for: indexPath, item: option)
			case .detailsEditor:
				return collectionView.dequeueConfiguredReusableCell(using: detailsRegistration, for: indexPath, item: AnyHashable(ItemKind.detailsEditor))
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

		self.snapshot.appendSections([.reason])
		self.snapshot.appendItems((self.subject?.options ?? []).map { ItemKind.reasonOption($0) }, toSection: .reason)

		self.snapshot.appendSections([.details])
		self.snapshot.appendItems([.detailsEditor], toSection: .details)

		self.dataSource.apply(self.snapshot, animatingDifferences: false)
	}
}
