//
//  ShowDetailsCollectionViewController+TouchBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import UIKit

extension ShowDetailsCollectionViewController: NSTouchBarDelegate {
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self

		touchBar.defaultItemIdentifiers = [
			.toggleShowIsReminded,
			.toggleShowIsFavorite
		]
		return touchBar
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		let touchBarItem: NSTouchBarItem?
		guard let show = self.show else { return nil }

		switch identifier {
		case .toggleShowIsFavorite:
			let name = show.attributes.favoriteStatus == .favorited ? "heart.fill" : "heart"
			guard let image = UIImage(systemName: name) else { return nil }
			toggleShowIsFavoriteTouchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(toggleFavorite))
			touchBarItem = toggleShowIsFavoriteTouchBarItem
		case .toggleShowIsReminded:
			let name = show.attributes.reminderStatus == .reminded ? "bell.fill" : "bell"
			guard let image = UIImage(systemName: name) else { return nil }
			toggleShowIsRemindedTouchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(toggleReminder))
			touchBarItem = toggleShowIsRemindedTouchBarItem
		default:
			touchBarItem = nil
		}
		return touchBarItem
	}
}
#endif
