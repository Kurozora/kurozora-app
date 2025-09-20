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
	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [
			TitleHeaderCollectionReusableView.self
		]
	}

	override func configureDataSource() {
		let musicCellConfiguration = self.getConfiguredMusicCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: musicCellConfiguration, for: indexPath, item: itemKind)
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
				if self.showSongCategories.index(forKey: songType) != nil {
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
		} else if !self.showSongs.isEmpty {
			let sectionHeader = SectionLayoutKind.header()
			self.snapshot.appendSections([sectionHeader])

			let showSongItems: [ItemKind] = self.showSongs.map { showSong in
				return .showSong(showSong)
			}
			self.snapshot.appendItems(showSongItems, toSection: sectionHeader)
		} else if !self.songs.isEmpty {
			let sectionHeader = SectionLayoutKind.header()
			self.snapshot.appendSections([sectionHeader])

			let songItems: [ItemKind] = self.songs.map { song in
				return .song(song)
			}
			self.snapshot.appendItems(songItems, toSection: sectionHeader)
		}

		self.dataSource.apply(self.snapshot)
	}
}

extension ShowSongsListCollectionViewController {
	func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.musicLockupCollectionViewCell)) { [weak self] musicLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			musicLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .showSong(let showSong, _):
				let showIDExists = self.showIdentity != nil
				musicLockupCollectionViewCell.configure(using: showSong, at: indexPath, showEpisodes: showIDExists, showShow: !showIDExists)
			case .song(let song, _):
				musicLockupCollectionViewCell.configure(using: song, at: indexPath)
			}
		}
	}
}
