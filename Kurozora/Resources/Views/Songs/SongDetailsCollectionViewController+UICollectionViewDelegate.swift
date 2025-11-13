//
//  SongDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/11/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

extension SongDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .shows:
			guard let show = self.shows[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.songDetailsCollectionViewController.showDetailsSegue, sender: show)
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .shows:
			guard let show = self.shows[indexPath] else { return nil }
            return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .reviews:
			guard let review = self.reviews[safe: indexPath.item] else { return nil }
			return review.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default: break
		}

		return nil
	}
}
