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
		return []
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, _: Int) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			if let themesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.themesCollectionViewCell, for: indexPath) {
				themesCollectionViewCell.delegate = self
				if indexPath.section == 0 {
					themesCollectionViewCell.kTheme = KTheme(rawValue: indexPath.item) ?? .kurozora
				} else {
					themesCollectionViewCell.kTheme = KTheme.other(self.appThemes[indexPath.item])
				}
				return themesCollectionViewCell
			} else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.themesCollectionViewCell.identifier)")
			}
		}
		dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			// Get a supplementary view of the desired kind.
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.configure(withTitle: indexPath.section == 0 ? "Default" : "Premium", indexPath: indexPath, segueID: "")

			// Return the view.
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
		var identifierOffset = 0
		var itemsPerSection = 0

		SectionLayoutKind.allCases.forEach {
			itemsPerSection = $0 == .def ? KTheme.defaultCases.count : self.appThemes.count
			snapshot.appendSections([$0])
			let maxIdentifier = identifierOffset + itemsPerSection
			snapshot.appendItems(Array(identifierOffset..<maxIdentifier), toSection: $0)
			identifierOffset += itemsPerSection
		}
		dataSource.apply(snapshot)
	}
}
