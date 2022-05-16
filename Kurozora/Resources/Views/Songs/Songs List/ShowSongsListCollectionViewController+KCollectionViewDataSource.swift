//
//  ShowSongsListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ShowSongsListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			MusicLockupCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [
			TitleHeaderCollectionReusableView.self
		]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			let showIDExists = self.showIdentity != nil

			switch item {
			case .showSong(let showSong, _):
				let musicLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: MusicLockupCollectionViewCell.self, for: indexPath)
				musicLockupCollectionViewCell.delegate = self
				musicLockupCollectionViewCell.configure(using: showSong, at: indexPath, showEpisodes: showIDExists, showShow: !showIDExists)
				return musicLockupCollectionViewCell
			}
		}

		if self.showIdentity != nil {
			self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
				guard let self = self else { return nil }
				guard let songType = SongType(rawValue: indexPath.section) else { return nil }

					// Get a supplementary view of the desired kind.
				let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
				exploreSectionTitleCell.delegate = self
				exploreSectionTitleCell.configure(withTitle: "\(songType.stringValue) (\(self.showSongCategories[songType]?.count ?? 0))")
				return exploreSectionTitleCell
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		if self.showIdentity != nil {
			SongType.allCases.forEach { songType in
				if self.showSongCategories.has(key: songType) {
					let sectionHeader = SectionLayoutKind.header()
					self.snapshot.appendSections([sectionHeader])

					if let showSongCategory = self.showSongCategories[songType] {
						let showSongItems: [ItemKind] = showSongCategory.map { showSong in
							return .showSong(showSong)
						}
						self.snapshot.appendItems(showSongItems, toSection: sectionHeader)
					}
				}
			}
		} else {
			let sectionHeader = SectionLayoutKind.header()
			self.snapshot.appendSections([sectionHeader])

			let showSongItems: [ItemKind] = self.showSongs.map { showSong in
				return .showSong(showSong)
			}
			self.snapshot.appendItems(showSongItems, toSection: sectionHeader)
		}

		self.dataSource.apply(self.snapshot)
	}
}
