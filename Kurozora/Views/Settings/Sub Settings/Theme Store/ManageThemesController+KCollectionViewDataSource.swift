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

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			if let themesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.themesCollectionViewCell, for: indexPath) {
				themesCollectionViewCell.delegate = self
				themesCollectionViewCell.indexPath = indexPath
				themesCollectionViewCell.theme = self.themes[indexPath.section][indexPath.item]
				return themesCollectionViewCell
			} else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.themesCollectionViewCell.identifier)")
			}
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
		SectionLayoutKind.allCases.forEach {
			let itemsPerSection = ($0 == .def ? self.themes.first?.count : self.themes.last?.count) ?? 0
			snapshot.appendSections([$0])
			let itemOffset = $0.rawValue * itemsPerSection
			let itemUpperbound = itemOffset + itemsPerSection
			snapshot.appendItems(Array(itemOffset..<itemUpperbound))
		}
		dataSource.apply(snapshot)
	}
}
