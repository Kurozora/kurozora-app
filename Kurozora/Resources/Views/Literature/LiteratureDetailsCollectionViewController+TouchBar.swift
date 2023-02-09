//
//  LiteratureDetailsCollectionViewController+TouchBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2021 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import UIKit

extension LiteratureDetailsCollectionViewController: NSTouchBarDelegate {
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
		guard let literature = self.literature else { return nil }

		switch identifier {
		case .toggleModelIsFavorite:
			let name = literature.attributes.favoriteStatus == .favorited ? "heart.fill" : "heart"
			guard let image = UIImage(systemName: name) else { return nil }
			self.toggleLiteratureIsFavoriteTouchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(self.toggleFavorite))
			touchBarItem = self.toggleLiteratureIsFavoriteTouchBarItem
		default:
			touchBarItem = nil
		}
		return touchBarItem
	}
}
#endif
