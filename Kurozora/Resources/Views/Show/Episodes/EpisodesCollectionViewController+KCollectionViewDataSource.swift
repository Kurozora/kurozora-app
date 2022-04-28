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
		return []
	}

	override func configureDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, EpisodeIdentity>(cellNib: UINib(resource: R.nib.episodeLockupCollectionViewCell)) { [weak self] episodeLockupCollectionViewCell, indexPath, episodeIdentity in
			guard let self = self else { return }
			let episode = self.fetchEpisode(at: indexPath)

			// Retrieve the token that's tracking this asset from either the prefetching operations dictionary
			// or just use a token that's already set on the cell, which is the case when a cell is being reconfigured.
			var episodeDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? episodeLockupCollectionViewCell.episodeDataRequest

			// If the asset is a placeholder and there is no token, ask the asset store to load it, reconfiguring
			// the cell in its completion handler.
			if episodeDataRequest == nil && episode == nil {
				episodeDataRequest = KService.getDetails(forEpisode: episodeIdentity) { result in
					// After the episode fetching completes, trigger a reconfigure for the item so the cell can be updated if
					// it is visible.
					switch result {
					case .success(let episodes):
						self.episodes[indexPath] = episodes.first
						self.setEpisodeNeedsUpdate(episodeIdentity)
					case .failure: break
					}
				}
			}

			episodeLockupCollectionViewCell.episodeDataRequest = episodeDataRequest
			episodeLockupCollectionViewCell.delegate = self
			episodeLockupCollectionViewCell.configureCell(using: episode)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, EpisodeIdentity>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: EpisodeIdentity) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
		}
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
}
