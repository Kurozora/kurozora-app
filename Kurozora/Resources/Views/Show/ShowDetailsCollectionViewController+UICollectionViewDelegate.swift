//
//  ShowDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ShowDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .badges:
			guard let showDetailBadge = ShowDetail.Badge(rawValue: indexPath.item) else { return }
			switch showDetailBadge {
			case .rating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.rating) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: 0, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .season:
				if self.show?.attributes.startedAt != nil, self.show?.attributes.airSeason != nil {
					self.show(.seasonalBrowseSegue, sender: nil)
				} else if let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) {
					collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.airDates.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				}
				return
			case .rank:
				self.show(.topChartsSegue, sender: nil)
				return
			case .tvRating:
				guard let showIdentity = self.showIdentity else { return }
				self.show(.parentalGuideSegue, sender: showIdentity)
				return
			case .studio:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.moreByStudio) else { return }
				let indexPath = IndexPath(row: 0, section: sectionIndex)
				self.show(.showsListSegue, sender: indexPath)
				return
			case .country:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.countryOfOrigin.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .language:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.languages.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			}
		case .seasons:
			guard let season = self.cache[indexPath] as? Season else { return }
			self.show(.episodesListSegue, sender: season)
		case .songs:
			guard let song = self.showSongs[safe: indexPath.item]?.song else { return }
			self.show(.songDetailsSegue, sender: song)
		case .studios:
			guard let studio = self.cache[indexPath] as? Studio else { return }
			self.show(.studioDetailsSegue, sender: studio)
		case .moreByStudio:
			guard let show = self.cache[indexPath] as? Show else { return }
			self.show(.showDetailsSegue, sender: show)
		case .relatedShows:
			guard let show = self.relatedShows[safe: indexPath.item]?.show else { return }
			self.show(.showDetailsSegue, sender: show)
		case .relatedLiteratures:
			guard let literature = self.relatedLiteratures[safe: indexPath.item]?.literature else { return }
			self.show(.literatureDetailsSegue, sender: literature)
		case .relatedGames:
			guard let game = self.relatedGames[safe: indexPath.item]?.game else { return }
			self.show(.gameDetailsSegue, sender: game)
		case .reviews:
			guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
			switch itemKind {
			case .review(let review, _):
				self.present(.reviewDetailsSegue, sender: review)
			default: break
			}
		default: return
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .reviews:
			guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
			switch itemKind {
			case .review(let review, _):
				return review.contextMenuConfiguration(in: self, userInfo: nil, sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			default:
				return nil
			}
		case .seasons:
			guard let season = self.cache[indexPath] as? Season else { return nil }
			return season.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .cast:
			guard let cast = self.cache[indexPath] as? Cast else { return nil }
			return cast.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .songs:
			guard
				let showSong = self.showSongs[safe: indexPath.item],
				let appleMusicID = showSong.song.attributes.amID,
				let song = self.resolvedSongs[appleMusicID]
			else { return nil }
			return showSong.song.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": song
			], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .studios:
			guard let studio = self.cache[indexPath] as? Studio else { return nil }
			return studio.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .moreByStudio:
			guard let show = self.cache[indexPath] as? Show else { return nil }
            return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .relatedShows:
            return self.relatedShows[indexPath.item].show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .relatedLiteratures:
			return self.relatedLiteratures[indexPath.item].literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .relatedGames:
			return self.relatedGames[indexPath.item].game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default: break
		}

		return nil
	}
}
