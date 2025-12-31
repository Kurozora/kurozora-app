//
//  GenresCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/08/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension GenresCollectionViewController {
	override func configureDataSource() {
		let genreCellRegistration = self.getConfiguredGenreCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Genre>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			collectionView.dequeueConfiguredReusableCell(using: genreCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Genre>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.genres)
		self.snapshot = snapshot
		self.dataSource.apply(snapshot) { [weak self] in
			guard let self = self else { return }
			self.toggleEmptyDataView()
		}
	}
}
