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
			let show = self.shows[indexPath]
			self.performSegue(withIdentifier: R.segue.studioDetailsCollectionViewController.showDetailsSegue, sender: show)
		case .literatures:
			let literature = self.literatures[indexPath]
			self.performSegue(withIdentifier: R.segue.studioDetailsCollectionViewController.literatureDetailsSegue, sender: literature)
		case .games:
			let game = self.games[indexPath]
			self.performSegue(withIdentifier: R.segue.studioDetailsCollectionViewController.gameDetailsSegue, sender: game)
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .shows:
			return self.shows[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .literatures:
			return self.literatures[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		case .games:
			return self.games[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		default: break
		}

		return nil
	}
}
