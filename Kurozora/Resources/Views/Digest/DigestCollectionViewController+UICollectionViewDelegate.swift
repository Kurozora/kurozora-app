//
//  DigestCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension DigestCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let section = self.dataSource.sectionIdentifier(for: indexPath.section) else { return }

		switch section {
		case .hero, .becauseYouWatched, .dropIn, .rescueOnHold, .rescuePlanning, .premiering:
			guard let show = self.cache[indexPath] as? Show else { return }
			self.show(.showDetailsSegue, sender: show)
		case .newReleases, .releasing:
			guard let game = self.cache[indexPath] as? Game else { return }
			self.show(.gameDetailsSegue, sender: game)
		case .newEpisodes, .finales, .trending:
			guard let episode = self.cache[indexPath] as? Episode else { return }
			self.show(.episodeDetailsSegue, sender: [indexPath: episode])
		case .birthdays:
			guard let person = self.cache[indexPath] as? Person else { return }
			self.show(.personDetailsSegue, sender: person)
		case .momentum, .growth:
			break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let section = self.dataSource.sectionIdentifier(for: indexPath.section) else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch section {
		case .hero, .becauseYouWatched, .dropIn, .rescueOnHold, .rescuePlanning, .premiering:
			guard let show = self.cache[indexPath] as? Show else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .newReleases, .releasing:
			guard let game = self.cache[indexPath] as? Game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .newEpisodes, .finales, .trending:
			guard let episode = self.cache[indexPath] as? Episode else { return nil }
			return episode.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .birthdays:
			guard let person = self.cache[indexPath] as? Person else { return nil }
			return person.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .momentum, .growth:
			return nil
		}
	}
}
