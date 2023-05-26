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
			let show = self.shows[indexPath]
			self.performSegue(withIdentifier: R.segue.songDetailsCollectionViewController.showDetailsSegue, sender: show)
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .shows:
			return self.shows[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		default: break
		}

		return nil
	}
}
