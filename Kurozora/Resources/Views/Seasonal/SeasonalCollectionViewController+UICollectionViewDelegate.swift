//
//  SeasonalCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension SeasonalCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.dataSource.sectionIdentifier(for: indexPath.section) {
		case .browseSeason(let browseSeason):
			if let shows = browseSeason.relationships.shows?.data {
				guard let show = shows[safe: indexPath.item] else { return }
				self.show(.showDetailsSegue, sender: show)
			} else if let literatures = browseSeason.relationships.literatures?.data {
				guard let literature = literatures[safe: indexPath.item] else { return }
				self.show(.literatureDetailsSegue, sender: literature)
			} else if let games = browseSeason.relationships.games?.data {
				guard let game = games[safe: indexPath.item] else { return }
				self.show(.gameDetailsSegue, sender: game)
			}
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: indexPath.section) else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch sectionIdentifier {
		case .browseSeason(let browseSeason):
			if let shows = browseSeason.relationships.shows?.data {
				return shows[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			} else if let literatures = browseSeason.relationships.literatures?.data {
				return literatures[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			} else if let games = browseSeason.relationships.games?.data {
				return games[safe: indexPath.item]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
			}
		}

		return nil
	}
}
