//
//  LibraryListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension LibraryListCollectionViewController {
	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let libraryBaseCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.libraryCellStyle.identifierString, for: indexPath) as? LibraryBaseCollectionViewCell else {
				fatalError("Cannot dequeue reusable cell with identifier \(self.libraryCellStyle.identifierString)")
			}
			switch item {
			case .show(let show):
				libraryBaseCollectionViewCell.configure(using: show, showSelectionIcon: self.isEditing)
			case .literature(let literature):
				libraryBaseCollectionViewCell.configure(using: literature, showSelectionIcon: self.isEditing)
			case .game(let game):
				libraryBaseCollectionViewCell.configure(using: game, showSelectionIcon: self.isEditing)
			}
			return libraryBaseCollectionViewCell
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		switch UserSettings.libraryKind {
		case .shows:
			let shows: [ItemKind] = self.shows.map { show in
				.show(show)
			}
			self.snapshot.appendItems(shows, toSection: .main)
		case .literatures:
			let literatures: [ItemKind] = self.literatures.map { literature in
				.literature(literature)
			}
			self.snapshot.appendItems(literatures, toSection: .main)
		case .games:
			let games: [ItemKind] = self.games.map { game in
				.game(game)
			}
			self.snapshot.appendItems(games, toSection: .main)
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: true)
	}
}
