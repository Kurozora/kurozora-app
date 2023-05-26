//
//  PersonDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension PersonDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .shows:
			let show = self.shows[indexPath]
			self.performSegue(withIdentifier: R.segue.personDetailsCollectionViewController.showDetailsSegue, sender: show)
		case .literatures:
			let literature = self.literatures[indexPath]
			self.performSegue(withIdentifier: R.segue.personDetailsCollectionViewController.literatureDetailsSegue, sender: literature)
		case .games:
			let game = self.games[indexPath]
			self.performSegue(withIdentifier: R.segue.personDetailsCollectionViewController.gameDetailsSegue, sender: game)
		case .characters:
			let character = self.characters[indexPath]
			self.performSegue(withIdentifier: R.segue.personDetailsCollectionViewController.characterDetailsSegue, sender: character)
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
		case .characters:
			return self.characters[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		default: break
		}

		return nil
	}
}
