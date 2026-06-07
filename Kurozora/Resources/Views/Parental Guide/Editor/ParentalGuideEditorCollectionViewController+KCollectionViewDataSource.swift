//
//  ParentalGuideEditorCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ParentalGuideEditorCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			RatingSegmentedCollectionViewCell.self,
			FrequencySegmentedCollectionViewCell.self,
			DepictionSegmentedCollectionViewCell.self,
			ReasonTextCollectionViewCell.self,
			SpoilerToggleCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let ratingCellRegistration = UICollectionView.CellRegistration<RatingSegmentedCollectionViewCell, AnyHashable> { [weak self] cell, _, _ in
			cell.configure(selected: self?.rating, delegate: self)
		}

		let frequencyCellRegistration = UICollectionView.CellRegistration<FrequencySegmentedCollectionViewCell, AnyHashable> { [weak self] cell, _, _ in
			cell.configure(selected: self?.frequency, delegate: self)
		}

		let depictionCellRegistration = UICollectionView.CellRegistration<DepictionSegmentedCollectionViewCell, AnyHashable> { [weak self] cell, _, _ in
			cell.configure(selected: self?.depiction, delegate: self)
		}

		let reasonCellRegistration = UICollectionView.CellRegistration<ReasonTextCollectionViewCell, AnyHashable> { [weak self] cell, _, _ in
			cell.configure(text: self?.reason ?? "", delegate: self)
		}

		let spoilerCellRegistration = UICollectionView.CellRegistration<SpoilerToggleCollectionViewCell, Bool> { [weak self] cell, _, isOn in
			cell.configure(isOn: isOn, delegate: self)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.collectionView) { [weak self] collectionView, indexPath, itemKind in
			guard let self = self else { return nil }

			switch itemKind {
			case .ratingPicker:
				return collectionView.dequeueConfiguredReusableCell(using: ratingCellRegistration, for: indexPath, item: AnyHashable(ItemKind.ratingPicker))
			case .frequencyPicker:
				return collectionView.dequeueConfiguredReusableCell(using: frequencyCellRegistration, for: indexPath, item: AnyHashable(ItemKind.frequencyPicker))
			case .depictionPicker:
				return collectionView.dequeueConfiguredReusableCell(using: depictionCellRegistration, for: indexPath, item: AnyHashable(ItemKind.depictionPicker))
			case .reasonEditor:
				return collectionView.dequeueConfiguredReusableCell(using: reasonCellRegistration, for: indexPath, item: AnyHashable(ItemKind.reasonEditor))
			case .spoilerToggle:
				return collectionView.dequeueConfiguredReusableCell(using: spoilerCellRegistration, for: indexPath, item: self.isSpoiler)
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

		self.snapshot.appendSections([.rating])
		self.snapshot.appendItems([.ratingPicker], toSection: .rating)

		let hasSeverity = self.rating != nil && self.rating != ParentalGuideRating.none

		if hasSeverity {
			self.snapshot.appendSections([.frequency])
			self.snapshot.appendItems([.frequencyPicker], toSection: .frequency)

			if self.category?.supportsDepiction == true {
				self.snapshot.appendSections([.depiction])
				self.snapshot.appendItems([.depictionPicker], toSection: .depiction)
			}
		}

		self.snapshot.appendSections([.reason])
		self.snapshot.appendItems([.reasonEditor, .spoilerToggle], toSection: .reason)

		self.dataSource.apply(self.snapshot, animatingDifferences: false)
	}
}
