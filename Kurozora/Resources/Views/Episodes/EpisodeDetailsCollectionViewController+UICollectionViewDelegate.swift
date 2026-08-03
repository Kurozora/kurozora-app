//
//  EpisodeDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension EpisodeDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .badge:
			guard let episodeDetailBadge = EpisodeDetail.Badge(rawValue: indexPath.item) else { return }
			switch episodeDetailBadge {
			case .rating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.rating) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: 0, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .season:
				guard let showIdentity = self.episode.relationships?.shows?.data.first else { return }
				self.show(.seasonsListSegue, sender: showIdentity)
				return
			case .rank:
				self.show(.topChartsSegue, sender: nil)
				return
			case .previousEpisode:
				guard let previousEpisode = self.episode.relationships?.previousEpisodes?.data.first else { return }
				self.show(.episodeDetailsSegue, sender: previousEpisode)
				return
			case .nextEpisode:
				guard let nextEpisode = self.episode.relationships?.nextEpisodes?.data.first else { return }
				self.show(.episodeDetailsSegue, sender: nextEpisode)
				return
			case .show:
				guard let showIdentity = self.episode.relationships?.shows?.data.first else { return }
				self.show(.showDetailsSegue, sender: showIdentity)
				return
			}
		case .cast:
			guard let character = self.cast[indexPath]?.relationships.characters.data.first else { return }
			self.show(.characterDetailsSegue, sender: character)
		case .suggestedEpisodes:
			let suggestedEpisode = self.suggestedEpisodes[indexPath.item]
			self.show(.episodeDetailsSegue, sender: suggestedEpisode)
		case .reviews:
			guard let review = self.reviews[safe: indexPath.item] else { return }
			self.present(.reviewDetailsSegue, sender: review)
		default: return
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .header, .badge, .synopsis, .rateAndReview, .rating, .information, .sosumi:
			return nil
		case .reviews:
			return self.reviews[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .cast:
			return self.cast[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .suggestedEpisodes:
			return self.suggestedEpisodes[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}
