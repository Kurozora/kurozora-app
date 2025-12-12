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
			guard let showSong = self.showSongs[safe: indexPath.item] else { return }
			self.performSegue(withIdentifier: SegueIdentifiers.songDetailsSegue, sender: showSong.song)
		} else if !self.songs.isEmpty {
			guard let song = self.songs[safe: indexPath.item] else { return }
			self.performSegue(withIdentifier: SegueIdentifiers.songDetailsSegue, sender: song)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//		if indexPath.item == self.showSongs.count - 20 && self.nextPageURL != nil {
//			self.fetchShowSongs()
//		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		if !self.showSongs.isEmpty {
			guard
				let cell = collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell,
				let song = cell.song
			else { return nil }
			return self.showSongs[indexPath.item].song.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": song
			], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		} else if !self.songs.isEmpty {
			return self.songs[indexPath.item].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}

		return nil
	}
}
