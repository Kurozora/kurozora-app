//
//  ThemesCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/01/2022.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ThemesCollectionViewController {
	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Theme>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Theme) -> UICollectionViewCell? in
			let themeLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: ThemeLockupCollectionViewCell.self, for: indexPath)
			themeLockupCollectionViewCell.theme = item
			return themeLockupCollectionViewCell
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Theme>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.themes)
		self.snapshot = snapshot
		self.dataSource.apply(snapshot) {
			self.toggleEmptyDataView()
		}
	}
}
