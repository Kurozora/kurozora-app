//
//  CharacterDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension CharacterDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.snapshot.sectionIdentifiers[indexPath.section] {
		case .shows:
			guard let show = self.shows[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.characterDetailsCollectionViewController.showDetailsSegue, sender: show)
		case .literatures:
			guard let literature = self.literatures[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.characterDetailsCollectionViewController.literatureDetailsSegue, sender: literature)
		case .games:
			guard let game = self.games[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.characterDetailsCollectionViewController.gameDetailsSegue, sender: game)
		case .people:
			guard let person = self.people[indexPath] else { return }
			self.performSegue(withIdentifier: R.segue.characterDetailsCollectionViewController.personDetailsSegue, sender: person)
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
		case .people:
			return self.people[indexPath]?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default: break
		}

		return nil
	}
}
