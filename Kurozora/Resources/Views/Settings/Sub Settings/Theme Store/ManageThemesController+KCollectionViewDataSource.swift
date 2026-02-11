//
//  ManageThemesController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension ManageThemesCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [ThemesCollectionViewCell.self]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, _: Int) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let themesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ThemesCollectionViewCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(ThemesCollectionViewCell.reuseID)")
			}

			themesCollectionViewCell.delegate = self

			if indexPath.section == 0 {
				themesCollectionViewCell.kTheme = KTheme(rawValue: indexPath.item) ?? .kurozora
			} else {
				themesCollectionViewCell.kTheme = KTheme.other(self.appThemes[indexPath.item])
			}

			return themesCollectionViewCell
		}
		self.dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			// Get a supplementary view of the desired kind.
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.configure(withTitle: indexPath.section == 0 ? Trans.default : Trans.premium, indexPath: indexPath, segueID: nil)

			// Return the view.
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
		var identifierOffset = 0
		var itemsPerSection = 0

		SectionLayoutKind.allCases.forEach { section in
			switch section {
			case .default:
				itemsPerSection = KTheme.defaultCases.count
				snapshot.appendSections([section])
				let maxIdentifier = identifierOffset + itemsPerSection
				snapshot.appendItems(Array(identifierOffset ..< maxIdentifier), toSection: section)
			case .premium:
				itemsPerSection = self.appThemes.count
				if itemsPerSection > 0 {
					snapshot.appendSections([section])
					let maxIdentifier = identifierOffset + itemsPerSection
					snapshot.appendItems(Array(identifierOffset ..< maxIdentifier), toSection: section)
				}
			}

			identifierOffset += itemsPerSection
		}
		self.dataSource.apply(snapshot)
	}
}
