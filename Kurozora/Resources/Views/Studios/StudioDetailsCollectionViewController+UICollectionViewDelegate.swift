//
//  StudioDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension StudioDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .badges:
			guard let studioDetailBadge = StudioDetail.Badge(rawValue: indexPath.item) else { return }
			switch studioDetailBadge {
			case .rating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.rating) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: 0, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .rank:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: StudioDetail.Information.rating.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .tvRating:
				guard let sectionIndex = self.snapshot.indexOfSection(SectionLayoutKind.information) else { return }
				collectionView.safeScrollToItem(at: IndexPath(row: StudioDetail.Information.rating.rawValue, section: sectionIndex), at: .centeredVertically, animated: true)
				return
			case .successor:
				guard let successor = self.studio.relationships?.successors?.data.first else { return }
				self.performSegue(withIdentifier: R.segue.studioDetailsCollectionViewController.studioDetailsSegue.identifier, sender: successor)
				return
			}
		case .shows:
			guard let show = self.shows[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.studioDetailsCollectionViewController.showDetailsSegue, sender: show)
		case .literatures:
			guard let literature = self.literatures[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.studioDetailsCollectionViewController.literatureDetailsSegue, sender: literature)
		case .games:
			guard let game = self.games[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.studioDetailsCollectionViewController.gameDetailsSegue, sender: game)
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .reviews:
			return self.reviews[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .shows:
            return self.shows[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .literatures:
			return self.literatures[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .games:
			return self.games[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default: break
		}

		return nil
	}
}
