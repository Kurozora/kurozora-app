//
//  EpisodesListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension EpisodesListCollectionViewController {
	override func configureDataSource() {
		let episodeCellRegistration = self.getConfiguredEpisodeCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: episodeCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		// Filter filler episodes if needed
		let episodes = (self.cache as? [IndexPath: Episode]) ?? [:]
		let visibleEpisodeIdentities: [EpisodeIdentity] = {
			guard self.shouldHideFillers else {
				return self.episodeIdentities
			}

			let fillerIDs = episodes.values
				.filter { $0.attributes.isFiller }
				.map { $0.id }

			return self.episodeIdentities.filter { !fillerIDs.contains($0.id) }
		}()

		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		// Append items
		switch self.episodesListFetchType {
		case .search, .season, .upNext:
			let episodeItems: [ItemKind] = visibleEpisodeIdentities.map { episodeIdentity in
				.episodeIdentity(episodeIdentity)
			}
			self.snapshot.appendItems(episodeItems, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}
}
