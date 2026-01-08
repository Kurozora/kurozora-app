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
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.airDates.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .rank:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.genres.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .tvRating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: ShowDetail.Information.rating.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .studio:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.moreByStudio) else { return }
				let indexPath = IndexPath(row: 0, section: sectionIndex)
				self.show(SegueIdentifiers.showsListSegue, sender: indexPath)
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
			self.show(SegueIdentifiers.episodesListSegue, sender: season)
		case .songs:
			guard let song = self.showSongs[safe: indexPath.item]?.song else { return }
			self.show(SegueIdentifiers.songDetailsSegue, sender: song)
		case .studios:
			guard let studio = self.cache[indexPath] as? Studio else { return }
			self.show(SegueIdentifiers.studioDetailsSegue, sender: studio)
		case .moreByStudio:
			guard let show = self.cache[indexPath] as? Show else { return }
			self.show(SegueIdentifiers.showDetailsSegue, sender: show)
		case .relatedShows:
			guard let show = self.relatedShows[safe: indexPath.item]?.show else { return }
			self.show(SegueIdentifiers.showDetailsSegue, sender: show)
		case .relatedLiteratures:
			guard let literature = self.relatedLiteratures[safe: indexPath.item]?.literature else { return }
			self.show(SegueIdentifiers.literatureDetailsSegue, sender: literature)
		case .relatedGames:
			guard let game = self.relatedGames[safe: indexPath.item]?.game else { return }
			self.show(SegueIdentifiers.gameDetailsSegue, sender: game)
		default: return
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .reviews:
			return self.reviews[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .seasons:
			guard let season = self.cache[indexPath] as? Season else { return nil }
			return season.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .cast:
			guard let cast = self.cache[indexPath] as? Cast else { return nil }
			return cast.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .songs:
			guard
				let cell = collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell,
				let song = cell.song
			else { return nil }
			return self.showSongs[indexPath.item].song.contextMenuConfiguration(in: self, userInfo: [
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
