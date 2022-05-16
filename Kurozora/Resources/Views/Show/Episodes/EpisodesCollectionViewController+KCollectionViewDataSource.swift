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
	override func configureDataSource() {
		let episodeCellRegistration = UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, EpisodeIdentity>(cellNib: UINib(resource: R.nib.episodeLockupCollectionViewCell)) { [weak self] episodeLockupCollectionViewCell, indexPath, episodeIdentity in
			guard let self = self else { return }
			let episode = self.fetchEpisode(at: indexPath)
			var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? episodeLockupCollectionViewCell.dataRequest

			if dataRequest == nil && episode == nil {
				dataRequest = KService.getDetails(forEpisode: episodeIdentity) { [weak self] result in
					switch result {
					case .success(let episodes):
						self?.episodes[indexPath] = episodes.first
						self?.setEpisodeNeedsUpdate(episodeIdentity)
					case .failure: break
					}
				}
			}

			episodeLockupCollectionViewCell.dataRequest = dataRequest
			episodeLockupCollectionViewCell.delegate = self
			episodeLockupCollectionViewCell.configure(using: episode)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, EpisodeIdentity>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, episodeIdentity: EpisodeIdentity) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: episodeCellRegistration, for: indexPath, item: episodeIdentity)
		}
	}

	override func updateDataSource() {
		let episodeIdentities = self.shouldHideFillers ? self.dataSource.snapshot().itemIdentifiers.filter({ [weak self] episodeIdentity in
			guard let self = self else { return false }
			return !(self.episodes.values.first(where: { episode in
				episode.id == episodeIdentity.id
			})?.attributes.isFiller ?? false)
		}) : self.episodeIdentities
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, EpisodeIdentity>()
		snapshot.appendSections([.main])
		snapshot.appendItems(episodeIdentities, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	func fetchEpisode(at indexPath: IndexPath) -> Episode? {
		guard let episode = self.episodes[indexPath] else { return nil }
		return episode
	}

	func setEpisodeNeedsUpdate(_ episodeIdentity: EpisodeIdentity) {
		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems([episodeIdentity])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
