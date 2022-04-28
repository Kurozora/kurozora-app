//
//  GenresCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/08/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension GenresCollectionViewController {
	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Genre>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Genre) -> UICollectionViewCell? in
			let genreLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: GenreLockupCollectionViewCell.self, for: indexPath)
			genreLockupCollectionViewCell.genre = item
			return genreLockupCollectionViewCell
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
