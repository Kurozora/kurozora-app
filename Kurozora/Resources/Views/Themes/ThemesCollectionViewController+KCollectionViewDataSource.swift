//
//  ThemesCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/01/2022.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ThemesCollectionViewController {
	override func configureDataSource() {
		let genreCellRegistration = self.getConfiguredGenreCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Theme>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			collectionView.dequeueConfiguredReusableCell(using: genreCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Theme>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.themes)
		self.snapshot = snapshot
		self.dataSource.apply(snapshot) { [weak self] in
			guard let self = self else { return }
			self.toggleEmptyDataView()
		}
	}
}
