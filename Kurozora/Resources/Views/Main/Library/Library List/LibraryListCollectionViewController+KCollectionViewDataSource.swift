//
//  LibraryListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension LibraryListCollectionViewController {
	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let libraryBaseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.libraryCellStyle.identifierString, for: indexPath) as? LibraryBaseCollectionViewCell else {
				fatalError("Cannot dequeue reusable cell with identifier \(self.libraryCellStyle.identifierString)")
			}
			switch item {
			case .show(let show, _):
				libraryBaseCollectionViewCell.configure(using: show)
			case .literature(let literature, _):
				libraryBaseCollectionViewCell.configure(using: literature)
			case .game(let game, _):
				libraryBaseCollectionViewCell.configure(using: game)
			}
			return libraryBaseCollectionViewCell
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])

		switch UserSettings.libraryKind {
		case .shows:
			let shows: [ItemKind] = self.shows.map { show in
				return .show(show)
			}
			snapshot.appendItems(shows, toSection: .main)
		case .literatures:
			let literatures: [ItemKind] = self.literatures.map { literature in
				return .literature(literature)
			}
			snapshot.appendItems(literatures, toSection: .main)
		}

		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
