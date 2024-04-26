//
//  ShowSongsListCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension ShowSongsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if !self.showSongs.isEmpty {
			self.performSegue(withIdentifier: R.segue.showSongsListCollectionViewController.songDetailsSegue, sender: self.showSongs[indexPath.item].song)
		} else if !self.songs.isEmpty {
			self.performSegue(withIdentifier: R.segue.showSongsListCollectionViewController.songDetailsSegue, sender: self.songs[indexPath.item])
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//		if indexPath.item == self.showSongs.count - 20 && self.nextPageURL != nil {
//			self.fetchShowSongs()
//		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if !self.showSongs.isEmpty {
			guard let cell = collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell else { return nil }
			return self.showSongs[indexPath.item].song.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": cell.song
			])
		} else if !self.songs.isEmpty {
			return self.songs[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}

		return nil
	}
}
