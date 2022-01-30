//
//  EpisodesCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension EpisodesCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [EpisodeLockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Episode>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Episode) -> UICollectionViewCell? in
			guard let episodesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.episodeLockupCollectionViewCell, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.episodeLockupCollectionViewCell.identifier)")
			}
			episodesCollectionViewCell.delegate = self
			episodesCollectionViewCell.episode = item
			return episodesCollectionViewCell
		}
	}

	override func updateDataSource() {
		let episodes = self.shouldHideFillers ? self.episodes.filter({ episode in
			!episode.attributes.isFiller
		}) : self.episodes
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Episode>()
		snapshot.appendSections([.main])
		snapshot.appendItems(episodes, toSection: .main)
		dataSource.apply(snapshot)
	}
}
