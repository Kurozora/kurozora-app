//
//  TopChartsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension TopChartsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .showIdentity:
			guard let show = self.cache[indexPath] as? Show else { return }
			self.show(.showDetailsSegue, sender: show)
		case .characterIdentity:
			guard let character = self.cache[indexPath] as? Character else { return }
			self.show(.characterDetailsSegue, sender: character)
		case .episodeIdentity:
			guard let episode = self.cache[indexPath] as? Episode else { return }
			self.show(.episodeDetailsSegue, sender: [indexPath: episode])
		case .gameIdentity:
			guard let game = self.cache[indexPath] as? Game else { return }
			self.show(.gameDetailsSegue, sender: game)
		case .literatureIdentity:
			guard let literature = self.cache[indexPath] as? Literature else { return }
			self.show(.literatureDetailsSegue, sender: literature)
		case .personIdentity:
			guard let person = self.cache[indexPath] as? Person else { return }
			self.show(.personDetailsSegue, sender: person)
		case .songIdentity:
			guard let song = self.cache[indexPath] as? Song else { return }
			self.show(.songDetailsSegue, sender: song)
		case .studioIdentity:
			guard let studio = self.cache[indexPath] as? Studio else { return }
			self.show(.studioDetailsSegue, sender: studio)
		case .pending: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch itemKind {
		case .showIdentity:
			guard let show = self.cache[indexPath] as? Show else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .characterIdentity:
			guard let character = self.cache[indexPath] as? Character else { return nil }
			return character.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .episodeIdentity:
			guard let episode = self.cache[indexPath] as? Episode else { return nil }
			return episode.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .gameIdentity:
			guard let game = self.cache[indexPath] as? Game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .literatureIdentity:
			guard let literature = self.cache[indexPath] as? Literature else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .personIdentity:
			guard let person = self.cache[indexPath] as? Person else { return nil }
			return person.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .songIdentity:
			guard
				let song = self.cache[indexPath] as? Song,
				let appleMusicID = song.attributes.amID,
				let resolvedSong = self.resolvedSongs[appleMusicID]
			else { return nil }
			return song.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": resolvedSong
			], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .studioIdentity:
			guard let studio = self.cache[indexPath] as? Studio else { return nil }
			return studio.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .pending: return nil
		}
	}
}
