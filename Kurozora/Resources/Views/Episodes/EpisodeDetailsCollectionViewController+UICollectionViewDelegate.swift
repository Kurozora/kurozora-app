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
				guard let seasonIdentity = self.episode.relationships?.seasons?.data.first else { return }
				self.performSegue(withIdentifier: R.segue.episodeDetailsCollectionViewController.seasonsListSegue.identifier, sender: seasonIdentity)
				return
			case .rank:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: EpisodeDetail.Information.number.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .previousEpisode:
				guard let previousEpisode = self.episode.relationships?.previousEpisodes?.data.first else { return }
				self.performSegue(withIdentifier: R.segue.episodeDetailsCollectionViewController.episodeDetailsSegue.identifier, sender: previousEpisode)
				return
			case .nextEpisode:
				guard let nextEpisode = self.episode.relationships?.nextEpisodes?.data.first else { return }
				self.performSegue(withIdentifier: R.segue.episodeDetailsCollectionViewController.episodeDetailsSegue.identifier, sender: nextEpisode)
				return
			case .show:
				guard let show = self.episode.relationships?.shows?.data.first else { return }
				self.performSegue(withIdentifier: R.segue.episodeDetailsCollectionViewController.showDetailsSegue.identifier, sender: show)
				return
			}
		case .cast:
			let character = self.cast[indexPath]?.relationships.characters.data.first
			self.performSegue(withIdentifier: R.segue.episodeDetailsCollectionViewController.characterDetailsSegue.identifier, sender: character)
		case .suggestedEpisodes:
			let suggestedEpisode = self.suggestedEpisodes[indexPath.item]
			self.performSegue(withIdentifier: R.segue.episodeDetailsCollectionViewController.episodeDetailsSegue.identifier, sender: suggestedEpisode)
		default: return
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .header, .badge, .synopsis, .rateAndReview, .rating, .information, .sosumi:
			return nil
		case .reviews:
			return self.reviews[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .cast:
			return self.cast[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .suggestedEpisodes:
			return self.suggestedEpisodes[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}
	}
}
