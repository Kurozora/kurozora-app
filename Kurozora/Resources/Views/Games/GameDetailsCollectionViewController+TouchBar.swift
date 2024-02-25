//
//  GameDetailsCollectionViewController+TouchBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import UIKit

extension GameDetailsCollectionViewController: NSTouchBarDelegate {
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self

		touchBar.defaultItemIdentifiers = [
			.toggleModelIsReminded,
			.toggleModelIsFavorite
		]
		return touchBar
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		let touchBarItem: NSTouchBarItem?
		guard let game = self.game else { return nil }

		switch identifier {
		case .toggleModelIsFavorite:
			let name = game.attributes.library?.favoriteStatus == .favorited ? "heart.fill" : "heart"
			guard let image = UIImage(systemName: name) else { return nil }
			self.toggleGameIsFavoriteTouchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(self.toggleFavorite))
			touchBarItem = self.toggleGameIsFavoriteTouchBarItem
		default:
			touchBarItem = nil
		}
		return touchBarItem
	}
}
#endif
