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
		return [
//			EpisodeLockupCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, EpisodeIdentity>(cellNib: UINib(resource: R.nib.episodeLockupCollectionViewCell)) { [weak self] episodesCollectionViewCell, indexPath, episodeIdentity in
			guard let self = self else { return }
			guard self.episodes[indexPath] != nil else { return }
			guard let episode = self.fetchEpisode(at: indexPath) else { return }
			episodesCollectionViewCell.delegate = self
			episodesCollectionViewCell.configureCell(using: episode)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, EpisodeIdentity>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: EpisodeIdentity) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
		}
	}

	func fetchEpisode(at indexPath: IndexPath) -> Episode? {
		guard let episode = self.episodes[indexPath] else { return nil }
		return episode
	}

	override func updateDataSource() {
//		let episodes = self.shouldHideFillers ? self.episodes.filter({ episode in
//			!episode.attributes.isFiller
//		}) : self.episodes

//		let episodeIdentities = self.shouldHideFillers ? self.episodeIdentities.filter({ episodeIdentity in
//			!(self.episodes[episodeIdentity.id]?.attributes.isFiller ?? false)
//		}) :
		let episodeIdentities = self.episodeIdentities
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, EpisodeIdentity>()
		snapshot.appendSections([.main])
		snapshot.appendItems(episodeIdentities, toSection: .main)
		self.dataSource.apply(snapshot)
	}
}
